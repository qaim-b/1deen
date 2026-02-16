package com.example.app

import android.app.Activity
import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.os.CountDownTimer
import android.os.Handler
import android.os.Looper
import android.view.Gravity
import android.view.WindowManager
import android.widget.Button
import android.widget.LinearLayout
import android.widget.TextView
import kotlin.math.max

class LockOverlayActivity : Activity() {
    private var timer: CountDownTimer? = null
    private val relaunchHandler = Handler(Looper.getMainLooper())
    private lateinit var stateEvaluator: GuardStateEvaluator
    private lateinit var logger: LockEventLogger
    private var allowClose = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        stateEvaluator = GuardStateEvaluator(applicationContext)
        logger = LockEventLogger(applicationContext)

        window.addFlags(
            WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or
                WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON or
                WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON,
        )

        val prayerName = intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "Prayer"
        val endEpochMillis = intent.getLongExtra(EXTRA_END_EPOCH_MILLIS, System.currentTimeMillis())
        val strictnessMode = intent.getStringExtra(EXTRA_STRICTNESS_MODE) ?: "soft"

        logger.info(
            event = "overlay_opened",
            details = mapOf("prayer" to prayerName, "strictness" to strictnessMode),
        )

        val root = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setBackgroundColor(Color.parseColor("#0B0D10"))
            setPadding(48, 120, 48, 80)
            gravity = Gravity.CENTER_HORIZONTAL
        }

        val title = TextView(this).apply {
            text = "1Deen Guard Active"
            textSize = 28f
            setTextColor(Color.WHITE)
            gravity = Gravity.CENTER
        }

        val verse = TextView(this).apply {
            text = "And establish prayer for My remembrance. (20:14)"
            textSize = 16f
            setTextColor(Color.parseColor("#D6DFE8"))
            gravity = Gravity.CENTER
        }

        val countdown = TextView(this).apply {
            textSize = 18f
            setTextColor(Color.parseColor("#F7C470"))
            gravity = Gravity.CENTER
        }

        val subtitle = TextView(this).apply {
            text = "$prayerName window is active"
            textSize = 14f
            setTextColor(Color.parseColor("#AAB6C2"))
            gravity = Gravity.CENTER
        }

        val prayedButton = Button(this).apply {
            text = "I have prayed"
            setOnClickListener {
                allowClose = true
                EmergencyUnlockController(applicationContext).activate(durationSeconds = 600)
                logger.info(event = "overlay_prayed_unlock")
                finish()
            }
        }

        val emergencyButton = Button(this).apply {
            text = if (strictnessMode == "strict") "Emergency unlock (30s)" else "Temporary unlock (30s)"
            setOnClickListener {
                allowClose = true
                EmergencyUnlockController(applicationContext).activate(durationSeconds = 30)
                logger.info(event = "overlay_emergency_unlock", details = mapOf("seconds" to 30))
                finish()
            }
        }

        root.addView(title)
        root.addView(space())
        root.addView(verse)
        root.addView(space())
        root.addView(subtitle)
        root.addView(space())
        root.addView(countdown)
        root.addView(space(size = 42))
        root.addView(prayedButton)
        root.addView(space())
        root.addView(emergencyButton)

        setContentView(root)
        startCountdown(countdown, endEpochMillis)
    }

    override fun onBackPressed() {
        if (stateEvaluator.shouldHoldOverlay()) {
            logger.warn(event = "overlay_back_blocked")
            return
        }
        super.onBackPressed()
    }

    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (!allowClose && stateEvaluator.shouldHoldOverlay()) {
            logger.warn(event = "overlay_user_leave_hint_relaunch")
            relaunchOverlaySoon()
        }
    }

    override fun onPause() {
        super.onPause()
        if (!allowClose && stateEvaluator.shouldHoldOverlay()) {
            logger.warn(event = "overlay_pause_relaunch")
            relaunchOverlaySoon()
        }
    }

    override fun onMultiWindowModeChanged(isInMultiWindowMode: Boolean) {
        super.onMultiWindowModeChanged(isInMultiWindowMode)
        if (isInMultiWindowMode && stateEvaluator.shouldHoldOverlay()) {
            logger.warn(event = "overlay_multiwindow_relaunch")
            relaunchOverlaySoon()
        }
    }

    override fun onDestroy() {
        timer?.cancel()
        relaunchHandler.removeCallbacksAndMessages(null)
        super.onDestroy()
    }

    private fun startCountdown(countdownView: TextView, endEpochMillis: Long) {
        val remainingMillis = max(endEpochMillis - System.currentTimeMillis(), 0L)

        timer = object : CountDownTimer(remainingMillis, 1000L) {
            override fun onTick(millisUntilFinished: Long) {
                val totalSeconds = millisUntilFinished / 1000L
                val minutes = totalSeconds / 60L
                val seconds = totalSeconds % 60L
                countdownView.text = "Time left ${minutes}m ${seconds}s"
            }

            override fun onFinish() {
                countdownView.text = "Window ended"
                allowClose = true
                finish()
            }
        }.start()
    }

    private fun relaunchOverlaySoon() {
        relaunchHandler.postDelayed({
            if (allowClose || !stateEvaluator.shouldHoldOverlay()) {
                return@postDelayed
            }

            val relaunchIntent = Intent(this, LockOverlayActivity::class.java).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                putExtra(EXTRA_PRAYER_NAME, intent.getStringExtra(EXTRA_PRAYER_NAME) ?: "Prayer")
                putExtra(EXTRA_END_EPOCH_MILLIS, intent.getLongExtra(EXTRA_END_EPOCH_MILLIS, System.currentTimeMillis()))
                putExtra(EXTRA_STRICTNESS_MODE, intent.getStringExtra(EXTRA_STRICTNESS_MODE) ?: "soft")
            }
            startActivity(relaunchIntent)
        }, RELAUNCH_DELAY_MILLIS)
    }

    private fun space(size: Int = 18): TextView {
        return TextView(this).apply {
            text = ""
            height = size
        }
    }

    companion object {
        const val EXTRA_PRAYER_NAME = "extra_prayer_name"
        const val EXTRA_END_EPOCH_MILLIS = "extra_end_epoch_millis"
        const val EXTRA_STRICTNESS_MODE = "extra_strictness_mode"
        private const val RELAUNCH_DELAY_MILLIS = 150L
    }
}
