package com.example.ftest


import androidx.appcompat.widget.Toolbar
import androidx.appcompat.app.AppCompatActivity
import android.annotation.SuppressLint
import android.app.PendingIntent
import android.content.Intent
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.MifareClassic
import android.os.Bundle
import android.view.View
import android.os.Parcelable
import android.util.Log
import android.widget.Button
import android.widget.EditText
import android.widget.ImageView
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.google.android.material.floatingactionbutton.ExtendedFloatingActionButton
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.SetOptions
import io.flutter.plugins.firebase.auth.Constants.TAG
import java.io.IOException
import java.nio.charset.Charset
import com.bumptech.glide.Glide
import com.bumptech.glide.load.resource.gif.GifDrawable


class NFCActivity : AppCompatActivity() {
    // Initialize attributes
    private var nfcAdapter: NfcAdapter? = null
    private var pendingIntent: PendingIntent? = null
    private var eventID: String? = null
    private var user:String? = null
    private var openForAll : Boolean? = false
    private lateinit var adapter: RollNumberAdapter
    private lateinit var firestore:FirebaseFirestore
    private lateinit var rollNumberList: MutableList<String>
    private lateinit var rollNumberStatusMap: Map<String, Map<String, Any>>
    private lateinit var recyclerView: RecyclerView
    private lateinit var noParticipantsView: View


    @SuppressLint("MissingInflatedId", "WrongConstant")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_nfcactivity)

        rollNumberList = mutableListOf()

        eventID = intent.getStringExtra("eventID")
        user = intent.getStringExtra("user")
        openForAll = intent.getBooleanExtra("openForAll", false)
        // Initialize NfcAdapter
        nfcAdapter = NfcAdapter.getDefaultAdapter(this)
        // If no NfcAdapter, display that the device has no NFC
        if (nfcAdapter == null) {
            Toast.makeText(
                this, "NFC Not Available on Device",
                Toast.LENGTH_SHORT
            ).show()
            finish()
        }

        if (nfcAdapter?.isEnabled == false) {
            val intent = Intent(android.provider.Settings.ACTION_NFC_SETTINGS)
            startActivity(intent)
        }

        val toolbar = findViewById<Toolbar>(R.id.toolbar)
        setSupportActionBar(toolbar)
        supportActionBar?.setDisplayShowTitleEnabled(false)
        val imageView = findViewById<ImageView>(R.id.imageView)
        Glide.with(this)
            .asGif() // Specify that you are loading a GIF
            .load(R.drawable.nfc) // Replace with the resource ID of your GIF
            .into(imageView)
        val back = findViewById<ImageView>(R.id.backButton)
        val note = findViewById<ImageView>(R.id.addIcon)
        val fab = findViewById<ExtendedFloatingActionButton>(R.id.fab)
        noParticipantsView = findViewById(R.id.NoParticipantsView)

        fab.setOnClickListener {
            onBackPressed()
        }

        back.setOnClickListener {
            onBackPressed()
        }

        note.setOnClickListener {
            showCustomDialog()
        }


        pendingIntent = PendingIntent.getActivity(
            this,
            0,
            Intent(this, this.javaClass).addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP),
            PendingIntent.FLAG_MUTABLE
        )

        rollNumberStatusMap = emptyMap()
        recyclerView = findViewById(R.id.recyclerView)
        adapter = RollNumberAdapter(rollNumberList ,rollNumberStatusMap)
        setupRecyclerView()

    }

    private fun setupRecyclerView() {
        firestore = FirebaseFirestore.getInstance()
        val attendanceCollectionRef = firestore
            .collection("events")
            .document(eventID.toString())
            .collection("Participants")
            .document("Attendance")

        attendanceCollectionRef.addSnapshotListener { documentSnapshot, error ->
            if (error != null) {
                // Handle errors
                Log.e(TAG, "Error fetching data: $error")
                return@addSnapshotListener
            }

            if (documentSnapshot != null && documentSnapshot.exists()) {

                val data = documentSnapshot.data

                if (data != null) {
                    val rollNumberStatusMap = data as Map<String, Map<String, Any>>
                    val rollNumbers = rollNumberStatusMap.keys.toList()

                    if (rollNumbers.isNotEmpty()) {
                        recyclerView.visibility = View.VISIBLE
                        noParticipantsView.visibility = View.GONE

                        rollNumberList.clear()
                        rollNumberList.addAll(rollNumbers)
                        recyclerView.layoutManager = LinearLayoutManager(this)
                        adapter = RollNumberAdapter(rollNumberList, rollNumberStatusMap)
                        recyclerView.adapter = adapter
                        adapter.notifyDataSetChanged()
                    } else {
                        recyclerView.visibility = View.GONE
                        noParticipantsView.visibility = View.VISIBLE
                    }
                }
            }
            else {
                Log.d(TAG, "Document doesn't exist")
            }
        }
    }




    override fun onResume() {
        super.onResume()
        if (!nfcAdapter?.isEnabled!!)
        {
            Toast.makeText(this,"Please Enable NFC",Toast.LENGTH_SHORT).show()
        }
        assert(nfcAdapter != null)
        nfcAdapter!!.enableForegroundDispatch(this, pendingIntent, null, null)
    }

    override fun onPause() {
        super.onPause()
        // On pause, stop listening
        if (nfcAdapter != null) {
            nfcAdapter!!.disableForegroundDispatch(this)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        resolveIntent(intent)
    }

    private fun resolveIntent(intent: Intent) {
        val action = intent.action
        if (NfcAdapter.ACTION_TAG_DISCOVERED == action ||
            NfcAdapter.ACTION_TECH_DISCOVERED == action ||
            NfcAdapter.ACTION_NDEF_DISCOVERED == action
        ) {
            val tag = (intent.getParcelableExtra<Parcelable>(NfcAdapter.EXTRA_TAG) as Tag?)!!
            readBlockData(tag)
        }
    }


    private fun readBlockData(tag: Tag) {
        val mifareClassic = MifareClassic.get(tag)
        try {
            mifareClassic.connect()
            val sector = 1 // Read data from sector 1
            val block = 0 // Read data from block 4
            val keyList = getDefaultKeys()

            for (key in keyList) {
                if (mifareClassic.authenticateSectorWithKeyA(sector, key)) {
                    // Authentication successful, read the block data here
                    val blockIndex = mifareClassic.sectorToBlock(sector) + block
                    val data = mifareClassic.readBlock(blockIndex)
                    val dataString = String(data, Charset.forName("US-ASCII"))
                    val rollNumber = dataString.substringBefore("#")
                    if (openForAll == true) {
                        addParticipant(rollNumber)
                    }else
                    {
                        addCloseParticipant(rollNumber)
                    }
                    break
                }
            }
        } catch (e: IOException) {
            Log.e(TAG, "Error reading Mifare Classic tag data", e)
        } finally {
            try {
                mifareClassic.close()
            } catch (e: IOException) {
                Log.e(TAG, "Error closing MifareClassic", e)
            }
        }
    }

    private fun addParticipant(rollNumber: String) {
        // Check if the roll number is already in the list
        if (rollNumberList.contains(rollNumber)) {
            Toast.makeText(this, "$rollNumber Attendance Already Marked", Toast.LENGTH_SHORT).show()
            return // Exit the function if it's already in the list
        }

        // Add the roll number to the list
        rollNumberList.add(0, rollNumber)
        adapter.notifyDataSetChanged()

        firestore = FirebaseFirestore.getInstance() // Replace with your event ID
        val attendanceCollectionRef = firestore
            .collection("events")
            .document(eventID.toString())
            .collection("Participants")
            .document("Attendance")

        // Update the Roll Number field under the "Attendance" document
        val updateData = mapOf(
            rollNumber to mapOf(
                "isPresent" to true,
                "takenBy" to user,
                "takenTime" to System.currentTimeMillis()
            )
        )
        attendanceCollectionRef
            .set(updateData, SetOptions.merge())
            .addOnSuccessListener {
                // Data added or updated successfully
                Toast.makeText(this, "$rollNumber Attendance Marked", Toast.LENGTH_SHORT).show()
                setupRecyclerView()
            }
            .addOnFailureListener { e ->
                // Handle errors
                Log.e(TAG, "Error adding/updating data for Roll Number: $rollNumber", e)
            }
    }


    private fun addCloseParticipant(rollNumber: String) {
        firestore = FirebaseFirestore.getInstance()
        val attendanceCollectionRef = firestore
            .collection("events")
            .document(eventID.toString())
            .collection("Participants")
            .document("Attendance")

        // Check if the roll number is already in the Firestore data
        attendanceCollectionRef.get()
            .addOnSuccessListener { documentSnapshot ->
                if (documentSnapshot != null && documentSnapshot.exists()) {
                    val data = documentSnapshot.data

                    if (data != null) {
                        val rollNumberStatusMap = data as MutableMap<String, Map<String, Any>>
                        val rollNumberData = rollNumberStatusMap[rollNumber]?.toMutableMap()

                        if (rollNumberData != null) {
                            val isPresent = rollNumberData["isPresent"] as? Boolean ?: false
                            if (!isPresent) {
                                val updateData = mapOf(
                                    rollNumber to mapOf(
                                        "isPresent" to true,
                                        "takenBy" to user,
                                        "takenTime" to System.currentTimeMillis()
                                    )
                                )

                                // Update the Firestore data with the modified rollNumberData
                                attendanceCollectionRef.set(updateData, SetOptions.merge())
                                    .addOnSuccessListener {
                                        Toast.makeText(this, "$rollNumber Attendance Marked", Toast.LENGTH_SHORT).show()
                                        setupRecyclerView()
                                    }
                                    .addOnFailureListener { e ->
                                        // Handle errors
                                        Log.e(
                                            TAG,
                                            "Error updating data for Roll Number: $rollNumber",
                                            e
                                        )
                                    }
                            } else {
                                Toast.makeText(this, "$rollNumber Attendance Already Marked ", Toast.LENGTH_SHORT).show()
                            }
                        } else {
                            Toast.makeText(this, "$rollNumber is not eligible for this Event", Toast.LENGTH_SHORT).show()
                        }
                    }
                } else {
                    Log.d(TAG, "Document doesn't exist")
                }
            }
            .addOnFailureListener { e ->
                e.printStackTrace()
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

    private fun showCustomDialog() {
        val dialogView = layoutInflater.inflate(R.layout.custom_dialog, null)
        val dialogBuilder = AlertDialog.Builder(this)
            .setView(dialogView)

        val alertDialog = dialogBuilder.create()
        alertDialog.window?.decorView?.setBackgroundResource(R.drawable.dialog_background)
        alertDialog.show()

        val titleTextView = dialogView.findViewById<TextView>(R.id.dialog_title)
        val participantIdInput = dialogView.findViewById<EditText>(R.id.participant_id)
        val addButton = dialogView.findViewById<Button>(R.id.add_button)
        val cancelButton = dialogView.findViewById<Button>(R.id.cancel_button)

        addButton.setOnClickListener {
            val rollNumber = participantIdInput.text.toString().toUpperCase()
            if (rollNumber.isNotEmpty()) {
                if (openForAll == true) {
                    if (scannedDataFormatChecker(rollNumber)) {
                        addParticipant(rollNumber)
                    } else {
                        Toast.makeText(this, "Invalid Roll Number Format", Toast.LENGTH_SHORT).show()
                    }
                }else
                {
                    addCloseParticipant(rollNumber)
                }
            } else {
                Toast.makeText(this, "Roll Number is empty", Toast.LENGTH_SHORT).show()
            }
            alertDialog.dismiss()
        }

        cancelButton.setOnClickListener {
            alertDialog.dismiss()
        }
    }

    private fun scannedDataFormatChecker(scannedData: String): Boolean {
        if (scannedData.length == 8 &&
            scannedData.substring(0, 2).toIntOrNull() != null &&
            scannedData.substring(6, 8).toIntOrNull() != null) {
            for (i in 2 until 5) {
                if (scannedData[i].digitToIntOrNull()!= null) {
                    return false;
                }
            }
            return true;
        } else {
            return false;
        }
    }



}