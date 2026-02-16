package com.example.app

import android.content.Context
import android.util.Log
import org.json.JSONObject

class LockEventLogger(
    context: Context? = null,
    private val tag: String = TAG,
) {
    private val eventStore = context?.let { LockEventStore(it.applicationContext) }

    fun info(event: String, details: Map<String, Any?> = emptyMap()) {
        log("INFO", event, details)
    }

    fun warn(event: String, details: Map<String, Any?> = emptyMap()) {
        log("WARN", event, details)
    }

    fun error(event: String, details: Map<String, Any?> = emptyMap(), throwable: Throwable? = null) {
        eventStore?.save(event)
        val payload = buildPayload(event, details)
        if (throwable == null) {
            Log.e(tag, payload)
        } else {
            Log.e(tag, payload, throwable)
        }
    }

    private fun log(level: String, event: String, details: Map<String, Any?>) {
        eventStore?.save(event)
        val payload = buildPayload(event, details)
        when (level) {
            "INFO" -> Log.i(tag, payload)
            "WARN" -> Log.w(tag, payload)
            else -> Log.d(tag, payload)
        }
    }

    private fun buildPayload(event: String, details: Map<String, Any?>): String {
        val json = JSONObject()
            .put("event", event)
            .put("ts", System.currentTimeMillis())

        details.forEach { (key, value) ->
            json.put(key, value)
        }
        return json.toString()
    }

    private companion object {
        private const val TAG = "OneDeenLockEngine"
    }
}
