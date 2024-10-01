package com.example.fahrschul_manager

import android.os.Bundle
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Properties
import java.io.FileInputStream
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.fahrschul_manager/keys"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getGradleApplicationIDValue") {
                val applicationID = getGradleApplicationIDValue()
                if (applicationID != null) {
                    result.success(applicationID)
                } else {
                    result.error("UNAVAILABLE", "Gradle-Wert nicht verfügbar.", null)
                }
            } else {
                result.notImplemented()
            }
            if (call.method == "getGradleClientIDValue") {
                val clientID = getGradleClientIDValue()
                if (clientID != null) {
                    result.success(clientID)
                } else {
                    result.error("UNAVAILABLE", "Gradle-Wert nicht verfügbar.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getGradleApplicationIDValue(): String? {
        return BuildConfig.APPLICATION_ID
    }

    private fun getGradleClientIDValue(): String? {
        return BuildConfig.CLIENT_ID
    }
}
