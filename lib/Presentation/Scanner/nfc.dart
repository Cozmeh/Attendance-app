// ignore_for_file: camel_case_types

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NfcScanner extends StatefulWidget {
  const NfcScanner({Key? key}) : super(key: key);

  @override
  State<NfcScanner> createState() => _NfcScannerState();
}

class _NfcScannerState extends State<NfcScanner> {
  late StreamSubscription _streamSubscription;
  static const nfcChannel = MethodChannel('ams.nfc');
  static const nfcEventChannel = EventChannel('ams.nfcEvent');
  String nfcText = 'data';

  Future<void> checkNFC() async {
    String nfcTagData = await nfcChannel.invokeMethod('readBlockData');
    setState(() {
      nfcText = nfcTagData;
    });
  }

  void onStreamNFC() {
    _streamSubscription = nfcEventChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        nfcText = '$event';
      });
    });
  }

  @override
  void initState() {
    super.initState();
    onStreamNFC();
  }

  @override
  void dispose() {
    _streamSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'NFC Read',
          style: TextStyle(color: Colors.black54),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SizedBox(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(nfcText),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: checkNFC,
                child: const Text('NFC'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}