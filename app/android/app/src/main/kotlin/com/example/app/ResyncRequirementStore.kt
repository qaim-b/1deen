package com.example.app

import android.content.Context

class ResyncRequirementStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun markRequired(reason: String) {
        prefs.edit()
            .putBoolean(KEY_REQUIRED, true)
            .putString(KEY_REASON, reason)
            .putLong(KEY_MARKED_AT, System.currentTimeMillis())
            .apply()
    }

    fun consumeRequired(): Boolean {
        val required = prefs.getBoolean(KEY_REQUIRED, false)
        if (required) {
            prefs.edit().putBoolean(KEY_REQUIRED, false).apply()
        }
        return required
    }

    private companion object {
        private const val PREFS_NAME = "salah_guard_resync"
        private const val KEY_REQUIRED = "required"
        private const val KEY_REASON = "reason"
        private const val KEY_MARKED_AT = "marked_at"
    }
}
