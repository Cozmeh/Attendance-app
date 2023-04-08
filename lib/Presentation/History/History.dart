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
    return Scaffold(
        appBar: AppBar(
            title: Text(
              'History',
              style: TextStyle(color: Colors.black),
            ),
            iconTheme: IconThemeData(color: Colors.black),
        ),
        body: Scaffold(body:
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height*1,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('Event')
                  .where('coordinators',arrayContains: FirebaseAuth.instance.currentUser!.email)
                  .snapshots(),
              builder:(context, streamSnapshot){
                if(streamSnapshot.connectionState==ConnectionState.waiting){
                  return Center(child: CircularProgressIndicator());
                }else if(!streamSnapshot.hasData){
                  return Container();
                }else if(streamSnapshot.hasData){
                  final details = streamSnapshot.data!.docs;
                  return ListView.builder(
                      itemCount: details.length,
                      itemBuilder: (ctx, index) =>
                      details[index]['endTime'].toDate().isBefore(DateTime.now())?
                          EventCard(
                              imageUrl: details[index]['backDrop'],
                              eventName: details[index]['eventName'],
                              departName :details[index]['deptName'],
                              venue: details[index]['venue'],
                              dateTime: details[index]['startTime'].toDate(),
                              id: details[index]['eventID'],
                              page: 'history')
                          : SizedBox(width: 0,)
                  );
                }else{
                  return Container();
                }
              },),
          ),
        ),)
    );
  }
}