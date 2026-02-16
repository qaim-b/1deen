package com.example.app

import android.content.ComponentName
import android.content.Context
import android.provider.Settings

class LockEngineHealthChecker(private val context: Context) {
    private val heartbeatStore = GuardHeartbeatStore(context)
    private val eventStore = LockEventStore(context)

    fun isHealthy(): Boolean {
        if (!isAccessibilityServiceEnabled()) {
            return false
        }

        val lastHeartbeat = heartbeatStore.lastHeartbeatAtMillis()
        if (lastHeartbeat <= 0L) {
            return false
        }

        return System.currentTimeMillis() - lastHeartbeat <= HEARTBEAT_STALE_AFTER_MILLIS
    }

    fun debugSnapshot(): Map<String, Any> {
        val lastHeartbeat = heartbeatStore.lastHeartbeatAtMillis()
        val lastEventAt = eventStore.lastEventAtMillis()
        return mapOf(
            "accessibilityEnabled" to isAccessibilityServiceEnabled(),
            "lastHeartbeatAt" to lastHeartbeat,
            "lastHeartbeatReason" to heartbeatStore.lastHeartbeatReason(),
            "heartbeatAgeMs" to if (lastHeartbeat > 0) (System.currentTimeMillis() - lastHeartbeat) else -1L,
            "lastLockEvent" to (eventStore.lastEvent() ?: ""),
            "lastLockEventAt" to lastEventAt,
            "lastLockEventAgeMs" to if (lastEventAt > 0) (System.currentTimeMillis() - lastEventAt) else -1L,
        )
    }

    private fun isAccessibilityServiceEnabled(): Boolean {
        val enabledServices = Settings.Secure.getString(
            context.contentResolver,
            Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES,
        ) ?: return false

        val expectedComponent = ComponentName(context, SalahAccessibilityService::class.java).flattenToString()
        return enabledServices.split(':').any { it.equals(expectedComponent, ignoreCase = true) }
    }

    private companion object {
        private const val HEARTBEAT_STALE_AFTER_MILLIS = 90000L
    }
}
