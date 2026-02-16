package com.example.app

import android.content.Context

class BlockedAppsStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun save(packageNames: List<String>) {
        val sanitized = packageNames.map { it.trim() }.filter { it.isNotBlank() }.toSet()
        prefs.edit().putStringSet(KEY_PACKAGE_NAMES, sanitized).apply()
    }

    fun load(): Set<String> {
        val stored = prefs.getStringSet(KEY_PACKAGE_NAMES, null)
        return if (stored.isNullOrEmpty()) {
            DEFAULT_BLOCKED_PACKAGES
        } else {
            stored
        }
    }

    private companion object {
        private const val PREFS_NAME = "salah_guard_blocked_apps"
        private const val KEY_PACKAGE_NAMES = "package_names"

        private val DEFAULT_BLOCKED_PACKAGES = setOf(
            "com.instagram.android",
            "com.zhiliaoapp.musically",
            "com.google.android.youtube",
            "com.facebook.katana",
            "com.twitter.android",
            "com.reddit.frontpage",
        )
    }
}
