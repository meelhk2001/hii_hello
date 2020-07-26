import 'package:flutter/material.dart';
import 'package:hii_hello/screens/loading.dart';
import './screens/login_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alphabics',
      theme: ThemeData(
        primaryColor: Colors.teal,
        accentColor: Colors.teal,
      ),
      home:  LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}