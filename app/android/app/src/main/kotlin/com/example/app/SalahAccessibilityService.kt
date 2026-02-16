package com.example.app

import android.accessibilityservice.AccessibilityService
import android.os.Handler
import android.os.Looper
import android.content.Intent
import android.view.accessibility.AccessibilityEvent

class SalahAccessibilityService : AccessibilityService() {
    private lateinit var configStore: LockConfigStore
    private lateinit var lockWindowStore: LockWindowStore
    private lateinit var blockedAppsStore: BlockedAppsStore
    private lateinit var emergencyUnlockController: EmergencyUnlockController
    private lateinit var heartbeatStore: GuardHeartbeatStore
    private lateinit var logger: LockEventLogger

    private val heartbeatHandler = Handler(Looper.getMainLooper())
    private val heartbeatRunnable = object : Runnable {
        override fun run() {
            heartbeatStore.beat(reason = "service_periodic")
            heartbeatHandler.postDelayed(this, HEARTBEAT_INTERVAL_MILLIS)
        }
    }

    private var lastOverlayAtMillis: Long = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        configStore = LockConfigStore(applicationContext)
        lockWindowStore = LockWindowStore(applicationContext)
        blockedAppsStore = BlockedAppsStore(applicationContext)
        emergencyUnlockController = EmergencyUnlockController(applicationContext)
        heartbeatStore = GuardHeartbeatStore(applicationContext)
        logger = LockEventLogger(applicationContext)

        heartbeatStore.beat(reason = "service_connected")
        heartbeatHandler.removeCallbacks(heartbeatRunnable)
        heartbeatHandler.post(heartbeatRunnable)

        logger.info(
            event = "service_connected",
            details = mapOf(
                "blocked_apps_count" to blockedAppsStore.load().size,
                "has_active_window" to (lockWindowStore.activeWindow(System.currentTimeMillis()) != null),
            ),
        )
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event == null) {
            return
        }

        if (event.eventType != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED &&
            event.eventType != AccessibilityEvent.TYPE_WINDOWS_CHANGED
        ) {
            return
        }

        heartbeatStore.beat(reason = "event_${event.eventType}")

        val packageName = event.packageName?.toString()?.trim().orEmpty()
        if (packageName.isBlank() || packageName == applicationContext.packageName) {
            return
        }

        if (emergencyUnlockController.isActive()) {
            logger.info(event = "lock_skipped_emergency_unlock", details = mapOf("package" to packageName))
            return
        }

        val now = System.currentTimeMillis()
        val currentWindow = lockWindowStore.activeWindow(now)
        if (currentWindow == null) {
            return
        }

        val blockedApps = blockedAppsStore.load()
        if (!blockedApps.contains(packageName)) {
            return
        }

        val strictnessMode = configStore.load().strictnessMode
        if (strictnessMode == "reminder") {
            val elapsedSinceLastOverlay = now - lastOverlayAtMillis
            if (elapsedSinceLastOverlay < REMINDER_THROTTLE_MILLIS) {
                return
            }
        }

        val elapsedSinceLastOverlay = now - lastOverlayAtMillis
        if (elapsedSinceLastOverlay < OVERLAY_THROTTLE_MILLIS) {
            return
        }

        launchOverlay(
            prayerName = currentWindow.prayerName,
            endEpochMillis = currentWindow.endEpochMillis,
            strictnessMode = strictnessMode,
            blockedPackage = packageName,
        )
        lastOverlayAtMillis = now
    }

    override fun onUnbind(intent: Intent?): Boolean {
        if (::logger.isInitialized) {
            logger.warn(event = "service_unbind")
        }
        return super.onUnbind(intent)
    }

    override fun onInterrupt() {
        if (::logger.isInitialized) {
            logger.warn(event = "service_interrupted")
        }
    }

    override fun onDestroy() {
        heartbeatHandler.removeCallbacks(heartbeatRunnable)
        if (::heartbeatStore.isInitialized) {
            heartbeatStore.beat(reason = "service_destroyed")
        }
        if (::logger.isInitialized) {
            logger.warn(event = "service_destroyed")
        }
        super.onDestroy()
    }

    private fun launchOverlay(
        prayerName: String,
        endEpochMillis: Long,
        strictnessMode: String,
        blockedPackage: String,
    ) {
        val intent = Intent(this, LockOverlayActivity::class.java).apply {
            addFlags(
                Intent.FLAG_ACTIVITY_NEW_TASK or
                    Intent.FLAG_ACTIVITY_CLEAR_TOP or
                    Intent.FLAG_ACTIVITY_EXCLUDE_FROM_RECENTS,
            )
            putExtra(LockOverlayActivity.EXTRA_PRAYER_NAME, prayerName)
            putExtra(LockOverlayActivity.EXTRA_END_EPOCH_MILLIS, endEpochMillis)
            putExtra(LockOverlayActivity.EXTRA_STRICTNESS_MODE, strictnessMode)
        }

        logger.info(
            event = "overlay_launch",
            details = mapOf(
                "prayer" to prayerName,
                "blocked_package" to blockedPackage,
                "strictness" to strictnessMode,
                "window_end" to endEpochMillis,
            ),
        )
        startActivity(intent)
    }

    private companion object {
        private const val OVERLAY_THROTTLE_MILLIS = 2500L
        private const val REMINDER_THROTTLE_MILLIS = 60000L
        private const val HEARTBEAT_INTERVAL_MILLIS = 30000L
    }
}
