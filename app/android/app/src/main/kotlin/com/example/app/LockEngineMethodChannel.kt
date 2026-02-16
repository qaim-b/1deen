package com.example.app

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

object LockEngineMethodChannel : MethodChannel.MethodCallHandler {
    private const val CHANNEL_NAME = "salah_guard/lock_engine"

    private lateinit var configStore: LockConfigStore
    private lateinit var healthChecker: LockEngineHealthChecker
    private lateinit var lockWindowStore: LockWindowStore
    private lateinit var blockedAppsStore: BlockedAppsStore
    private lateinit var emergencyUnlockController: EmergencyUnlockController
    private lateinit var logger: LockEventLogger
    private lateinit var scheduler: GuardAutomationScheduler
    private lateinit var resyncRequirementStore: ResyncRequirementStore

    fun register(messenger: BinaryMessenger, context: Context) {
        configStore = LockConfigStore(context)
        healthChecker = LockEngineHealthChecker(context)
        lockWindowStore = LockWindowStore(context)
        blockedAppsStore = BlockedAppsStore(context)
        emergencyUnlockController = EmergencyUnlockController(context)
        logger = LockEventLogger(context)
        scheduler = GuardAutomationScheduler(context)
        resyncRequirementStore = ResyncRequirementStore(context)

        MethodChannel(messenger, CHANNEL_NAME).setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "syncConfiguration" -> handleSyncConfiguration(call, result)
            "syncLockWindows" -> handleSyncLockWindows(call, result)
            "syncBlockedApps" -> handleSyncBlockedApps(call, result)
            "requestEmergencyUnlock" -> handleRequestEmergencyUnlock(call, result)
            "requestIosAuthorization" -> result.success(true)
            "scheduleAutomation" -> handleScheduleAutomation(result)
            "consumeResyncRequired" -> result.success(resyncRequirementStore.consumeRequired())
            "getEngineDiagnostics" -> result.success(healthChecker.debugSnapshot())
            "isEngineHealthy" -> {
                val healthy = healthChecker.isHealthy()
                logger.info(
                    event = "health_check",
                    details = mapOf(
                        "healthy" to healthy,
                        "snapshot" to healthChecker.debugSnapshot().toString(),
                    ),
                )
                result.success(healthy)
            }
            else -> result.notImplemented()
        }
    }

    private fun handleSyncConfiguration(call: MethodCall, result: MethodChannel.Result) {
        val strictnessMode = call.argument<String>("strictnessMode")
        val lockBeforeMinutes = call.argument<Int>("lockBeforeMinutes")
        val lockAfterMinutes = call.argument<Int>("lockAfterMinutes")

        if (strictnessMode == null || lockBeforeMinutes == null || lockAfterMinutes == null) {
            result.error("invalid_args", "Lock configuration payload is incomplete.", null)
            return
        }

        val configuration = LockConfiguration(
            strictnessMode = strictnessMode,
            lockBeforeMinutes = lockBeforeMinutes,
            lockAfterMinutes = lockAfterMinutes,
        )

        configStore.save(configuration)
        logger.info(
            event = "sync_configuration",
            details = mapOf(
                "strictness_mode" to strictnessMode,
                "lock_before_minutes" to lockBeforeMinutes,
                "lock_after_minutes" to lockAfterMinutes,
            ),
        )
        result.success(true)
    }

    private fun handleSyncLockWindows(call: MethodCall, result: MethodChannel.Result) {
        val rawWindows = call.argument<List<Map<String, Any?>>>("windows")
        if (rawWindows == null) {
            result.error("invalid_args", "Lock windows payload is missing.", null)
            return
        }

        val windows = rawWindows.mapNotNull { map ->
            val prayerName = map["prayerName"] as? String ?: return@mapNotNull null
            val startEpochMillis = (map["startEpochMillis"] as? Number)?.toLong() ?: return@mapNotNull null
            val endEpochMillis = (map["endEpochMillis"] as? Number)?.toLong() ?: return@mapNotNull null
            LockWindow(prayerName = prayerName, startEpochMillis = startEpochMillis, endEpochMillis = endEpochMillis)
        }

        lockWindowStore.save(windows)
        resyncRequirementStore.consumeRequired()
        logger.info(
            event = "sync_lock_windows",
            details = mapOf("count" to windows.size),
        )
        result.success(true)
    }

    private fun handleSyncBlockedApps(call: MethodCall, result: MethodChannel.Result) {
        val packageNames = call.argument<List<String>>("packageNames")
        if (packageNames == null) {
            result.error("invalid_args", "Blocked app list is missing.", null)
            return
        }

        blockedAppsStore.save(packageNames)
        logger.info(
            event = "sync_blocked_apps",
            details = mapOf("count" to packageNames.size),
        )
        result.success(true)
    }

    private fun handleRequestEmergencyUnlock(call: MethodCall, result: MethodChannel.Result) {
        val seconds = call.argument<Int>("durationSeconds") ?: 30
        emergencyUnlockController.activate(seconds)
        logger.info(
            event = "request_emergency_unlock",
            details = mapOf("duration_seconds" to seconds),
        )
        result.success(true)
    }

    private fun handleScheduleAutomation(result: MethodChannel.Result) {
        scheduler.scheduleNextMidnightMaintenance()
        logger.info(event = "schedule_automation")
        result.success(true)
    }
}
