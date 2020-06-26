import 'package:flutter/material.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(),
      body: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.25,
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
          Image.asset('assets/logoNew.png'),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),
          Text(
            'developed by : @meelhk',
            style: TextStyle(fontSize: 20, color: Colors.teal),
          ),
        ],
      ),
    );
  }
}
