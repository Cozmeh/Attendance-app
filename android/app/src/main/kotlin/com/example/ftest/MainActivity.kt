package com.example.ftest


import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.MifareClassic
import android.os.Bundle
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import io.flutter.plugin.common.MethodChannel
import java.nio.charset.Charset

class MainActivity : FlutterActivity() {
    private var nfcAdapter: NfcAdapter? = null
    private var nfcEventSink: EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val nfcChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "ams.nfc")
        val nfcEventChannel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, "ams.nfcEvent")

        nfcChannel.setMethodCallHandler { call, result ->
            if (call.method == "readBlockData") {
                val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
                val tagData = tag?.let { readBlockData(it) }
                result.success(tagData)
            } else {
                result.notImplemented()
            }
        }

        nfcEventChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventSink) {
                nfcEventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                nfcEventSink = null
            }
        })
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        if (nfcAdapter == null) {
            Toast.makeText(
                this, "NO NFC Capabilities",
                Toast.LENGTH_SHORT
            ).show()
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        resolveIntent(intent)
    }

    private fun resolveIntent(intent: Intent) {
        val action = intent.action
        if (NfcAdapter.ACTION_TAG_DISCOVERED == action ||
            NfcAdapter.ACTION_TECH_DISCOVERED == action ||
            NfcAdapter.ACTION_NDEF_DISCOVERED == action
        ) {
            val tag: Tag? = intent.getParcelableExtra(NfcAdapter.EXTRA_TAG)
            tag?.let {
                readBlockData(it)
            }
        }
    }

    private fun readBlockData(tag: Tag) {
        val mifareClassic = MifareClassic.get(tag)
        try {
            mifareClassic.connect()
            val sector = 1
            val block = 0
            val keyList = getDefaultKeys()

            for (key in keyList) {
                if (mifareClassic.authenticateSectorWithKeyA(sector, key)) {
                    val blockIndex = mifareClassic.sectorToBlock(sector) + block
                    val data = mifareClassic.readBlock(blockIndex)
                    val dataString = String(data, Charset.forName("US-ASCII"))
                    val nfcData = dataString.subSequence(0,8)
                    nfcEventSink?.success(nfcData)
                    break
                }
            }
        } catch (e: Exception) {
            e.printStackTrace()
        } finally {
            try {
                mifareClassic.close()
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
    }

    private fun getDefaultKeys(): List<ByteArray> {
        return listOf(
            byteArrayOf(
                0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(), 0xFF.toByte(),
                0xFF.toByte(), 0xFF.toByte()
            ),
            byteArrayOf(
                0xA0.toByte(), 0xA1.toByte(), 0xA2.toByte(), 0xA3.toByte(),
                0xA4.toByte(), 0xA5.toByte()
            ),
            byteArrayOf(
                0xB0.toByte(), 0xB1.toByte(), 0xB2.toByte(), 0xB3.toByte(),
                0xB4.toByte(), 0xB5.toByte()
            ),
            byteArrayOf(
                0xC0.toByte(), 0xC1.toByte(), 0xC2.toByte(), 0xC3.toByte(),
                0xC4.toByte(), 0xC5.toByte()
            ),
            byteArrayOf(
                0xD0.toByte(), 0xD1.toByte(), 0xD2.toByte(), 0xD3.toByte(),
                0xD4.toByte(), 0xD5.toByte()
            ),
            byteArrayOf(
                0x00.toByte(), 0x00.toByte(), 0x00.toByte(), 0x00.toByte(),
                0x00.toByte(), 0x00.toByte()
            ),
            byteArrayOf(
                0x01.toByte(), 0x01.toByte(), 0x01.toByte(), 0x01.toByte(),
                0x01.toByte(), 0x01.toByte()
            ),
            byteArrayOf(
                0x4D.toByte(), 0x3A.toByte(), 0x99.toByte(), 0xC3.toByte(),
                0x51.toByte(), 0xDD.toByte()
            ),
            byteArrayOf(
                0xA0.toByte(), 0xB0.toByte(), 0xC0.toByte(), 0xD0.toByte(),
                0xE0.toByte(), 0xF0.toByte()
            )
        )
    }
}
