// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Widgets/eventCard.dart';
import 'package:ftest/Data/constants.dart';
import '../../Widgets/appDrawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context);
    return ScreenUtilInit(
      designSize: const Size(555, 1200),
      builder: (context, child) {
        return WillPopScope(
          onWillPop: () async {
            var exitBar = SnackBar(
              backgroundColor: primaryBlue,
              content: const Text("Do you want to Exit ?"),
              action: SnackBarAction(
                  label: "Yes",
                  textColor: Colors.white,
                  onPressed: () {
                    SystemNavigator.pop();
                  }),
            );
            ScaffoldMessenger.of(context).showSnackBar(exitBar);
            return false;
          },
          child: Scaffold(
            backgroundColor: background,
            appBar: AppBar(
              backgroundColor: pageHeaderBgColor,
              centerTitle: true,
              title: const Text(
                'Home Page',
                style: TextStyle(color: pageHeaderTextColor),
              ),
              iconTheme: const IconThemeData(color: pageHeaderTextColor),
            ),
            drawer: Drawer(
              backgroundColor: Colors.black,
              child: AppDrawer(
                fAuth: FirebaseAuth.instance,
                pageTitle: "Home",
              ),
            ),
            body: Padding(
              padding: const EdgeInsets.all(2),
              child: SizedBox(
                height: double.infinity,
                child: StreamBuilder(
                  stream: FirebaseFirestore
                      .instance // composite indexes should be created in the firestore for ordering to work
                      .collection('events')
                      .where('coordinators',
                          arrayContains: FirebaseAuth
                              .instance.currentUser!.providerData[0].email)
                      .orderBy('startTime', descending: false)
                      .orderBy('eventName', descending: false)
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (!snapshot.hasData) {
                      return Container();
                    } else if (snapshot.hasData) {
                      bool button, isEnded, isStarted;
                      return ListView(
                          physics: const BouncingScrollPhysics(),
                          children: snapshot.data!.docs.map((e) {
                            print(e);
                            List timeCheck =
                                checkTime(e['startTime'], e['endTime']);
                            List timeCheck2 =
                                checkTime(e['endTime'], e['startTime']);
                            if (timeCheck[0] == "pending" ||
                                timeCheck[0] == "running") {
                              //if (eventTense != "past"){
                              //print(l[0]);
                              if (timeCheck[0] == "running") {
                                button = true;
                                isStarted = true; // started
                                isEnded = false; // didn't end yet
                              } else {
                                button = false;
                                isStarted = false; // didn't start yet
                                isEnded = false; // didn't end yet
                              }
                              return EventCard(
                                imageUrl: e['backDrop'],
                                eventName: e['eventName'],
                                departName: e['organizer'],
                                date: e['eventDate'],
                                venue: e['venue'],
                                startTime: timeCheck[1],
                                endTime: timeCheck2[1],
                                button: button,
                                id: e.id,
                                isOpenForall: e['openForAll'],
                                isStarted: isStarted,
                                isEnded: isEnded,
                              );
                            }
                            return const SizedBox();
                          }).toList());
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
            //)
          ),
        );
      },
    );
  }

  List checkTime(int startTime, int endTime) {
    DateTime today = DateTime.now();
    DateTime start = DateTime.fromMillisecondsSinceEpoch(
        startTime >= 1000000000 ? startTime : startTime * 1000);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(
        endTime >= 1000000000 ? endTime : startTime * 1000);
    String eventTime =
        '${start.hour % 12 == 0 ? 12 : start.hour % 12}:${start.minute < 10 ? '0' : ''}${start.minute} ${start.hour < 12 ? 'AM' : 'PM'}';

    if (start.isAfter(today)) {
      return ["pending", eventTime];
    } else if (start.isBefore(today) && end.isAfter(today)) {
      return ["running", eventTime];
    } else {
      return ["over", eventTime];
    }
  }
}
