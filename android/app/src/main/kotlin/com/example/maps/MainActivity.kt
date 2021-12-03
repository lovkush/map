package com.example.maps

import android.Manifest
import android.content.*
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.os.Bundle
import android.os.PersistableBundle
import android.provider.Settings
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.example.maps.service.LocationService
import com.google.firebase.database.ktx.database
import com.google.firebase.ktx.Firebase
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel


class MainActivity:FlutterActivity(){
    companion object{
        const val PERMISSION_ID = 1
    }
    private val CHANNEL = "samples.flutter.dev/location"




    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

//
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            // Note: this method is invoked on the main thread.
                call, result ->
            if (call.method == "startLocation") {
                if (!checkPermission()) {
                    requestPermission()
                }else{
                    if (isLocationEnabled())
                    {
                        Log.d("TAG", "configureFlutterEngine: true")

                        val path :String? = call.argument("path")
                        if (path != null) {
                            Log.d("TAG", "start Service: ")
                            LocationService.startService(this@MainActivity,path)
                            result.success(1)
                        }
                    }else{
                        result.success(2)
                    }
                }

//            }else if(call.method == "startLocation"){
//               // LocationService.stopService(this@MainActivity,path)
//                result.success(3)
            }
              else {
                result.notImplemented()
            }
        }


    }


    private fun checkPermission(): Boolean {
        val result = ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.ACCESS_FINE_LOCATION)
        val result1 = ContextCompat.checkSelfPermission(applicationContext, Manifest.permission.ACCESS_COARSE_LOCATION)
        return result == PackageManager.PERMISSION_GRANTED && result1 == PackageManager.PERMISSION_GRANTED
    }

    private fun requestPermission() {
        ActivityCompat.requestPermissions(this,
            arrayOf(Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION),
            PERMISSION_ID
        )
    }


    // If everything is alright then
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String?>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == PERMISSION_ID) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                if (isLocationEnabled())
                {
                    ContextCompat.startForegroundService(this, Intent(this, LocationService::class.java))
                }
            }
        }
    }


    private fun isLocationEnabled(): Boolean {
        val locationManager = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val gpsEnabled =
            locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) || locationManager.isProviderEnabled(
                LocationManager.NETWORK_PROVIDER
            )

        if (!gpsEnabled) {
            showAlertDialog(
                "Gps not enabled",
                message = "Please enable location service",
                posBtnText = "Enable",
                negBtnText = "Cancel",
                callback = {
                    Toast.makeText(this, "Please turn on" + " your location...", Toast.LENGTH_LONG)
                        .show()
                    val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
                    startActivity(intent)
                }
            )
        }

        return gpsEnabled
    }


}
