package com.example.app

import android.content.Context

class GuardStateEvaluator(context: Context) {
    private val lockWindowStore = LockWindowStore(context)
    private val emergencyUnlockController = EmergencyUnlockController(context)

    fun shouldHoldOverlay(nowMillis: Long = System.currentTimeMillis()): Boolean {
        if (emergencyUnlockController.isActive()) {
            return false
        }

        val activeWindow = lockWindowStore.activeWindow(nowMillis)
        return activeWindow != null
    }
}
