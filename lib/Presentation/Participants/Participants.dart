import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Widgets/participantsTile.dart';
import 'package:ftest/Data/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class Participants extends StatefulWidget {
  String? eventID;
  String eventName;
  bool isOpenForall;
  bool isEnded;
  var faculty;
  Participants(
      {super.key,
      required this.eventName,
      required this.eventID,
      required this.isOpenForall,
      required this.isEnded,
      required this.faculty});

  @override
  State<Participants> createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String searchValue = "";
  bool searchCross = false;
  bool searchEnabled = true;
  dynamic participantsData;
  List studentKey = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DocumentReference<Map<String, dynamic>> participants =
        FirebaseFirestore.instance.collection('events').doc(widget.eventID);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: background,
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
            onPressed: () {
              participantsInfo();
            },
            icon: const Icon(Icons.info),
          )
        ],
      ),
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
                enabled: searchEnabled,
                style: TextStyle(fontSize: 22.sp),
                cursorColor: Colors.black,
                focusNode: _focusNode,
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Participants..',
                  hintStyle: TextStyle(fontSize: 25.sp, color: dimGrey),
                  contentPadding: EdgeInsets.all(10.w),
                  focusColor: primaryBlue,
                  focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: primaryBlue),
                      borderRadius: BorderRadius.circular(borderRadius)),
                  border: const OutlineInputBorder(
                      borderRadius:
                          BorderRadius.all(Radius.circular(borderRadius))),
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
                          _focusNode.unfocus();
                          searchValue = "";
                          searchCross = false;
                        });
                      },
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    _focusNode.requestFocus();
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
            child: SizedBox(
              child: Padding(
                padding: EdgeInsets.only(left: 15.w, right: 15.w),
                child: StreamBuilder(
                  stream: participants
                      .collection('Participants')
                      //.orderBy('takenTime', descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: Text("Loading..."));
                    } else if (!snapshot.hasData) {
                      return Container();
                    } else if (snapshot.hasData) {
                      dynamic studentData;
                      List sdKey = [];
                      for (var element in snapshot.data!.docs) {
                        studentData = element.data();
                        participantsData = element.data();
                      }
                      studentData.forEach((key, value) {
                        sdKey.add(key);
                        studentKey.add(key);
                      });
                      if (studentData == null || studentData.length == 0) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/noOne.png",
                              height: 250.h,
                              width: 250.w,
                            ),
                            Text(
                              "Uh..oh! No participants..",
                              style: TextStyle(
                                fontFamily: "Inter",
                                fontSize: 25.sp,
                              ),
                            ),
                          ],
                        );
                      }
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: studentData == null ? 1 : studentData.length,
                        itemBuilder: (context, index) {
                          var time = DateTime.fromMillisecondsSinceEpoch(
                                  studentData[sdKey[index]]["takenTime"] >=
                                          1000000000
                                      ? studentData[sdKey[index]]["takenTime"]
                                      : studentData[sdKey[index]]["takenTime"] *
                                          1000)
                              .toString();
                          var participantsTile = ParticipantsTile(
                            participantID: sdKey[index],
                            takenTime: time,
                            isPresent: studentData[sdKey[index]]['isPresent'],
                            isOpenForall: widget.isOpenForall,
                            eventID: widget.eventID!.toString(),
                            deleteBtn: widget.isEnded ? false : true,
                            takenBy: studentData[sdKey[index]]['takenBy'],
                          );
                          // search results ...
                          if (searchValue == "") {
                            return participantsTile;
                          } else if (sdKey[index]
                              .toString()
                              .toUpperCase()
                              .contains(searchValue.toString().toUpperCase())) {
                            return participantsTile;
                          } else if (searchValue == "self" &&
                              studentData[sdKey[index]]["takenBy"]
                                  .toString()
                                  .toUpperCase()
                                  .contains(FirebaseAuth.instance.currentUser!
                                      .providerData[0].email
                                      .toString()
                                      .toUpperCase())) {
                            return participantsTile;
                          } else {
                            return Container();
                          }
                        },
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void participantsInfo() {
    int selfCount = 0;
    int presentCount = 0;
    int absentCount = 0;
    for (var i = 0; i < participantsData.length; i++) {
      if (participantsData[studentKey[i]]["takenBy"]
          .toString()
          .toUpperCase()
          .contains(FirebaseAuth.instance.currentUser!.providerData[0].email
              .toString()
              .toUpperCase())) {
        selfCount += 1;
      }
      if (participantsData[studentKey[i]]["isPresent"] == true) {
        presentCount += 1;
      } else {
        absentCount += 1;
      }
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Participants Info"),
              widget.isOpenForall
                  ? const Icon(Icons.public)
                  : const Icon(Icons.public_off)
            ],
          ),
          content: SizedBox(
            height: 200,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Event Name",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 22.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.eventName,
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                const Text(""),
                Text(
                  "Stats",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 22.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Total Participants : ${participantsData.length.toString()}",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                Text(
                  "My Count : $selfCount",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                Visibility(
                  visible: !widget.isOpenForall,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Present : $presentCount",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 22.sp,
                          color: Colors.green,
                        ),
                      ),
                      Text(
                        "Absent : $absentCount",
                        style: TextStyle(
                          fontFamily: "Inter",
                          fontSize: 22.sp,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(""),
                Text(
                  "Faculty Assigned",
                  style: TextStyle(
                    fontFamily: "Inter",
                    fontSize: 22.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      widget.faculty
                          .toString()
                          .replaceAll(",", "")
                          .replaceAll("[", "")
                          .replaceAll("]", ""),
                      style: TextStyle(
                        fontFamily: "Inter",
                        fontSize: 22.sp,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                "Okay",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }
}




