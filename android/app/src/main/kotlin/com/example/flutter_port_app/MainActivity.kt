package com.example.flutter_port_app

import android.os.Bundle
import android.util.Log
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import com.mk.service.ifpd.midware.manager.app.imp.AppSystem
import com.mk.service.ifpd.midware.manager.app.imp.AppSettings
import com.mk.service.ifpd.app.midware.DisplayOrientation
import android.os.RemoteException
// import com.mk.service.ifpd.midware.manager.app.imp.AutoRebootInfo
// import com.mk.service.ifpd.midware.AutoRebootInfo


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

                                // "setSystemAutoReboot" -> {
                                //     try {
                                //         val status = call.argument<Int>("status") ?: 0
                                //         val time = call.argument<String>("time") ?: "00:00"
                                //         val success = appSystem.setSystemAutoReboot(AutoRebootInfo(status, time))
                                //         result.success(success)
                                //     } catch (e: Exception) {
                                //         result.error("AUTO_REBOOT_ERROR", "Failed to set auto reboot", null)
                                //     }
                                // }

                //                 "setSystemAutoReboot" -> {
                //     try {
                //         val status = call.argument<Int>("status") ?: 0
                //         val time = call.argument<String>("time") ?: "00:00"
                        
                        
                //         val possiblePackages = listOf(
                //             "com.mk.service.ifpd.midware.manager.app.imp.AutoRebootInfo",
                //             "com.mk.service.ifpd.midware.AutoRebootInfo",
                //             "com.mk.service.ifpd.AutoRebootInfo"
                //         )
                        
                //         var autoRebootInfo: Any? = null
                //         var found = false
                        
                //         for (pkg in possiblePackages) {
                //             try {
                //                 val clazz = Class.forName(pkg)
                //                 val constructor = clazz.getConstructor(Int::class.java, String::class.java)
                //                 autoRebootInfo = constructor.newInstance(status, time)
                //                 found = true
                //                 break
                //             } catch (e: ClassNotFoundException) {
                //                 continue
                //             }
                //         }
                        
                //         if (!found) {
                //             result.error(
                //                 "CLASS_NOT_FOUND", 
                //                 "AutoRebootInfo class not found in any of: $possiblePackages", 
                //                 null
                //             )
                //             return@setMethodCallHandler
                //         }
                        
                //         // Find and call setSystemAutoReboot method
                //         val method = appSystem.javaClass.methods.find { 
                //             it.name == "setSystemAutoReboot" && 
                //             it.parameterTypes.size == 1
                //         }
                        
                //         if (method == null) {
                //             result.error(
                //                 "METHOD_NOT_FOUND", 
                //                 "setSystemAutoReboot method not found in AppSystem", 
                //                 null
                //             )
                //             return@setMethodCallHandler
                //         }
                        
                //         val success = method.invoke(appSystem, autoRebootInfo) as Boolean
                //         result.success(success)
                        
                //     } catch (e: Exception) {
                //         Log.e("MainActivity", "Auto reboot error", e)
                //         result.error(
                //             "AUTO_REBOOT_ERROR", 
                //             "Failed to set auto reboot: ${e.javaClass.simpleName}: ${e.message}", 
                //             null
                //         )
                //     }
                // }


                        else -> result.notImplemented()
                    }
        }
    }
}
