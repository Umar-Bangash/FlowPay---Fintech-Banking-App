package com.example.flow_pay

import android.content.Context
import android.util.Log
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_STRONG
import androidx.biometric.BiometricManager.Authenticators.BIOMETRIC_WEAK
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.plugin.common.MethodChannel

object BiometricHelper {

    private const val TAG = "BiometricHelper"

    private fun getBestAuthenticator(context: Context): Int {
        val manager = BiometricManager.from(context)
        if (manager.canAuthenticate(BIOMETRIC_STRONG) == BiometricManager.BIOMETRIC_SUCCESS) {
            Log.d(TAG, "Using BIOMETRIC_STRONG")
            return BIOMETRIC_STRONG
        }
        if (manager.canAuthenticate(BIOMETRIC_WEAK) == BiometricManager.BIOMETRIC_SUCCESS) {
            Log.d(TAG, "Using BIOMETRIC_WEAK")
            return BIOMETRIC_WEAK
        }
        Log.d(TAG, "No biometric available")
        return -1
    }

    fun canAuthenticate(context: Context): Boolean {
        val authenticator = getBestAuthenticator(context)
        Log.d(TAG, "canAuthenticate: ${authenticator != -1}")
        return authenticator != -1
    }

    fun authenticate(activity: FragmentActivity, result: MethodChannel.Result) {
        val authenticator = getBestAuthenticator(activity)

        if (authenticator == -1) {
            Log.d(TAG, "No biometric available — returning false")
            result.success(false)
            return
        }

        Log.d(TAG, "Showing prompt with authenticator: $authenticator")

        val executor = ContextCompat.getMainExecutor(activity)

        val callback = object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(authResult: BiometricPrompt.AuthenticationResult) {
                Log.d(TAG, "onAuthenticationSucceeded")
                result.success(true)
            }

            override fun onAuthenticationFailed() {
                Log.d(TAG, "onAuthenticationFailed — waiting for retry")
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                Log.d(TAG, "onAuthenticationError: $errorCode $errString")
                result.success(false)
            }
        }

        val prompt = BiometricPrompt(activity, executor, callback)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle("Fingerprint Required")
            .setSubtitle("Touch the fingerprint sensor")
            .setAllowedAuthenticators(authenticator)
            .setNegativeButtonText("Cancel")
            .build()

        prompt.authenticate(promptInfo)
    }
}