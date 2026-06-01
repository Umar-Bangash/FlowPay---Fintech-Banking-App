/*
    I Modified this File for Fingeprint Setup !!
*/

package com.example.flow_pay

import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.example.flow_pay/biometric"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {

                // ── Check if fingerprint is available ──
                "canAuthenticate" -> {
                    result.success(BiometricHelper.canAuthenticate(this))
                }

                // ── Show fingerprint-only prompt ──
                "authenticate" -> {
                    BiometricHelper.authenticate(this, result)
                }

                else -> result.notImplemented()
            }
        }
    }
}