// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';

import '../../Data/constants.dart';

class nfcScanner extends StatefulWidget {
  const nfcScanner({super.key});

  @override
  State<nfcScanner> createState() => _nfcScannerState();
}

class _nfcScannerState extends State<nfcScanner> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'NFC Read',
          style: TextStyle(color: textColor),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
    );
  }
}
