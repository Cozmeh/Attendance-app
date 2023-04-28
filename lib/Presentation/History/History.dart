import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftest/Widgets/EventCard.dart';

class History extends StatelessWidget {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: MediaQuery.of(context).size.height * 1,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Event')
                  .where('coordinators',
                      arrayContains: FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData) {
                  return Container();
                } else if (snapshot.hasData) {
                  bool button;
                  return ListView(
                      physics: const BouncingScrollPhysics(),
                      children: snapshot.data!.docs.map((e) {
                        List l = checkTime(e['startTime'], e['endTime']);
                        if (l[0] == "over") {
                          print(l[0]);
                          button = false;
                          return EventCard(
                            imageUrl: e['backDrop'],
                            eventName: e['eventName'],
                            departName: e['deptName'],
                            date: e['eventDate'],
                            venue: e['venue'],
                            time: l[1],
                            description: e['description'],
                            button: button,
                            id: e.id,
                            isOpenForall: e['openForAll'],
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
}
