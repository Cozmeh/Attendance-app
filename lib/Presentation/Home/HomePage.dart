// ignore_for_file: avoid_print
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Data/constants.dart';
import 'package:ftest/Widgets/AppDrawer.dart';
import 'package:ftest/Widgets/EventCard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;
  @override
  Widget build(BuildContext context) {
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
            drawer: const AppDrawer(),
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
                      return const Center(child: Text("Loading..."));
                    } else if (!snapshot.hasData) {
                      return Container();
                    } else if (snapshot.hasData) {
                      bool isEnded, isStarted;
                      List count = [];
                      for (var e in snapshot.data!.docs) {
                        count.add(e.get('endTime'));
                        List startTime =
                        checkTime(e['startTime'], e['endTime']);
                        startTime[0] == "over" ? count.removeLast() : null;
                      }
                      if (count.isEmpty) {
                        return noActiveEvents();
                      }
                      return RefreshIndicator(
                        triggerMode: RefreshIndicatorTriggerMode.onEdge,
                        displacement: 20,
                        color: primaryBlue,
                        onRefresh: refresh,
                        child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            children: snapshot.data!.docs.map(
                                  (e) {
                                List startTime =
                                checkTime(e['startTime'], e['endTime']);
                                List endTime =
                                checkTime(e['endTime'], e['startTime']);

                                if (startTime[0] == "pending" ||
                                    startTime[0] == "running") {
                                  if (startTime[0] == "running") {
                                    isStarted = true; // started
                                    isEnded = false; // didn't end yet
                                  } else {
                                    isStarted = false; // didn't start yet
                                    isEnded = false; // didn't end yet
                                  }
                                  return EventCard(
                                    imageUrl: e['backDrop'],
                                    eventName: e['eventName'],
                                    departName: e['organizer'],
                                    date: e['eventDate'],
                                    venue: e['venue'],
                                    startTime: startTime[1],
                                    endTime: endTime[1],
                                    id: e.id,
                                    isOpenForall: e['openForAll'],
                                    isStarted: isStarted,
                                    isEnded: isEnded,
                                    faculty: e['coordinators'],
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ).toList()),
                      );
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> refresh() {
    return Future.delayed(const Duration(seconds: 1), () {
      setState(() {});
    });
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

  noActiveEvents() {
    return SizedBox(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/empty.png",
              height: 200.h,
              width: 200.w,
            ),
            Text(
              "No Events to show",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }


}
