import 'package:flutter/material.dart';
import 'package:ftest/Data/constants.dart';

class Logout extends StatefulWidget {
  String userEmail;
  Logout({super.key, required this.userEmail});

  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 240, 239, 239),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .1,
              ),
              PhysicalModel(
                color: Colors.transparent,
                elevation: 50,
                shape: BoxShape.circle,
                shadowColor: Colors.black.withOpacity(.3),
                child: SizedBox(
                  child: Image.asset(
                    'assets/403.png',
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .15,
              ),
              const Text(
                "Ohh..Snap! :(",
                style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'Inter',
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .05,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Text(
                  "The email address ${widget.userEmail} is not registered/authorised for using this application. Please try again with a valid  authorised account.",
                  style: const TextStyle(
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
                  Navigator.pop(context);
                },
                child: const Padding(
                  padding: EdgeInsets.all(15),
                  child: Text(
                    "Take me back",
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
        ));
  }
}
