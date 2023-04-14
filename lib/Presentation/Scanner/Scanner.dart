// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'package:ftest/Widgets/ParticipantsTile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Scanner extends StatefulWidget {
  String? eventID;
  Scanner({super.key, required this.eventID});
  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final GlobalKey globalKey = GlobalKey();
  QRViewController? qrViewController;
  bool correctScan = false;
  bool vibrate = false;
  bool isFlash = false;
  String? result;
  Color? scanStatus;
  int totalCount = 0;
  String status = "";

  Future<int> countProducts() async {
    print("count products");
    final CollectionReference<Map<String, dynamic>> productList =
        FirebaseFirestore.instance
            .collection('Event')
            .doc(widget.eventID)
            .collection("Participants");
    AggregateQuerySnapshot query = await productList.count().get();
    print('The number of products: ${query.count}');
    setState(() {
      totalCount = query.count;
    });
    print(query.count);
    return query.count;
  }

  @override
  void initState() {
    //qrViewController?.resumeCamera();
    //countProducts();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(555, 1200),
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Color(0xffffffff),
          appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            title: const Text(
              'Scanner',
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: IconThemeData(color: Colors.black),
          ),
          body: Column(
            children: [
              SizedBox(
                height: 55.h,
              ),
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: <Widget>[
                  SizedBox(
                    height: 450.h,
                    width: 450.w,
                    child: QRView(
                      key: globalKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        cutOutHeight: 350.h,
                        cutOutWidth: 350.w,
                        borderColor: scanStatus ?? Colors.red,
                        borderRadius: 10,
                        borderLength: min(350.h, 350.w) / 2 + 12.w * 2,
                        borderWidth: 12.w,
                      ),
                      onPermissionSet: (ctrl, p) =>
                          _onPermissionSet(context, ctrl, p),
                    ),
                  ),
                  Positioned(
                    bottom: 8.w,
                    right: 8.w,
                    child: SizedBox(
                        child: IconButton(
                      icon: isFlash
                          ? Icon(Icons.flash_on_rounded,
                              color: Colors.white, size: 35.w)
                          : Icon(Icons.flash_off_rounded,
                              color: Colors.white, size: 35.w),
                      onPressed: () {
                        setState(() {
                          qrViewController?.toggleFlash();
                          isFlash = !isFlash;
                        });
                      },
                    )),
                  )
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: scanStatus, borderRadius: BorderRadius.circular(5)),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 15.sp),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Padding(
                padding: EdgeInsets.only(left: 45.w, right: 45.w),
                child: SizedBox(
                  height: 350.h,
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Event')
                        .doc(widget.eventID)
                        .collection('Participants')
                        .orderBy('takenTime', descending: false)
                        .snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      // Camera pausing ..
                      if (correctScan == true) {
                        Vibration.vibrate(duration: 100);
                        correctScan = false;
                      } // Data Processing ..
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: Text("Loading.."),
                        );
                      } else if (!snapshot.hasData) {
                        return Container();
                      } else if (snapshot.hasData) {
                        return ListView(
                            physics: const BouncingScrollPhysics(),
                            children: snapshot.data!.docs.map((e) {
                              var itemTime = (e["takenTime"] as Timestamp)
                                  .toDate()
                                  .toString()
                                  .substring(0, 16);
                              return ParticipantsTile(participantID:e['participantID'], takenTime: itemTime, eventID: widget.eventID.toString(),);
                            }).toList());
                      } else {
                        return Center(
                          child: Column(
                            children: const [
                              Icon(Icons.error_outline, color: Colors.red),
                              Text("There was a problem in loading data..")
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
              SizedBox(
                height: 50.h,
              ),
              // qrViewController.
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff1D4ED8),
                  fixedSize: Size(450.w, 70.h),
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                  qrViewController?.dispose();
                },
                child: Text(
                  'Finish',
                  style: GoogleFonts.inter(fontSize: 18.sp,fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    qrViewController!.resumeCamera();
    //print('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('no Permission'),
        ),
      );
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() => qrViewController = controller);
    controller.scannedDataStream.listen(
      (scanData) async {
        //print("ITs sancnning");
        qrViewController?.stopCamera();
        if (scanData.code != null) {
          setState(() => result = scanData.code);
          var a = await FirebaseFirestore.instance
              .collection("Event")
              .doc(widget.eventID)
              .collection("Participants")
              .doc(scanData.code)
              .get();

          if ((await FirebaseFirestore.instance
                  .collection("Event")
                  .doc(widget.eventID)
                  .collection("Participants")
                  .doc(scanData.code)
                  .get())
              .exists) {
            setState(() {
              scanStatus = Colors.orange;
              status = "$result Attendance Marked already";
            });
            qrViewController?.resumeCamera();
          } else {
            setState(() {
              status = "Some problem occured";
              scanStatus = Colors.red;
            });
          }

          if (scanData.code != null && !a.exists) {
            var participantref = FirebaseFirestore.instance
                .collection("Event")
                .doc(widget.eventID)
                .collection("Participants")
                .doc(scanData.code);
            participantref.set(
              {
                'takenTime': DateTime.now(),
                'isPresent': true,
                'takenBy': FirebaseAuth.instance.currentUser!.email,
                'participantID': scanData.code
              },
            );
            setState(() {
              scanStatus = Colors.green;
              status = "$result Attendance Marked";
              correctScan = true;
            });
            qrViewController?.resumeCamera();
          }
          //
        }
      },
    );
  }
}
