import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Widgets/participantsTile.dart';
import 'package:ftest/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Widgets/appDrawer.dart';

class Participants extends StatefulWidget {
  String? eventID;
  bool isOpenForall;
  Participants({super.key, required this.eventID, required this.isOpenForall});

  @override
  State<Participants> createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  String number = "";
  List<List<String>> items = [];

  @override
  void initState() {
    items = [
      <String>["participantID", "takenBy", "takenTime", "isPresent"]
    ];
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FocusNode focusNode = FocusNode();
    DocumentReference<Map<String, dynamic>> participants =
        FirebaseFirestore.instance.collection('Event').doc(widget.eventID);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      drawer: Drawer(
        child: AppDrawer(
          fAuth: FirebaseAuth.instance,
          pageTitle: "Participants",
        ),
      ),
      appBar: AppBar(
          title: Text(
            "Participants",
            style: GoogleFonts.inter(
                color: textColor, fontWeight: FontWeight.w500),
          ),
          iconTheme: IconThemeData(color: Colors.black)),
      // floatingActionButton: FloatingActionButton(
      //  backgroundColor: Color(0xff1D4ED8),
      //   onPressed: () => getCSV(),
      //   child: const Icon(Icons.download),
      // ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.only(left: 25.w, right: 25.w),
            child: SizedBox(
              height: 70.h,
              child: TextField(
                style: TextStyle(fontSize: 20.sp),
                onTap: () {
                  focusNode.requestFocus();
                },
                focusNode: focusNode,
                decoration: InputDecoration(
                    hintStyle: TextStyle(fontSize: 20.sp),
                    focusColor: primaryBlue,
                    border: const OutlineInputBorder(),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 35.h,
                    ),
                    hintText: 'Search Participants..'),
                onChanged: (roll) => setState(() => number = roll),
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                focusNode.unfocus();
              },
              child: SizedBox(
                child: Padding(
                  padding: EdgeInsets.only(left: 25.w, right: 25.w),
                  child: StreamBuilder(
                    stream: participants
                        .collection('Participants')
                        .orderBy('takenTime', descending: false)
                        .snapshots(),
                    builder: (context, snapshot) {
                      return (snapshot.connectionState ==
                              ConnectionState.waiting)
                          ? const Center(child: CircularProgressIndicator())
                          : snapshot.data!.docs.isEmpty
                              ? Center(
                                  child: widget.isOpenForall
                                      ? Text(
                                          'THIS EVENT IS OPEN FOR ALL',
                                          style: GoogleFonts.inter(
                                              color: textColor,
                                              fontWeight: FontWeight.w500),
                                        )
                                      : null,
                                )
                              : ListView(
                                  physics: const BouncingScrollPhysics(),
                                  children: snapshot.data!.docs.map((e) {
                                    var time =
                                        DateTime.fromMillisecondsSinceEpoch(
                                                e["takenTime"] >= 1000000000
                                                    ? e["takenTime"]
                                                    : e["takenTime"] * 1000)
                                            .toString();
                                    items.add([
                                      e['participantID'],
                                      e["takenBy"],
                                      time,
                                      e["isPresent"].toString()
                                    ]);
                                    if (number == "") {
                                      return ParticipantsTile(
                                          participantID: e['participantID'],
                                          takenTime: time,
                                          isPresent: e['isPresent'],
                                          isOpenForall: widget.isOpenForall);
                                    } else if (e['participantID']
                                        .toString()
                                        .toUpperCase()
                                        .contains(
                                            number.toString().toUpperCase())) {
                                      return ParticipantsTile(
                                          participantID: e['participantID'],
                                          takenTime: time,
                                          isPresent: e['isPresent'],
                                          isOpenForall: widget.isOpenForall);
                                    } else {
                                      return Container();
                                    }
                                  }).toList());
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  getCSV() async {
    String csvData = const ListToCsvConverter().convert(items);
    print(csvData);
    try {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
      final String directory = (await getApplicationDocumentsDirectory()).path;
      final String path = "$directory/ams${widget.eventID}.csv";
      final File file = File(path);
      dynamic data = await file.writeAsString(csvData);
      print(data);
      print(path);
      try {
        await OpenFilex.open(file.path);
      } catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }
}
