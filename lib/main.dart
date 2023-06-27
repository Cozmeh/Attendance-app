import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ftest/Data/firebase_options.dart';
// firebase
import 'package:firebase_core/firebase_core.dart';

import 'splashScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.black,
          backgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
          )),
      home: const Splash()));
}
