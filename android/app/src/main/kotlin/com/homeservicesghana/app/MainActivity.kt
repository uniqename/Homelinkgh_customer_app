package com.homeservicesghana.app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val PHONE_CHANNEL = "flutter.native/phone"
    private val EMAIL_CHANNEL = "flutter.native/email"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, PHONE_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "makeCall") {
                val phoneNumber = call.argument<String>("phoneNumber")
                if (phoneNumber != null) {
                    val intent = Intent(Intent.ACTION_DIAL).apply {
                        data = Uri.parse("tel:$phoneNumber")
                    }
                    startActivity(intent)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Phone number is required", null)
                }
            } else {
                result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, EMAIL_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "sendEmail") {
                val email = call.argument<String>("email")
                if (email != null) {
                    val intent = Intent(Intent.ACTION_SENDTO).apply {
                        data = Uri.parse("mailto:$email")
                    }
                    startActivity(intent)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Email is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}