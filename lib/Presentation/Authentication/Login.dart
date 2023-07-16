import 'package:flutter/material.dart';
import 'package:ftest/InfraStructure/AuthRepo.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';
import 'package:ftest/Data/constants.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: background,
        body: SizedBox(
          height: MediaQuery.of(context).size.height * 1,
          child: Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .15,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * .35,
                child: Image.asset('assets/kjcLogo.png'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .1),
              const Center(
                child: Text(
                  "Kristu Jayanti\n Attendance\n Management System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.black,
                      fontFamily: 'Inter',
                      fontSize: 30,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * .1),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10))),
                onPressed: () async {
                  /*dynamic user =*/ AuthRepo.googleSignup();
                  /*if (user == true) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  } else {}*/
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * .7,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        height: 50,
                        width: 50,
                        'http://pngimg.com/uploads/google/google_PNG19635.png',
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(
                        width: 5.0,
                      ),
                      const Text(
                        "Continue with Google",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Inter',
                            height: 1.2,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
