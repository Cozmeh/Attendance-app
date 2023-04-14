import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:ftest/Presentation/History/History.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../InfraStructure/AuthRepo.dart';
import '../Presentation/Authentication/Login.dart';

class AppDrawer extends StatefulWidget {
  FirebaseAuth fAuth;
  String pageTitle;
  AppDrawer({super.key, required this.fAuth, required this.pageTitle});
  @override
  State<StatefulWidget> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          color: const Color(0xffe6e6e6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                padding: EdgeInsets.only(top: 35, bottom: 5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          widget.fAuth.currentUser!.photoURL.toString()),
                      maxRadius: 100,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.displayName.toString(),
                      style: GoogleFonts.inter(),
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.email.toString(),
                      style: GoogleFonts.inter(color: Color(0xff616161)),
                    ),
                  ],
                ),
              ),
              Center(
                child: SizedBox(
                    height: 25,
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: const Divider(
                      color: Color(0xffa7a7a7),
                      thickness: 1.0,
                    )),
              ),
              Container(
                  padding: const EdgeInsets.all(5.0),
                  color: const Color(0xffd9d9d9),
                  child: ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const History(),
                    )),
                    leading: const Icon(Icons.history),
                    title: Text(
                      "History",
                      style: GoogleFonts.inter(
                          fontSize: 20.0, fontWeight: FontWeight.w400),
                    ),
                  )),
              Visibility(
                  visible: widget.pageTitle != "Home",
                  child: Container(
                      padding: const EdgeInsets.all(5.0),
                      color: const Color(0xffd9d9d9),
                      child: ListTile(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        },
                        leading: const Icon(Icons.history),
                        title: Text(
                          "Home",
                          style: GoogleFonts.inter(
                              fontSize: 20.0, fontWeight: FontWeight.w400),
                        ),
                      )
                  )
              ),
              Expanded(
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.25,
                      maxHeight: MediaQuery.of(context).size.height * 0.45,
                    ),
                    alignment: Alignment.bottomCenter,
                  ),
              ), //this is the empty space between the button and the list items
              Container(
                  margin: const EdgeInsets.only(bottom: 20.0),
                  width: 200,
                  decoration: BoxDecoration(border: Border.all(color: const Color(0xffb91c1c))),
                  child: TextButton(
                    child: Text(
                      "Sign Out",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                          color: const Color(0xffb91c1c),
                          fontSize: 20.0,
                          fontWeight: FontWeight.normal),
                    ),
                    onPressed: () async {
                      await AuthRepo.signOut()
                          .whenComplete(() => print("completes"));
                      SchedulerBinding.instance.addPostFrameCallback(
                              (_) => Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const Login())));
                    },
                  )
              ),
            ],
          )
      ),
    );
  }
}
