import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../InfraStructure/AuthRepo.dart';
import '../Presentation/Authentication/Login.dart';

class AppDrawer extends StatefulWidget {
  FirebaseAuth fAuth;
  AppDrawer({super.key, required this.fAuth});
  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: const Color( 0xffe6e6e6 ),
        child: Column(
          children: [
            Container(
                width: double.infinity,
                height: 300,
                padding: const EdgeInsets.only(top: 35.0, bottom: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          widget.fAuth.currentUser!.photoURL.toString()),
                      maxRadius: 100,
                    ),
                    Text(FirebaseAuth.instance.currentUser!.displayName.toString()),
                    Text(FirebaseAuth.instance.currentUser!.email.toString(), style: const TextStyle(color: Color(0xff616161)),),
                  ],
                ),
              ),
            Center(
              child: SizedBox(
                height: 25.0,
                width: MediaQuery.of(context).size.width * 0.7,
                child: const Divider(
                    color: Color(0xffa7a7a7),
                  thickness: 1.0,
                )
              ),
            ),
            Container(
                padding: const EdgeInsets.all(5.0),
                color: const Color(0xffd9d9d9),
                child: const ListTile(
                  leading: Icon(Icons.history),
                  title: Text("History", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w400),),
                  // onTap: , this will open the home page
                )
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.4),
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(border: Border.all(color: Colors.red)),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  child: const Text(
                    "Sign Out",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 20.0,
                        fontWeight: FontWeight.normal),
                  ),
                  onPressed: () async {
                    await AuthRepo.signOut().whenComplete(() => print("completes"));
                    SchedulerBinding.instance.addPostFrameCallback((_) => Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Login())));
                  },
                ),
              ),
            ),
          ],
        )
      )
    );
  }
}
