package com.example.app

import android.content.Context
import org.json.JSONArray
import org.json.JSONObject

class LockWindowStore(context: Context) {
    private val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

    fun save(windows: List<LockWindow>) {
        val array = JSONArray()
        windows.forEach { window ->
            array.put(
                JSONObject()
                    .put(KEY_PRAYER_NAME, window.prayerName)
                    .put(KEY_START_EPOCH_MILLIS, window.startEpochMillis)
                    .put(KEY_END_EPOCH_MILLIS, window.endEpochMillis),
            )
        }

        prefs.edit().putString(KEY_WINDOWS_JSON, array.toString()).apply()
    }

    fun load(): List<LockWindow> {
        val payload = prefs.getString(KEY_WINDOWS_JSON, null) ?: return emptyList()
        return runCatching {
            val array = JSONArray(payload)
            buildList {
                for (index in 0 until array.length()) {
                    val item = array.getJSONObject(index)
                    add(
                        LockWindow(
                            prayerName = item.optString(KEY_PRAYER_NAME, "Prayer"),
                            startEpochMillis = item.optLong(KEY_START_EPOCH_MILLIS, 0L),
                            endEpochMillis = item.optLong(KEY_END_EPOCH_MILLIS, 0L),
                        ),
                    )
                }
            }.sortedBy { it.startEpochMillis }
        }.getOrDefault(emptyList())
    }

    fun activeWindow(nowEpochMillis: Long): LockWindow? {
        return load().firstOrNull { nowEpochMillis in it.startEpochMillis..it.endEpochMillis }
    }

    private companion object {
        private const val PREFS_NAME = "salah_guard_lock_windows"
        private const val KEY_WINDOWS_JSON = "windows_json"
        private const val KEY_PRAYER_NAME = "prayerName"
        private const val KEY_START_EPOCH_MILLIS = "startEpochMillis"
        private const val KEY_END_EPOCH_MILLIS = "endEpochMillis"
    }
}
