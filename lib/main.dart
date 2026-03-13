import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:panasonic_port/MyHome_Page.dart';
import 'wauly_monitor_screen.dart';
=======
import 'package:flutter_port_app/MyHome_Page.dart';
>>>>>>> e31babe10ded64515602883ca070a223c9a88b79

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      title: 'Panasonic Monitor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Panasoic Monitor App'),
      debugShowCheckedModeBanner: false,
=======
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
>>>>>>> e31babe10ded64515602883ca070a223c9a88b79
    );
  }
}
