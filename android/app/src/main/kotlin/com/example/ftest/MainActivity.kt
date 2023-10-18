package com.example.ftest

import android.content.Intent
import android.nfc.NfcAdapter
import android.util.Log
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result


class MainActivity : FlutterActivity(){
    private var nfcEventSink: EventChannel.EventSink? = null
    private var eventID: String? = null
    private var user:String? = null
    private var openForAll : Boolean? = false


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val nfcChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ams.nfc")
        val nfcEventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "ams.nfcEvent")

        nfcChannel.setMethodCallHandler { call: MethodCall, result: Result ->
            if (call.method == "startNFCScan") {
                eventID = call.argument<String>("eventID")
                user = call.argument<String>("user")
                openForAll = call.argument<Boolean>("openForAll")
                Log.d("LOG", openForAll.toString())
                if (eventID != null) {
                    startNFCScan()
                } else {
                    result.error("MISSING_EVENT_ID", "EventID is missing", null)
                }
            }
        }

        nfcEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink) {
                nfcEventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                nfcEventSink = null
            }
        })
    }

    private fun startNFCScan() {
        val nfcScanIntent = Intent(this, NFCActivity::class.java)
        nfcScanIntent.putExtra("eventID", eventID)
        nfcScanIntent.putExtra("user", user)
        nfcScanIntent.putExtra("openForAll", openForAll)
        startActivity(nfcScanIntent)
    }

}