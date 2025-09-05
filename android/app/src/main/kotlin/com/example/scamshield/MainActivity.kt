package com.example.scamshield

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.channel.scamshield"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (intent?.action == Intent.ACTION_PROCESS_TEXT) {
            val text = intent.getCharSequenceExtra(Intent.EXTRA_PROCESS_TEXT)
            MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("processText", text.toString())
        }
    }
}