package com.example.app

import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        LockEngineMethodChannel.register(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
            context = applicationContext,
        )
        SubscriptionBillingMethodChannel.register(
            messenger = flutterEngine.dartExecutor.binaryMessenger,
            activity = this,
        )
    }
}
