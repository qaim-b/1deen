package com.example.app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class GuardMaintenanceReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent?) {
        val action = intent?.action ?: return
        val logger = LockEventLogger(context)
        val heartbeat = GuardHeartbeatStore(context)
        val resyncStore = ResyncRequirementStore(context)
        val scheduler = GuardAutomationScheduler(context)

        heartbeat.beat(reason = "maintenance:$action")

        when (action) {
            ACTION_MIDNIGHT_MAINTENANCE -> {
                resyncStore.markRequired(reason = "midnight_alarm")
                scheduler.scheduleNextMidnightMaintenance()
                logger.info(event = "maintenance_midnight", details = mapOf("resync_required" to true))
            }
            Intent.ACTION_TIMEZONE_CHANGED,
            Intent.ACTION_TIME_CHANGED,
            Intent.ACTION_DATE_CHANGED,
            Intent.ACTION_BOOT_COMPLETED,
            Intent.ACTION_LOCKED_BOOT_COMPLETED,
            Intent.ACTION_MY_PACKAGE_REPLACED,
            -> {
                resyncStore.markRequired(reason = "system_action:$action")
                scheduler.scheduleNextMidnightMaintenance()
                logger.info(event = "maintenance_system_action", details = mapOf("action" to action))
            }
        }
    }

    companion object {
        const val ACTION_MIDNIGHT_MAINTENANCE = "com.example.app.ACTION_MIDNIGHT_MAINTENANCE"
    }
}
