package com.example.app

import android.content.Context

class LockEventStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun save(event: String) {
        prefs.edit()
            .putString(KEY_LAST_EVENT, event)
            .putLong(KEY_LAST_EVENT_AT, System.currentTimeMillis())
            .apply()
    }

    fun lastEvent(): String? = prefs.getString(KEY_LAST_EVENT, null)

    fun lastEventAtMillis(): Long = prefs.getLong(KEY_LAST_EVENT_AT, 0L)

    companion object {
        private const val PREFS_NAME = "lock_event_store"
        private const val KEY_LAST_EVENT = "last_event"
        private const val KEY_LAST_EVENT_AT = "last_event_at"
    }
}
