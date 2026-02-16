package com.example.app

import android.content.Context

class EmergencyUnlockController(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun activate(durationSeconds: Int = 30) {
        val unlockUntil = System.currentTimeMillis() + durationSeconds.coerceAtLeast(5) * 1000L
        prefs.edit().putLong(KEY_UNLOCK_UNTIL_MILLIS, unlockUntil).apply()
    }

    fun isActive(): Boolean {
        val unlockUntil = prefs.getLong(KEY_UNLOCK_UNTIL_MILLIS, 0L)
        return unlockUntil > System.currentTimeMillis()
    }

    private companion object {
        private const val PREFS_NAME = "salah_guard_unlock"
        private const val KEY_UNLOCK_UNTIL_MILLIS = "unlock_until_millis"
    }
}
