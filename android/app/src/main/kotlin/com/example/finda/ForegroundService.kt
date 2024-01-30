package com.example.finda

import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.app.KeyguardManager
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class ForegroundAppService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.packageName == "com.android.stk"&&LimitListConstant.shouldservicerun) {
            performGlobalAction(GLOBAL_ACTION_BACK)
            showToast("Currently in an unsafe location Stk Launch prevented ")
        }
    }

    override fun onInterrupt() {
        // Not used
    }

    private fun showToast(message: String) {
        Toast.makeText(applicationContext, message, Toast.LENGTH_LONG).show()
    }
}
