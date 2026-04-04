package com.hjuagom.aegis

import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.aegis.app/monitor"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when(call.method) {
                "checkUsagePermission" -> {
                    result.success(hasUsageStatsPermission())
                }
                "requestUsagePermission" -> {
                    try {
                        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        intent.data = Uri.parse("package:$packageName")
                        startActivity(intent)
                        result.success(true)
                    } catch (e: Exception) {
                        val fallbackIntent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
                        fallbackIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        startActivity(fallbackIntent)
                        result.success(true)
                    }
                }
                "checkOverlayPermission" -> {
                    result.success(Settings.canDrawOverlays(this))
                }
                "requestOverlayPermission" -> {
                    val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                    intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    startActivity(intent)
                    result.success(null)
                }
                "getForegroundApp" -> {
                    if (!hasUsageStatsPermission()) {
                        result.error("NO_PERMISSION", "Permiso de uso no concedido", null)
                        return@setMethodCallHandler
                    }
                    
                    val packageName = getForegroundPackageName()
                    if (packageName != null) {
                        result.success(packageName)
                    } else {
                        result.error("UNAVAILABLE", "No foreground app detected", null)
                    }
                }
                "bringToForeground" -> {
                    val intent = Intent(context, MainActivity::class.java).apply {
                        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                        addFlags(Intent.FLAG_ACTIVITY_REORDER_TO_FRONT)
                        addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                        addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    }
                    startActivity(intent)
                    result.success(null)
                }
                "sendToBackground" -> {
                    moveTaskToBack(true)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = appOps.unsafeCheckOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS,
            Process.myUid(),
            packageName
        )
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun getForegroundPackageName(): String? {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 1000 * 60
        
        val usageEvents = usageStatsManager.queryEvents(startTime, endTime)
        val event = UsageEvents.Event()
        var currentForegroundPackage: String? = null
        
        while (usageEvents.hasNextEvent()) {
            usageEvents.getNextEvent(event)
            if (event.eventType == UsageEvents.Event.ACTIVITY_RESUMED) {
                currentForegroundPackage = event.packageName
            }
        }
        
        return currentForegroundPackage
    }
}
