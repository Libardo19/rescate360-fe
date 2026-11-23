package com.rescate360.rescate

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.wifi.WifiManager
import android.os.Build

class MainActivity : FlutterActivity() {
    private val solicitudBluetooth = 3601
    private var respuestaBluetooth: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "co.rescate360/relevo")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "versionAndroid" -> result.success(Build.VERSION.SDK_INT)
                    "activarBluetooth" -> solicitarBluetooth(result)
                    "estadoRadios" -> {
                        try {
                            val bluetooth = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
                            val wifi = applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager
                            result.success(mapOf(
                                "bluetooth" to (bluetooth.adapter?.isEnabled == true),
                                "wifi" to wifi.isWifiEnabled
                            ))
                        } catch (error: SecurityException) {
                            result.error("PERMISO_RADIOS", "Falta permiso de dispositivos cercanos", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun solicitarBluetooth(result: MethodChannel.Result) {
        if (respuestaBluetooth != null) {
            result.error("BLUETOOTH_EN_CURSO", "Ya hay una solicitud de Bluetooth abierta", null)
            return
        }
        try {
            val manager = getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
            val adapter = manager.adapter
            if (adapter == null) {
                result.error("BLUETOOTH_NO_DISPONIBLE", "Este teléfono no dispone de Bluetooth", null)
                return
            }
            if (adapter.isEnabled) {
                result.success(true)
                return
            }
            respuestaBluetooth = result
            startActivityForResult(Intent(BluetoothAdapter.ACTION_REQUEST_ENABLE), solicitudBluetooth)
        } catch (error: SecurityException) {
            respuestaBluetooth = null
            result.error("PERMISO_BLUETOOTH", "Falta permiso para conectar por Bluetooth", null)
        } catch (error: ActivityNotFoundException) {
            respuestaBluetooth = null
            result.error("DIALOGO_BLUETOOTH", "Android no pudo abrir la activación de Bluetooth", null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == solicitudBluetooth) {
            val respuesta = respuestaBluetooth
            respuestaBluetooth = null
            respuesta?.success(resultCode == Activity.RESULT_OK)
        }
    }

    override fun onDestroy() {
        val respuesta = respuestaBluetooth
        respuestaBluetooth = null
        respuesta?.success(false)
        super.onDestroy()
    }
}
