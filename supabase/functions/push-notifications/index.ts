// Supabase Edge Function: push-notifications
// Sends FCM v1 push notifications when triggered (e.g. notifications table INSERT webhook).
//
// Deploy:
//   supabase functions deploy push-notifications
//
// Set secrets (from Firebase service account JSON):
//   supabase secrets set FCM_PROJECT_ID=your-project-id
//   supabase secrets set FCM_CLIENT_EMAIL=firebase-adminsdk-xxx@your-project.iam.gserviceaccount.com
//   supabase secrets set FCM_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
//
// Wire up in Supabase Dashboard → Database → Webhooks:
//   Table: notifications, Event: INSERT
//   URL: https://<project-ref>.supabase.co/functions/v1/push-notifications
//   Header: Authorization: Bearer <SUPABASE_SERVICE_ROLE_KEY>

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { create, getNumericDate } from "https://deno.land/x/djwt@v3.0.2/mod.ts";

const FCM_V1_URL = (projectId: string) =>
  `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

/** Get a short-lived OAuth2 access token using the service account private key */
async function getAccessToken(
  clientEmail: string,
  privateKeyPem: string
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);

  // Import the RSA private key
  const keyData = privateKeyPem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\n/g, "");

  const binaryKey = Uint8Array.from(atob(keyData), (c) => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    "pkcs8",
    binaryKey,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const jwt = await create(
    { alg: "RS256", typ: "JWT" },
    {
      iss: clientEmail,
      sub: clientEmail,
      aud: "https://oauth2.googleapis.com/token",
      iat: getNumericDate(0),
      exp: getNumericDate(60 * 60), // 1 hour
      scope: "https://www.googleapis.com/auth/firebase.messaging",
    },
    cryptoKey
  );

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  const tokenData = await tokenResponse.json();
  if (!tokenData.access_token) {
    throw new Error(`Failed to get access token: ${JSON.stringify(tokenData)}`);
  }
  return tokenData.access_token;
}

serve(async (req: Request) => {
  try {
    const payload = await req.json();

    // Support both direct calls and Supabase webhook payloads
    const record = payload?.record ?? payload;
    const { user_id, title, message, type, data } = record;

    if (!user_id || !title || !message) {
      return new Response(JSON.stringify({ error: "Missing required fields" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Load Firebase service account from Supabase secrets
    const projectId = Deno.env.get("FCM_PROJECT_ID");
    const clientEmail = Deno.env.get("FCM_CLIENT_EMAIL");
    const privateKey = Deno.env.get("FCM_PRIVATE_KEY");

    if (!projectId || !clientEmail || !privateKey) {
      console.error("FCM service account secrets not configured");
      return new Response(JSON.stringify({ error: "FCM not configured" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Look up FCM token in Supabase
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, serviceRoleKey);

    const { data: profile } = await supabase
      .from("user_profiles")
      .select("fcm_token")
      .eq("id", user_id)
      .maybeSingle();

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
      console.warn(`No FCM token for user ${user_id} — skipping push`);
      return new Response(JSON.stringify({ status: "no_token", user_id }), {
        status: 200,
        headers: { "Content-Type": "application/json" },
      });
    }

    // Get OAuth2 access token
    const accessToken = await getAccessToken(clientEmail, privateKey);

    // Build FCM v1 message
    const fcmPayload = {
      message: {
        token: fcmToken,
        notification: {
          title,
          body: message,
        },
        data: {
          type: type ?? "general",
          user_id,
          ...(typeof data === "object" && data !== null
            ? Object.fromEntries(
                Object.entries(data).map(([k, v]) => [k, String(v)])
              )
            : {}),
        },
        android: {
          priority: "high",
          notification: {
            channel_id: "homelinkgh_high_importance",
            color: "#006B3C",
            default_sound: true,
            default_vibrate_timings: true,
          },
        },
        apns: {
          payload: {
            aps: {
              alert: { title, body: message },
              badge: 1,
              sound: "default",
            },
          },
        },
      },
    };

    const fcmResponse = await fetch(FCM_V1_URL(projectId), {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${accessToken}`,
      },
      body: JSON.stringify(fcmPayload),
    });

    const fcmResult = await fcmResponse.json();

    if (fcmResponse.ok) {
      console.log(`✅ Push sent to user ${user_id}: ${fcmResult.name}`);
    } else {
      console.warn(`⚠️ FCM error for user ${user_id}:`, JSON.stringify(fcmResult));
    }

    return new Response(
      JSON.stringify({ status: fcmResponse.ok ? "sent" : "failed", user_id, fcm: fcmResult }),
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
