// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'package:ftest/Data/constants.dart';
import 'package:ftest/Widgets/participantsTile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vibration/vibration.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../Scanner/nfc.dart';

// ignore: must_be_immutable
class Scanner extends StatefulWidget {
  String? eventID;
  bool isOpenForall;
  Scanner({super.key, required this.eventID, required this.isOpenForall});
  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  final ScrollController scrollControl = ScrollController();
  final GlobalKey globalKey = GlobalKey();
  QRViewController? qrViewController;
  bool correctScan = false;
  bool vibrate = false;
  bool isFlash = false;
  //String? result;
  Color? scanStatus;
  int totalCount = 0;
  String status = "";

  @override
  void initState() {
    status = "Scan the QR to mark Attendance";
    scanStatus = primaryBlue;
    super.initState();
  }

  @override
  void dispose() {
    qrViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(555, 1200),
      splitScreenMode: true,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: background,
          appBar: AppBar(
            backgroundColor: pageHeaderBgColor,
            centerTitle: true,
            title: const Text(
              'QR Scan',
              style: TextStyle(color: pageHeaderTextColor),
            ),
            iconTheme: const IconThemeData(color: pageHeaderTextColor),
            actions: [
              IconButton(
                onPressed: () {
                  // manual entry page route goes here
                },
                icon: const Icon(Icons.edit_square),
              ),
              IconButton(
                onPressed: () {
                  //nfc page route goes here
                  Navigator.of(context)
                    .push(MaterialPageRoute(
                  builder: (context) =>
                      const NfcScanner(),
                        ));
                },
                icon: const Icon(Icons.nfc),
              ),
            ],
          ),
          body: Column(
            children: [
              Stack(
                alignment: AlignmentDirectional.bottomEnd,
                children: <Widget>[
                  SizedBox(
                    height: 450.h,
                    child: QRView(
                      key: globalKey,
                      onQRViewCreated: _onQRViewCreated,
                      overlay: QrScannerOverlayShape(
                        cutOutHeight: 350.h,
                        cutOutWidth: 350.w,
                        borderColor: scanStatus ?? Colors.red,
                        borderRadius: 15,
                        borderLength: min(350.h, 350.w) / 2 + 12.w * 2,
                        borderWidth: 15.w,
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
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                    color: scanStatus, borderRadius: BorderRadius.circular(5)),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 20.sp, color: Colors.white),
                ),
              ),
              SizedBox(
                height: 10.h,
              ),
              Flexible(
                flex: 10,
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w, right: 15.w),
                  child: SizedBox(
                    child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('events')
                          .doc(widget.eventID)
                          .collection('Participants')
                          //.orderBy('takenTime', descending: false)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> snapshot) {
                        // Camera pausing ..
                        if (correctScan == true) {
                          Vibration.vibrate(duration: 100);
                          correctScan = false;
                          Timer(const Duration(seconds: 1), () {
                            scrollLatest();
                          });
                        } // Data Processing ..
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Text("Loading.."),
                          );
                        } else if (!snapshot.hasData) {
                          return Container();
                        } else if (snapshot.hasData) {
                          dynamic studentData;
                          List sdKey = [];
                          for (var element in snapshot.data!.docs) {
                            studentData = element.data();
                          }
                          studentData.forEach((key, value) {
                            sdKey.add(key);
                          });
                          if (studentData == null || studentData.length == 0) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/noOne.png",
                                  height: 200.h,
                                  width: 200.w,
                                ),
                                Text(
                                  "No one is here yet..",
                                  style: TextStyle(
                                    fontFamily: "Inter",
                                    fontSize: 25.sp,
                                  ),
                                ),
                              ],
                            );
                          }
                          return ListView.builder(
                              itemCount:
                                  studentData == null ? 1 : studentData.length,
                              controller: scrollControl,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                var itemTime =
                                    (DateTime.fromMillisecondsSinceEpoch(
                                                studentData?[sdKey[index]]
                                                            ["takenTime"] >=
                                                        1000000000
                                                    ? studentData[sdKey[index]]
                                                        ["takenTime"]
                                                    : studentData[sdKey[index]]
                                                            ["takenTime"] *
                                                        1000)
                                            .toString())
                                        .substring(0, 16);

                                return ParticipantsTile(
                                  isOpenForall: widget.isOpenForall,
                                  isPresent: studentData[sdKey[index]]
                                      ['isPresent'],
                                  participantID: sdKey[index],
                                  takenTime: itemTime,
                                  eventID: widget.eventID.toString(),
                                  deleteBtn: false,
                                );
                              });
                        } else {
                          return const Center(
                            child: Column(
                              children: [
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
              ),
              const Expanded(
                child: SizedBox(),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  fixedSize: Size(500.w, 60.h),
                ),
                onPressed: () {
                  qrViewController?.dispose();
                  Navigator.of(context).pop(
                    MaterialPageRoute(
                      builder: (context) => const HomePage(),
                    ),
                  );
                },
                child: Text(
                  'Finish',
                  style: GoogleFonts.inter(
                      fontSize: 25.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 30.h,
              )
            ],
          ),
        );
      },
    );
  }

  //  Permission for camera
  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    qrViewController!.resumeCamera();
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('no Permission'),
        ),
      );
    }
  }

  // Scroll to the latest scanned QR
  void scrollLatest() {
    if (widget.isOpenForall) {
      scrollControl.jumpTo(scrollControl.position.maxScrollExtent);
    }
  }

  //  QR Code Format Checker
  bool scannedDataFormatChecker(String? scannedData) {
    if (scannedData!.length == 8 &&
        int.tryParse(scannedData.substring(0, 2)) is int &&
        int.tryParse(scannedData.substring(6, 8)) is int) {
      for (var i = 2; i < 6; i++) {
        if (int.tryParse(scannedData[i]) is int) {
          return false;
        }
      }
      return true;
    } else {
      return false;
    }
  }

  //  QR Code Scanner
  void _onQRViewCreated(QRViewController controller) {
    setState(() => qrViewController = controller);
    controller.scannedDataStream.listen(
      (scanData) async {
        qrViewController?.stopCamera();
        try {
          if (scanData.code != null &&
              scannedDataFormatChecker(scanData.code)) {
            // if the event is NOT OPEN FOR ALL
            if (!widget.isOpenForall) {
              var studentData = await FirebaseFirestore.instance
                  .collection("events")
                  .doc(widget.eventID)
                  .collection("Participants")
                  .doc("Attendance")
                  .get();
              print("broo ${studentData.data()?[scanData.code]}");
              if (scanData.code != null) {
                if (studentData.data()?[scanData.code] != null) {
                  if (studentData.data()?[scanData.code]["isPresent"] == true) {
                    setState(() {
                      scanStatus = Colors.orange;
                      status = "${scanData.code} Attendance already Marked ";
                    });
                    qrViewController?.resumeCamera();
                  } else {
                    FirebaseFirestore.instance
                        .collection("events")
                        .doc(widget.eventID)
                        .collection("Participants")
                        .doc("Attendance")
                        .update({
                      scanData.code!: {
                        "isPresent": true,
                        "takenTime": DateTime.now().millisecondsSinceEpoch,
                        "takenBy": FirebaseAuth
                            .instance.currentUser!.providerData[0].email
                      }
                    });
                    setState(() {
                      scanStatus = Colors.green;
                      status = "${scanData.code} Attendance Marked ";
                      correctScan = true;
                    });
                    qrViewController?.resumeCamera();
                  }
                } else {
                  setState(() {
                    scanStatus = Colors.red;
                    status = "${scanData.code} is not eligible for this Event";
                  });
                  qrViewController?.resumeCamera();
                }
              }
              // if the event is OPEN FOR ALL
            } else {
              var studentData = await FirebaseFirestore.instance
                  .collection("events")
                  .doc(widget.eventID)
                  .collection("Participants")
                  .doc("Attendance")
                  .get();
              print("datadb ${studentData.data()?["21bcac47"]}");
              if (scanData.code != null) {
                if (studentData.data()?[scanData.code] != null) {
                  setState(() {
                    scanStatus = Colors.orange;
                    status = "${scanData.code} Attendance already Marked ";
                  });
                  qrViewController?.resumeCamera();
                } else {
                  FirebaseFirestore.instance
                      .collection("events")
                      .doc(widget.eventID)
                      .collection("Participants")
                      .doc("Attendance")
                      .set(
                    {
                      scanData.code!: {
                        'takenTime': DateTime.now().millisecondsSinceEpoch,
                        'isPresent': true,
                        'takenBy': FirebaseAuth
                            .instance.currentUser!.providerData[0].email,
                      },
                    },
                    SetOptions(merge: true),
                  );
                  setState(() {
                    scanStatus = Colors.green;
                    status = "${scanData.code} Attendance Marked!";
                    correctScan = true;
                  });
                  qrViewController?.resumeCamera();
                }
              } else {
                setState(() {
                  status = "Unknown error has occured";
                  scanStatus = Colors.red;
                });
                qrViewController?.resumeCamera();
              }
            }
          } else {
            setState(() {
              status = "Invalid QR format!";
              scanStatus = Colors.red;
            });
            qrViewController?.resumeCamera();
          }
        } catch (e) {
          print("Exception occured $e");
          setState(() {
            status = "Something went wrong!";
            scanStatus = Colors.red;
          });
          qrViewController?.resumeCamera();
        }
      },
    );
  }
}

