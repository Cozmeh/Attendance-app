import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Data/constants.dart';
import 'package:ftest/Widgets/EventCard.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: pageHeaderBgColor,
        title: const Text(
          'History',
          style: TextStyle(color: pageHeaderTextColor),
        ),
        iconTheme: const IconThemeData(color: pageHeaderTextColor),
      ),
      body: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 1,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('events')
                  .where('coordinators',
                      arrayContains: FirebaseAuth
                          .instance.currentUser!.providerData[0].email)
                  .orderBy('eventName', descending: false)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Text("Loading..."));
                } else if (!snapshot.hasData) {
                  return Container();
                } else if (snapshot.hasData) {
                  bool isStarted, isEnded;
                  List count = [];
                  for (var e in snapshot.data!.docs) {
                    count.add(e.get('endTime'));
                    List startTime = checkTime(e['startTime'], e['endTime']);
                    startTime[0] != "over" ? count.removeLast() : null;
                    print("Count : ${count.length}");
                  }
                  if (count.isEmpty) {
                    return noHistoryEvents();
                  }
                  return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: snapshot.data!.docs.map((e) {
                        List timeCheck =
                            checkTime(e['startTime'], e['endTime']);
                        List timeCheck2 =
                            checkTime(e['endTime'], e['startTime']);
                        if (timeCheck[0] == "over") {
                          isStarted = false;
                          isEnded = true;
                          return EventCard(
                            imageUrl: e['backDrop'],
                            eventName: e['eventName'],
                            departName: e['organizer'],
                            date: e['eventDate'],
                            venue: e['venue'],
                            startTime: timeCheck[1],
                            endTime: timeCheck2[1],
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
      ),
      //)
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

  noHistoryEvents() {
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
              "No History",
              style: TextStyle(fontSize: 25.sp, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
