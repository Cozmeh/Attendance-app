import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ftest/InfraStructure/AuthRepo.dart';
import 'package:ftest/Presentation/Authentication/Login.dart';
import 'package:ftest/Presentation/Participants/Participants.dart';
import 'package:ftest/Presentation/Scanner/Scanner.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(child: ListView(children: [
        DrawerHeader(child: Column(children: [
         CircleAvatar(
          backgroundImage: NetworkImage(FirebaseAuth.instance.currentUser!.photoURL.toString()),
         radius: 25.0,
        ),
        SizedBox(height: 10),
          Text(FirebaseAuth.instance.currentUser!.displayName.toString()),
          Text(FirebaseAuth.instance.currentUser!.email.toString()),
        ],)),
        ListTile(title: Text("Logout"),onTap: ()async {
          await AuthRepo.signOut().whenComplete(() => print("completes"));
          SchedulerBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => Login()
                ));
          });
        },),
      ],)),
      body: Scaffold(body: 
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: MediaQuery.of(context).size.height*1,
          child: StreamBuilder(
            stream: FirebaseFirestore.instance.collection('Event')
            // .where('startTime',isLessThan: DateTime.now())
            // .where('endTime',isGreaterThan: DateTime.now())
            .where('coordinators',arrayContains: FirebaseAuth.instance.currentUser!.email)
            .snapshots(),
            builder:(BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(snapshot.connectionState==ConnectionState.waiting){
              return Center(child: CircularProgressIndicator());
            }else if(!snapshot.hasData){
              return Container();
            }else if(snapshot.hasData){
              return ListView(children: snapshot.data!.docs.map((e) {
                return Card(child: Container(child: Column(children: [
                  Row(children: [Text(e['eventName'],style:TextStyle(fontSize: 24),)],),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [

                      (e['startTime']).toDate().isBefore(DateTime.now()) && (e['endTime']).toDate().isAfter(DateTime.now()) ?
                      //e['startTime'] <= Timestamp.now() && e['endTime'] > Timestamp.now() ? 
                      ElevatedButton(
                        onPressed:(){
                         Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Scanner(eventID: e['eventID']),
                        ));
                      }, child: const Text("Take Attendance"))
                      :const SizedBox(width: 0),

                      ElevatedButton(onPressed: (){
                         Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Participants(eventID: e['eventID']),
                        ));
                      }, child: Text("View Participants"))

                    ],
                  )
                ],),),);
                }).toList());
            }else{
              return Container();
            }
          },),),
      ),)
      );
  }
}