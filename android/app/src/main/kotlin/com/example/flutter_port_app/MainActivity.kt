package com.example.flutter_port_app

import android.os.Bundle
import android.util.Log
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.mk.service.ifpd.midware.manager.app.imp.AppSystem
import com.mk.service.ifpd.midware.manager.app.imp.AppSettings

class MainActivity : FlutterActivity() {

    private val CHANNEL = "port_control"
    private lateinit var appSystem: AppSystem
    private lateinit var appSettings: AppSettings

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        appSystem = AppSystem.getInstance(applicationContext)
        appSettings = AppSettings.getInstance(applicationContext)

        appSystem.connectService()
        appSettings.connectService()

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                        "shutdownSystem" -> {
                            appSystem.shutdown()
                            result.success("Shutdown command sent")
                        }

                        "openHDMI" -> {
                            val index = call.argument<Int>("index") ?: 0
                            appSystem.openHDMI(index)
                            result.success("HDMI opened for index $index")
                        }

                        "closeHDMI" -> {
                            appSystem.closeHDMI()
                            result.success("HDMI closed")
                        }

                        "getHDMIStatus" -> {
                            val index = call.argument<Int>("index") ?: 0
                            val status = appSystem.getHDMIConnectedStatus(index)
                            result.success(status) 
                        }

                        "setDelayPowerOn" -> {
                            var mins = call.argument<Int>("mins") ?: 0
                            appSystem.setDelayPowerOn(mins)
                        }

                        "turnOff" -> {
                            appSystem.turnOff()
                            result.success("System turned off")
                        }

                        "isInteractive" -> {
                            val interactive = appSystem.isInteractive()
                            result.success(interactive) 
                        }

                        "setBackLight" -> {
                            val value = call.argument<Int>("value") ?: 0
                            appSettings.setBackLight(value)
                        }


                        "startScreenCap" -> {
                        val fileName = call.argument<String>("fileName") ?: ""
                        val file = java.io.File(fileName)

                        file.parentFile?.mkdirs()

                        Thread {
                            val resultCode = appSystem.startScreenCap(fileName)
                            runOnUiThread {
                                result.success(resultCode)
                            }
                        }.start()
                        }

                        else -> result.notImplemented()
                    }
        }
    }
}
