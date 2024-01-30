package com.example.finda

import android.accessibilityservice.AccessibilityService
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.provider.Settings
import android.text.TextUtils
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

        var channel=MethodChannel(flutterEngine.dartExecutor.binaryMessenger,channelName);
        channel.setMethodCallHandler { call, result ->

            if(call.method=="setSafeZone")
            {
                var Lrange=call.arguments as Map<String,Double>
                //max longitude
                LimitListConstant.limitlist[0]= Lrange["maxLong"]!!;
                //min longitude
                LimitListConstant.limitlist[1]= Lrange["minLong"]!!;
                //max latitude
                LimitListConstant.limitlist[2]= Lrange["maxLat"]!!;
                //min latitude
                LimitListConstant.limitlist[3]= Lrange["minLat"]!!;
                //set range
                //request accessibility permissions
              //  Toast.makeText(applicationContext, "safezone set max longitude ${ LimitListConstant.limitlist}", Toast.LENGTH_LONG).show()
            }
            if(call.method=="checkIfinRange")
            {
                var location=call.arguments as Map<String,Double>
                val longitude=location["Longitude"]!!;
                val latitude=location["Latitude"]!!;
              //check if location is in range
                if(longitude in  LimitListConstant.limitlist[1].. LimitListConstant.limitlist[0]&&latitude in  LimitListConstant.limitlist[3].. LimitListConstant.limitlist[2] )
                {
                    LimitListConstant.shouldservicerun=false;
                }
                else{
                 //  Toast.makeText(applicationContext, "not in range for max longitude ${ LimitListConstant.limitlist[0]},${ LimitListConstant.limitlist[1]}", Toast.LENGTH_LONG).show()
                    LimitListConstant.shouldservicerun=true;
                }
                if(LimitListConstant.shouldservicerun){
                    requestAccessibilityPermissions();
                }

            }
            if(call.method=="disableSuspiciousFlag")
            {
                //disable features
            }

        }
    }
}
