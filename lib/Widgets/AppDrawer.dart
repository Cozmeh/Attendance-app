import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ftest/Presentation/History/History.dart';
import 'package:google_fonts/google_fonts.dart';
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
                    Text(FirebaseAuth.instance.currentUser!.displayName.toString(),style: GoogleFonts.inter(),),
                    Text(FirebaseAuth.instance.currentUser!.email.toString(), style: GoogleFonts.inter(color: Color(0xff616161)),),
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
                child: ListTile(
                  onTap: (){
                    Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => History(),
                                        ));
                  },
                  leading: Icon(Icons.history),
                  title: Text("History", style: GoogleFonts.inter(fontSize: 20.0, fontWeight: FontWeight.w400),),
                  // onTap: , this will open the home page
                )
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.4),
            Container(
              margin: const EdgeInsets.only(bottom: 20.0),
              width: MediaQuery.of(context).size.width * 0.6,
              decoration: BoxDecoration(border: Border.all(color: Color(0xffb91c1c),)),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                  child: Text(
                    "Sign Out",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                        color: Color(0xffb91c1c),
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