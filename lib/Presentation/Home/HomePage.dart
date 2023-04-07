import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftest/Presentation/Participants/Participants.dart';
import 'package:ftest/Presentation/Scanner/Scanner.dart';

import '../../Widgets/AppDrawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Home',
          style: TextStyle(color: Colors.black),),
          iconTheme: IconThemeData(color: Colors.black),
        ),
        drawer: Drawer(
          backgroundColor: Colors.black,
          child:  AppDrawer(fAuth: FirebaseAuth.instance),
        ),
        body: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: MediaQuery.of(context).size.height * 1,
              child: StreamBuilder(
                stream: FirebaseFirestore.instance.collection('Event').where('coordinators', arrayContains: FirebaseAuth.instance.currentUser!.email).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData) {
                    return Container();
                  } else if (snapshot.hasData) {
                    return ListView(
                        children: snapshot.data!.docs.map((e) {
                      return Card(
                        child: Container(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    e['eventName'],
                                    style: TextStyle(fontSize: 24),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  (e['startTime'])
                                              .toDate()
                                              .isBefore(DateTime.now()) &&
                                          (e['endTime'])
                                              .toDate()
                                              .isAfter(DateTime.now())
                                      ?
                                      //e['startTime'] <= Timestamp.now() && e['endTime'] > Timestamp.now() ?
                                      ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => Scanner(eventID: e['eventID']),));
                                          },
                                          child: const Text("Take Attendance"))
                                      : const SizedBox(width: 0),
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                          builder: (context) => Participants(
                                              eventID: e['eventID']),
                                        ));
                                      },
                                      child: Text("View Participants"))
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList());
                  } else {
                    return Container();
                  }
                },
              ),
            ),
          ),
        )
    );
  }
}
