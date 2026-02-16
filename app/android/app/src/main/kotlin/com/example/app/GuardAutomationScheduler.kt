package com.example.app

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import java.util.Calendar

class GuardAutomationScheduler(private val context: Context) {
    fun scheduleNextMidnightMaintenance() {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val triggerAt = nextMidnightTriggerMillis()
        val pendingIntent = maintenancePendingIntent()

        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            triggerAt,
            pendingIntent,
        )

        LockEventLogger(context).info(
            event = "automation_scheduled",
            details = mapOf("trigger_at" to triggerAt),
        )
    }

    private fun nextMidnightTriggerMillis(): Long {
        val calendar = Calendar.getInstance().apply {
            add(Calendar.DAY_OF_YEAR, 1)
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        return calendar.timeInMillis
    }

    private fun maintenancePendingIntent(): PendingIntent {
        val intent = Intent(context, GuardMaintenanceReceiver::class.java).apply {
            action = GuardMaintenanceReceiver.ACTION_MIDNIGHT_MAINTENANCE
        }

        return PendingIntent.getBroadcast(
            context,
            REQUEST_CODE_MAINTENANCE,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
    }

    private companion object {
        private const val REQUEST_CODE_MAINTENANCE = 1001
    }
}
