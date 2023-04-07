import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../InfraStructure/AuthRepo.dart';
import '../Presentation/Authentication/Login.dart';

class AppDrawer extends StatefulWidget {
  FirebaseAuth fAuth;
  AppDrawer({required this.fAuth});
  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
            child: Column(
      children: [
        Card(
            elevation: 5,
            margin: EdgeInsets.all(0.0),
            child: Container(
              width: double.infinity,
              color: Colors.blue,
              height: 300,
              padding: EdgeInsets.only(top: 35.0, bottom: 5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        widget.fAuth.currentUser!.photoURL.toString()),
                    maxRadius: 100,
                  ),
                  Text(FirebaseAuth.instance.currentUser!.displayName
                      .toString()),
                  Text(FirebaseAuth.instance.currentUser!.email.toString()),
                ],
              ),
            )),
        SizedBox(height: 25.0),
        Container(
            padding: EdgeInsets.all(5.0),
            color: Colors.grey,
            child: const ListTile(
              leading: Icon(Icons.history),
              title: Text(
                "History",
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.normal),
              ),
              // onTap: , this will open the history page
            )),
        SizedBox(height: MediaQuery.of(context).size.width * 0.7),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          decoration: BoxDecoration(border: Border.all(color: Colors.red)),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: () async {
                await AuthRepo.signOut().whenComplete(() => print("completes"));
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => Login()));
                });
              },
              child: const Text(
                "Sign Out",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 20.0,
                    fontWeight: FontWeight.normal),
              ),
            ),
          ),
        ),
      ],
    )));
  }
}
