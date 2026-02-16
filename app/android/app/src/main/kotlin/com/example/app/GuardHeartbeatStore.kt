package com.example.app

import android.content.Context

class GuardHeartbeatStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun beat(reason: String) {
        prefs.edit()
            .putLong(KEY_LAST_HEARTBEAT_AT, System.currentTimeMillis())
            .putString(KEY_LAST_HEARTBEAT_REASON, reason)
            .apply()
    }

    fun lastHeartbeatAtMillis(): Long {
        return prefs.getLong(KEY_LAST_HEARTBEAT_AT, 0L)
    }

    fun lastHeartbeatReason(): String {
        return prefs.getString(KEY_LAST_HEARTBEAT_REASON, "none") ?: "none"
    }

    private companion object {
        private const val PREFS_NAME = "salah_guard_heartbeat"
        private const val KEY_LAST_HEARTBEAT_AT = "last_heartbeat_at"
        private const val KEY_LAST_HEARTBEAT_REASON = "last_heartbeat_reason"
    }
}
