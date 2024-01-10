package com.example.finda

import android.accessibilityservice.AccessibilityService
import android.app.ActivityManager
import android.view.accessibility.AccessibilityEvent
import android.widget.Toast

class ForegroundAppService : AccessibilityService() {

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event?.packageName == "com.android.stk") {
            performGlobalAction(GLOBAL_ACTION_BACK)
            showToast("Stk Launch prevented")
        }
    }

    override fun onInterrupt() {
        // Not used
    }

    private fun showToast(message: String) {
        Toast.makeText(applicationContext, message, Toast.LENGTH_SHORT).show()
    }
}
