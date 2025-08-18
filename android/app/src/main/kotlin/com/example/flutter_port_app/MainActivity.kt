package com.example.flutter_port_app

import android.os.Bundle
import android.util.Log
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.mk.service.ifpd.midware.manager.app.imp.AppSystem
import com.mk.service.ifpd.midware.manager.app.imp.AppSettings
import com.mk.service.ifpd.midware.manager.app.imp.AppSafety
import com.mk.service.ifpd.app.midware.SafetyType
import com.mk.service.ifpd.app.midware.DisplayOrientation
import android.os.RemoteException


class MainActivity : FlutterActivity() {

    private val CHANNEL = "port_control"
    private lateinit var appSystem: AppSystem
    private lateinit var appSettings: AppSettings
    private lateinit var appSafety: AppSafety
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        appSystem = AppSystem.getInstance(applicationContext)
        appSettings = AppSettings.getInstance(applicationContext)
        appSafety = AppSafety.getInstance(applicationContext)  

        appSystem.connectService()
        appSettings.connectService()
        appSafety.connectService()

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

                        "getHDMIMode" -> {
                            val mode = appSettings.getHDMIMode()
                            result.success(mode)
                        }

                        
                        "setHdmiMode" -> {
                                try {
                                    val status = call.argument<Boolean>("status") ?: false
                                    appSettings.setHdmiMode(status)
                                    result.success(true)
                                } catch (e: RemoteException) {
                                    result.error("REMOTE_ERROR", "Service communication failed", null)
                                } catch (e: Exception) {
                                    result.error("GENERIC_ERROR", e.message, null)
                                }
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

                            if (file.parentFile?.exists() == false) {
                                file.parentFile?.mkdirs()
                            }
                            val resultCode = appSystem.startScreenCap(fileName)
                        }

                        "setDisplayOrientation" -> {
                            val angle = call.argument<Int>("angle") ?: 0
                            val orientation = when (angle) {
                                0 -> DisplayOrientation.ROTATION_0
                                90 -> DisplayOrientation.ROTATION_90
                                180 -> DisplayOrientation.ROTATION_180
                                270 -> DisplayOrientation.ROTATION_270
                                else -> DisplayOrientation.ROTATION_0 
                            }
                            appSystem.setDisplayOrientation(orientation)
                        }

                        "getSystemVoice" -> {
                            val volume = appSystem.getSystemVoice()
                            result.success(volume)
                        }
                            
                        "setSystemVoice" -> {
                            val voice = call.argument<Int>("voice") ?: 50
                            if (voice in 0..100) {
                                appSystem.setSystemVoice(voice)
                                result.success("Volume set to $voice")
                            } else {
                                result.error("INVALID_VOLUME", "Volume must be 0-100", null)
                            }
                        }
                                
                        "mute" -> {
                            appSystem.mute()
                            result.success("Device muted")
                        }
                                
                        "unMute" -> {
                            appSystem.unMute()
                            result.success("Device unmuted")
                        }

                        "reboot" -> {
                            appSystem.reboot()
                            result.success("Reboot command sent")
                        }

                        "getMacAddress" -> {
                            try {
                                val macAddress = appSystem.macAddress
                                result.success(macAddress)
                            } catch (e: Exception) {
                                result.error("MAC_ADDRESS_ERROR", "Failed to get MAC address", null)
                            }
                        }

                        "getDeviceId" -> {
                            try {
                                val deviceId = appSystem.deviceId
                                result.success(deviceId)
                            } catch (e: Exception) {
                                result.error("DEVICE_ID_ERROR", "Failed to get device ID", null)
                            }
                        }

                        "getSN" -> {
                            try {
                                Log.d("MainActivity", "Attempting to get SN...")
                                val sn = appSystem.getSN()
                                Log.d("MainActivity", "Got SN: $sn")
                                if (sn.isNullOrEmpty()) {
                                    Log.w("MainActivity", "Received empty SN")
                                    result.error("EMPTY_SN", "Serial number is empty", null)
                                } else {
                                    result.success(sn)
                                }
                            } catch (e: Exception) {
                                Log.e("MainActivity", "Error getting SN", e)
                                result.error("SN_ERROR", "Failed to get serial number: ${e.message}", e.toString())
                            }
                        }

                        "getClientType" -> {
                            try {
                                val clientType = appSystem.clientType
                                result.success(clientType)
                            } catch (e: Exception) {
                                result.error("CLIENT_TYPE_ERROR", "Failed to get client type", null)
                            }
                        }

                        "getAppId" -> {
                            try {
                                val appId = appSystem.appId
                                result.success(appId)
                            } catch (e: Exception) {
                                result.error("APP_ID_ERROR", "Failed to get app ID", null)
                            }
                        }

                        "getHDMI" -> {

                            val lockType = SafetyType.MK_SAFETY_IOC_GET_HDMI_LOCK_TYPE
                            val value = appSafety.getSafetyLockStatus(lockType)
                            Log.d("MainActivity", "Attempting to $value")
                            result.success("HDMI opened for index $value")
                        }

                        "toggleHDMI" -> {
                            val status = call.argument<Boolean>("value") ?: true
                            val lockType = SafetyType.MK_SAFETY_IOC_SET_HDMI_LOCK_TYPE
                            val value = appSafety.setSafetyLockStatus(lockType,status)
                            Log.d("MainActivity", "Attempting to $value")
                            result.success("HDMI opened for index $value")
                        }

                        "toggleUSB" -> {
                            val status = call.argument<Boolean>("value") ?: true
                            val lockType = SafetyType.MK_SAFETY_IOC_SET_USB_LOCK_TYPE
                            val value = appSafety.setSafetyLockStatus(lockType,status)
                            Log.d("MainActivity", "Attempting to $value")
                            result.success("USB opened for index $value")
                        }

                        else -> result.notImplemented()
                    }
        }
    }
}
