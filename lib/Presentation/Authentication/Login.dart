import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:ftest/InfraStructure/AuthRepo.dart';
import 'package:ftest/Presentation/Home/HomePage.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffffffff),
      body: Container(
        height: MediaQuery.of(context).size.height*1,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*.2,),
            Container(height: MediaQuery.of(context).size.height*.3,
            child: Image.asset('assets/kjcLogo.png'),),
            SizedBox(height: MediaQuery.of(context).size.height*.1),
            const Center(
              child: Text("Kristu Jayanti\n Attendance\n Management System",
              textAlign: TextAlign.center,
              style:  TextStyle(
                      color: Colors.black,
                                    fontFamily: 'Inter',
                                    fontSize: 28,
                                    fontWeight: FontWeight.w400),
              ),
            ),
             SizedBox(height: MediaQuery.of(context).size.height*.05),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xffffffff),elevation: 0),
              onPressed: () async {
              dynamic user=AuthRepo.googleSignup();
              if(user==true){
                Navigator.push(  
                  context,  
                  MaterialPageRoute(builder: (context) => HomePage()),  
                );
              }else{

              }
            }, 
            child: Container(
              width: MediaQuery.of(context).size.width*.7,
              decoration: BoxDecoration(
                 color: Colors.white,
                 border:Border.all(color: Color(0xff1D4ED8)), 
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, 
                children: [
                  Image.network(height: 40,width:40,
              'http://pngimg.com/uploads/google/google_PNG19635.png',
              fit:BoxFit.cover
            ), const SizedBox(
            width: 5.0,
            ),
                  const Text(
                    "Sign in with Google",
                    style: TextStyle(
                      color: Color(0xff1D4ED8),
                                    fontFamily: 'Inter',
                                    height: 1.2,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400),
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