package com.example.maps.service

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.location.Location
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.firebase.database.FirebaseDatabase
import java.util.*

/**
 * @author: Shashi
 * @date : 30-11-2021
 * @description : Service for location
 **/
class LocationService  : Service() {

    companion object{
        const val NOTIFICATION_CHANNEL_ID = "LoccaID"
        fun startService(context: Context, path: String) {
            val intent = Intent(context, LocationService::class.java).apply {
                putExtra("Path", path)
            }
            ContextCompat.startForegroundService(context, intent)
        }
    }

    private var isServiceStarted = false
    private var path : String = ""
    override fun onCreate() {
        super.onCreate()
        Log.d("TAG", "onCreate: ")
//        var intent =Intent()
//        var bundle : Bundle?=intent.extras
//         path = bundle!!.getString("value").toString() // 1
        isServiceStarted = true
        val builder: NotificationCompat.Builder =
            NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
                .setOngoing(true)
                .setContentText("Locca is running..")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val notificationManager: NotificationManager =
                getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            val notificationChannel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID,
                NOTIFICATION_CHANNEL_ID, NotificationManager.IMPORTANCE_LOW
            )
            notificationChannel.description = "Notification is running"
            notificationChannel.setSound(null, null)
            notificationManager.createNotificationChannel(notificationChannel)
            startForeground(1, builder.build())
        }
    }

    override fun onStartCommand(intent: Intent, flags: Int, startId: Int): Int {
        val timer = Timer()

        path = intent.getStringExtra("Path").toString()

        LocationHelper().startListeningUserLocation(
            this, object : MyLocationListener {
                override fun onLocationChanged(location: Location?) {

                    //Here we will get the location
                    FirebaseDatabase.getInstance().reference.child(path).setValue(location?.latitude)
                    Log.d("LocationTAG:","Location is:${location?.latitude}, ${location?.longitude}")
                }
            })
        return START_STICKY
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }

    override fun onDestroy() {
        super.onDestroy()
        isServiceStarted = false
    }
}