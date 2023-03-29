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
      body: Container(
        height: MediaQuery.of(context).size.height*1,
        child: Center(
          child: ElevatedButton(onPressed: () async {
            dynamic user=AuthRepo.googleSignup();
            if(user==true){
              Navigator.push(  
                context,  
                MaterialPageRoute(builder: (context) => HomePage()),  
              );
            }else{

            }
          }, 
          child: Center(
              child: Container(
                color: Colors.white,
                child: Row(mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    Image.network(height: 40,width:40,
                'http://pngimg.com/uploads/google/google_PNG19635.png',
                fit:BoxFit.cover
              ), const SizedBox(
          width: 5.0,
        ),
                    const Text(
                      "Google Signin",
                      style: TextStyle(fontSize: 18,color:Colors.black),
                    ),
                  ],
                ),
        ),
          ),
    )),
      ));
  }
}