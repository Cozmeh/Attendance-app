import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftest/Presentation/Participants/Participants.dart';
import 'package:ftest/Presentation/Scanner/Scanner.dart';
import 'package:ftest/Widgets/EventCard.dart';

import '../../Widgets/AppDrawer.dart';

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
                      children: snapshot.data!.docs.map((e) {
                        String eventTense  = checkDate(e['eventDate']);
                        List l = checkTime(e['startTime'], e['endTime']);
                        if ((eventTense == "past")  || (eventTense == "today" && l[1] == "over")){
                          print(eventTense);
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

  String checkDate(String eventDate){
    DateTime today =  DateTime.now();
    int eventYear = int.parse(eventDate.substring(0,4));
    int eventMonth = int.parse(eventDate.substring(5,7));
    int eventDay = int.parse(eventDate.substring(8));
    if (today.year > eventYear){
      return "past";
    }else if ((today.year == eventYear) && (today.month > eventMonth)){
      return "past";
    }else if((today.year == eventYear) && (today.month == eventMonth) && (today.day > eventDay)){
      return "past";
    }else if((today.year == eventYear) && (today.month == eventMonth) && (today.day == eventDay)){
      return "today";
    }else{
      return "future";
    }
  }

  List checkTime(int startTime, int endTime){
    DateTime date = DateTime.now();
    DateTime start = DateTime.fromMillisecondsSinceEpoch(startTime >= 1000000000 ? startTime : startTime * 1000);
    DateTime end = DateTime.fromMillisecondsSinceEpoch(endTime >= 1000000000 ? endTime : startTime * 1000);
    String eventTime = '${start.hour % 12 == 0 ? 12 : start.hour % 12}:${start.minute < 10 ? '0' : ''}${start.minute} ${start.hour < 12 ? 'AM' : 'PM'}';

    if ((date.hour < start.hour) || (date.hour == start.hour && date.minute < start.minute)){
      return ["pending", eventTime];
    }else if ((date.hour == start.hour && date.minute > start.minute) || (date.hour > start.hour && date.hour < end.hour) || (date.hour == end.hour && date.minute < end.minute)){
      return ["running",eventTime];
    }else{
      return ["over",eventTime];
    }
  }
}