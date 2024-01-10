package com.example.finda

import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.provider.Settings
import android.text.TextUtils
import android.view.accessibility.AccessibilityManager
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity: FlutterActivity() {
    private val channelName="STKchannel";
    private fun requestAccessibilityPermissions() {
        val accessibilityService = ForegroundAppService::class.java
        if (!isAccessibilityServiceEnabled(this, accessibilityService)) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
        }
    }


   private fun isAccessibilityServiceEnabled(
        context: Context,
        accessibilityService: Class<out AccessibilityService>
    ): Boolean {
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES
        )
        val colonSplitter = TextUtils.SimpleStringSplitter(':')

        colonSplitter.setString(enabledServices)

        while (colonSplitter.hasNext()) {
            if (colonSplitter.next().equals(
                    "${context.packageName}/${accessibilityService.name}",
                    ignoreCase = true
                )
            ) {
                return true
            }
        }

        return false
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        //check if service is running
        requestAccessibilityPermissions()

        var channel=MethodChannel(flutterEngine.dartExecutor.binaryMessenger,channelName);

        channel.setMethodCallHandler { call, result ->
            val intentFilter = IntentFilter("com.android.stk.intent.ACTION_STK_COMMAND")
            if(call.method=="preventSTKLaunch")
            {
                // Check the current foreground application

//                registerReceiver(stkReceiver, intentFilter)

            }
            if(call.method=="enableSTKLaunch")
            {
//                try {
//                    unregisterReceiver(stkReceiver)
//                    Toast.makeText(this,"SIM toolkit launch enabled",Toast.LENGTH_LONG).show();
//                } catch (e: IllegalArgumentException) {
//                    Toast.makeText(this,e.message,Toast.LENGTH_LONG).show();
//                }

            }

        }
    }
}
