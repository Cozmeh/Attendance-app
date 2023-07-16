import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Widgets/participantsTile.dart';
import 'package:ftest/Data/constants.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String searchValue = "";
  List<List<String>> items = [];
  bool searchCross = false;

  @override
  void initState() {
    items = [
      <String>["participantID", "takenBy", "takenTime", "isPresent"]
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> participants =
        FirebaseFirestore.instance.collection('events').doc(widget.eventID);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
      /*drawer: Drawer(
        child: AppDrawer(
          fAuth: FirebaseAuth.instance,
          pageTitle: "Participants",
        ),
      ),*/
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: pageHeaderBgColor,
        title: Text(
          "Participants",
          style: GoogleFonts.inter(
              color: pageHeaderTextColor, fontWeight: FontWeight.w500),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.stacked_bar_chart_rounded),
          )
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //  backgroundColor: Color(0xff1D4ED8),
      //   onPressed: () => getCSV(),
      //   child: const Icon(Icons.download),
      // ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 15.h,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.w, right: 15.w),
            child: SizedBox(
              height: 50,
              child: TextField(
                style: TextStyle(fontSize: 22.sp),
                cursorColor: Colors.black,
                focusNode: focusNode,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Participants..',
                  hintStyle: TextStyle(fontSize: 25.sp, color: dimGrey),
                  contentPadding: EdgeInsets.all(10.w),
                  focusColor: primaryBlue,
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryBlue),
                      borderRadius: BorderRadius.circular(10)),
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  prefixIcon: Icon(
                    Icons.search,
                    size: 35.h,
                  ),
                  prefixIconColor: Colors.black,
                  suffixIconColor: Colors.black,
                  suffixIcon: Visibility(
                    visible: searchCross,
                    child: IconButton(
                      icon: Icon(
                        Icons.clear,
                        size: 35.h,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          focusNode.unfocus();
                          searchValue = "";
                          searchCross = false;
                        });
                      },
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    focusNode.requestFocus();
                    searchCross = true;
                  });
                },
                onChanged: (changed) => setState(() => searchValue = changed),
              ),
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  focusNode.unfocus();
                });
              },
              child: SizedBox(
                child: Padding(
                  padding: EdgeInsets.only(left: 15.w, right: 15.w),
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
                                      e.id,
                                      e["takenBy"],
                                      time,
                                      e["isPresent"].toString()
                                    ]);
                                    if (searchValue == "") {
                                      return ParticipantsTile(
                                          participantID: e.id,
                                          takenTime: time,
                                          isPresent: e['isPresent'],
                                          isOpenForall: widget.isOpenForall,
                                          eventID: widget.eventID!.toString(),
                                          deleteBtn: true,
                                      );
                                    } else if (e.id
                                        .toString()
                                        .toUpperCase()
                                        .contains(searchValue
                                            .toString()
                                            .toUpperCase())) {
                                      return ParticipantsTile(
                                        participantID: e.id,
                                        takenTime: time,
                                        isPresent: e['isPresent'],
                                        isOpenForall: widget.isOpenForall,
                                        eventID: widget.eventID!,
                                        deleteBtn: true,
                                      );
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
