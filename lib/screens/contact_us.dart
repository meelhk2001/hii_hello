import 'package:flutter/material.dart';

class ContactUs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text('Contact Us'),
         centerTitle: true,
         elevation: 0,
       ),
      body: SingleChildScrollView(
              child: Column(
          
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.10,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.08,
              width: double.infinity,
              color: Colors.teal,
              child: Center(
                child: Text(
                  'Alphabics',
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.25,
            ),
            Text(
              '''For suggestions and inquiry :
 meelhk2001@gmail.com''',
              style: TextStyle(fontSize: 20, color: Colors.teal),
            ),
            SizedBox(height: 15,),
            Text(
              'Your suggestions will help us to improve this app',
              style: TextStyle(fontSize: 15, color: Colors.teal),
            ),
            SizedBox(height: 150,),
            Text(
              'developed by : @meelhk',
              style: TextStyle(fontSize: 20, color: Colors.teal),
            ),
            SizedBox(height: 30,),
            Text(
              'Made in India',
              style: TextStyle(fontSize: 15, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}