package com.example.app

import android.content.Context

class LockConfigStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun save(configuration: LockConfiguration) {
        prefs.edit()
            .putString(KEY_STRICTNESS_MODE, configuration.strictnessMode)
            .putInt(KEY_LOCK_BEFORE_MINUTES, configuration.lockBeforeMinutes)
            .putInt(KEY_LOCK_AFTER_MINUTES, configuration.lockAfterMinutes)
            .apply()
    }

    fun load(): LockConfiguration {
        return LockConfiguration(
            strictnessMode = prefs.getString(KEY_STRICTNESS_MODE, DEFAULT_STRICTNESS_MODE) ?: DEFAULT_STRICTNESS_MODE,
            lockBeforeMinutes = prefs.getInt(KEY_LOCK_BEFORE_MINUTES, DEFAULT_LOCK_BEFORE_MINUTES),
            lockAfterMinutes = prefs.getInt(KEY_LOCK_AFTER_MINUTES, DEFAULT_LOCK_AFTER_MINUTES),
        )
    }

    private companion object {
        private const val PREFS_NAME = "salah_guard_lock_config"
        private const val KEY_STRICTNESS_MODE = "strictness_mode"
        private const val KEY_LOCK_BEFORE_MINUTES = "lock_before_minutes"
        private const val KEY_LOCK_AFTER_MINUTES = "lock_after_minutes"

        private const val DEFAULT_STRICTNESS_MODE = "soft"
        private const val DEFAULT_LOCK_BEFORE_MINUTES = 15
        private const val DEFAULT_LOCK_AFTER_MINUTES = 20
    }
}
