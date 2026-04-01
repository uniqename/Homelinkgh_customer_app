// Supabase Edge Function: push-notifications
// Sends FCM push notifications when a row is inserted into the notifications table.
//
// Deploy with:
//   supabase functions deploy push-notifications
//
// Set secrets:
//   supabase secrets set FCM_SERVER_KEY=<your Firebase Cloud Messaging server key>
//
// Wire up as a Database Webhook in Supabase Dashboard:
//   Table: notifications, Event: INSERT
//   HTTP URL: https://<project-ref>.supabase.co/functions/v1/push-notifications
//   HTTP Headers: Authorization: Bearer <SUPABASE_SERVICE_ROLE_KEY>

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const FCM_URL = "https://fcm.googleapis.com/fcm/send";

serve(async (req: Request) => {
  try {
    const payload = await req.json();

    // Extract notification record from webhook payload
    const record = payload?.record ?? payload;
    const { user_id, title, message, type, data } = record;

    if (!user_id || !title || !message) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Initialize Supabase admin client to look up FCM token
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY");

    if (!fcmServerKey) {
      console.error("FCM_SERVER_KEY not configured");
      return new Response(JSON.stringify({ error: "FCM not configured" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    const supabase = createClient(supabaseUrl, serviceRoleKey);

    // Look up FCM token from user_profiles
    const { data: profile } = await supabase
      .from("user_profiles")
      .select("fcm_token")
      .eq("id", user_id)
      .maybeSingle();

    // Also check providers table (providers may have a separate fcm_token)
    let fcmToken = profile?.fcm_token;
    if (!fcmToken) {
      const { data: provider } = await supabase
        .from("providers")
        .select("fcm_token")
        .eq("user_id", user_id)
        .maybeSingle();
      fcmToken = provider?.fcm_token;
    }

    if (!fcmToken) {
      console.warn(`No FCM token found for user ${user_id} — skipping push`);
      return new Response(JSON.stringify({ status: "no_token", user_id }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Build FCM payload (legacy HTTP API)
    const fcmPayload = {
      to: fcmToken,
      priority: "high",
      notification: {
        title,
        body: message,
        sound: "default",
        badge: "1",
        android_channel_id: "homelinkgh_high_importance",
        color: "#006B3C",
      },
      data: {
        type: type ?? "general",
        user_id,
        ...(data ?? {}),
      },
    };

    const fcmResponse = await fetch(FCM_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `key=${fcmServerKey}`,
      },
      body: JSON.stringify(fcmPayload),
    });

    const fcmResult = await fcmResponse.json();

    if (fcmResult.success === 1) {
      console.log(`✅ Push sent to user ${user_id}`);
    } else {
      console.warn(`⚠️ FCM response:`, JSON.stringify(fcmResult));
    }

    return new Response(
      JSON.stringify({ status: "sent", user_id, fcm: fcmResult }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (err) {
    console.error("Edge function error:", err);
    return new Response(JSON.stringify({ error: String(err) }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
