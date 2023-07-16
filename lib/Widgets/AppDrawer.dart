import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ftest/Presentation/History/history.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:ftest/Data/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import '../InfraStructure/AuthRepo.dart';
import '../Presentation/Authentication/Login.dart';

// ignore: must_be_immutable
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
          color: pageHeaderBgColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 300,
                padding: const EdgeInsets.only(top: 40, bottom: 5.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(
                          widget.fAuth.currentUser!.photoURL.toString()),
                      maxRadius: 100,
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.displayName.toString(),
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Text(
                      FirebaseAuth.instance.currentUser!.providerData[0].email.toString(),
                      style: GoogleFonts.inter(color: dimGrey, fontSize: 20.sp),
                    ),
                  ],
                ),
              ),
              const Center(
                child: SizedBox(
                  height: 20,
                ),
              ),
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
                        leading: const Icon(Icons.home),
                        title: Text(
                          "Home",
                          style: GoogleFonts.inter(
                              fontSize: 20.0, fontWeight: FontWeight.w400),
                        ),
                      ))),
              Container(
                padding: const EdgeInsets.all(5.0),
                color: const Color.fromARGB(255, 66, 66, 66),
                child: ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const History()));
                  },
                  leading: Icon(
                    Icons.history_toggle_off,
                    size: 35.h,
                    color: Colors.white,
                  ),
                  title: Text(
                    "History",
                    style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w400),
                  ),
                  trailing: const Icon(
                    Icons.launch,
                    color: dimGrey,
                  ),
                ),
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
                  width: 300.h,
                  height: 60.h,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(5)),
                  child: TextButton(
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color.fromARGB(255, 117, 0, 0))),
                    child: Text(
                      "Sign Out",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () async {
                      await AuthRepo.signOut().whenComplete(() {
                        debugPrint("completes");
                      });
                      SchedulerBinding.instance.addPostFrameCallback((_) =>
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (context) => const Login())));
                    },
                  )),
            ],
          )),
    );
  }
}
