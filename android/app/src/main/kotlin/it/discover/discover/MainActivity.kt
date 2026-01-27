package it.discover.discover

import android.app.ActivityManager
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val taskDescription = ActivityManager.TaskDescription.Builder()
                .setPrimaryColor(Color.WHITE)   // Colore sfondo Recents
                .build()

            setTaskDescription(taskDescription)
        } else {
            @Suppress("DEPRECATION")
            setTaskDescription(ActivityManager.TaskDescription(null, null, Color.WHITE))
        }
    }
}