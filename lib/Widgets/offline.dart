import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../Data/constants.dart';

class Offline extends StatefulWidget {
  const Offline({super.key});

  @override
  State<Offline> createState() => _OfflineState();
}

class _OfflineState extends State<Offline> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var exitBar = SnackBar(
          backgroundColor: primaryBlue,
          content: const Text("Do you want to Exit ?"),
          action: SnackBarAction(
              label: "Yes",
              textColor: Colors.white,
              onPressed: () {
                SystemNavigator.pop();
              }),
        );
        ScaffoldMessenger.of(context).showSnackBar(exitBar);
        return false;
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                PhysicalModel(
                  color: Colors.transparent,
                  elevation: 50,
                  shape: BoxShape.circle,
                  shadowColor: Colors.black.withOpacity(.3),
                  child: SizedBox(
                    child: Image.asset(
                      'assets/offline.png',
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .1,
                ),
                const Text(
                  "Opps..you're Offline!",
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 30, right: 30),
                  child: Text(
                    "Your device is Offline, Please check your network connection and try again later.\nThe page will be reloaded once you are back online.",
                    style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontSize: 19,
                      fontWeight: FontWeight.w100,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .05,
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10))),
                  onPressed: () {
                    //setState(() {});
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(15),
                    child: Text(
                      "Try again",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Inter',
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
