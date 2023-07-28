import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Widgets/participantsTile.dart';
import 'package:ftest/Data/constants.dart';
import 'package:google_fonts/google_fonts.dart';

class Participants extends StatefulWidget {
  String? eventID;
  bool isOpenForall;
  bool isEnded;
  Participants(
      {super.key,
      required this.eventID,
      required this.isOpenForall,
      required this.isEnded});

  @override
  State<Participants> createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String searchValue = "";
  bool searchCross = false;
  bool searchEnabled = true;

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
            onPressed: () {},
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
                      for (var element in snapshot.data!.docs) {
                        studentData = element["studentData"];
                      }
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
                                  studentData[index]["takenTime"] >= 1000000000
                                      ? studentData[index]["takenTime"]
                                      : studentData[index]["takenTime"] * 1000)
                              .toString();
                          if (searchValue == "") {
                            return ParticipantsTile(
                              participantID: studentData[index]["id"],
                              takenTime: time,
                              isPresent: studentData[index]['isPresent'],
                              isOpenForall: widget.isOpenForall,
                              eventID: widget.eventID!.toString(),
                              deleteBtn: widget.isEnded ? false : true,
                              takenBy: studentData[index]['takenBy'],
                            );
                          } else if (studentData[index]["id"]
                              .toString()
                              .toUpperCase()
                              .contains(searchValue.toString().toUpperCase())) {
                            return ParticipantsTile(
                              participantID: studentData[index]["id"],
                              takenTime: time,
                              isPresent: studentData[index]['isPresent'],
                              isOpenForall: widget.isOpenForall,
                              eventID: widget.eventID!,
                              deleteBtn: widget.isEnded ? false : true,
                              takenBy: studentData[index]['takenBy'],
                            );
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

  /*getCSV() async {
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
  }*/
}


/*
StreamBuilder(
                  stream: participants
                      .collection('Participants')
                      .orderBy('takenTime', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return (snapshot.connectionState == ConnectionState.waiting)
                        ? const Center(child: Center(child: Text("Loading...")))
                        : snapshot.data!.docs.isEmpty
                            ? Center(
                                child: widget.isOpenForall
                                    ? Text(
                                        'No participants to show..',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.inter(
                                          fontSize: 25.sp,
                                          color: textColor,
                                        ),
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
                                  if (searchValue == "") {
                                    return ParticipantsTile(
                                      participantID: e.id,
                                      takenTime: time,
                                      isPresent: e['isPresent'],
                                      isOpenForall: widget.isOpenForall,
                                      eventID: widget.eventID!.toString(),
                                      deleteBtn: true,
                                      takenBy: e['takenBy'],
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
                                      takenBy: e['takenBy'],
                                    );
                                  } else {
                                    return Container();
                                  }
                                }).toList());
                  },
                ),
 */