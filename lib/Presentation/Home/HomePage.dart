import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftest/Presentation/Participants/Participants.dart';
import 'package:ftest/Presentation/Scanner/Scanner.dart';
import 'package:ftest/Widgets/EventCard.dart';

import '../../Widgets/AppDrawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    //Navigator.pop(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        backgroundColor: Colors.black,
        child: AppDrawer(
          fAuth: FirebaseAuth.instance,
          pageTitle: "Home",
        ),
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
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData) {
                  return Container();
                } else if (snapshot.hasData) {
                  return ListView(
                      children: snapshot.data!.docs.map((e) {
                    return DateTime.fromMillisecondsSinceEpoch(e['endTime'] * 1000).isAfter(DateTime.now())
                        ? EventCard(
                            endTime:DateTime.fromMillisecondsSinceEpoch(e['startTime'] * 1000),
                            imageUrl: e['backDrop'],
                            eventName: e['eventName'],
                            departName: e['deptName'],
                            venue: e['venue'],
                            dateTime:DateTime.fromMillisecondsSinceEpoch(e['startTime'] * 1000),
                            id: e.id.toString(),
                            page: 'history',
                            desc: '',
                          )
                        : SizedBox();
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
}
