import 'package:flutter/material.dart';
import './screens/login_screen.dart';


void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat Demo',
      theme: ThemeData(
        primaryColor: Colors.teal,
        accentColor: Colors.tealAccent[200]
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}