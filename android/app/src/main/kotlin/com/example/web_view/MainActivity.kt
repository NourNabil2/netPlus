package com.example.web_view

import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.net.NetworkInterface

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.device_info"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAndroidId" -> result.success(getAndroidId())
                "getMacAddress" -> result.success(getMacAddress())
                else -> result.notImplemented()
            }
        }
    }

    private fun getAndroidId(): String {
        return Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
    }

    private fun getMacAddress(): String {
        return try {
            val interfaces = NetworkInterface.getNetworkInterfaces()
            for (intf in interfaces) {
                if (intf.name.equals("wlan0", ignoreCase = true)) {
                    val macBytes = intf.hardwareAddress ?: return "02:00:00:00:00:00"
                    return macBytes.joinToString(":") { String.format("%02X", it) }
                }
            }
            "02:00:00:00:00:00"
        } catch (ex: Exception) {
            ex.printStackTrace()
            "03:00:00:00:00:00"
        }
    }
}
