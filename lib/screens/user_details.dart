import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserDetails extends StatelessWidget {
  final String userId;
  final String userName;
  UserDetails({this.userId, this.userName});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<dynamic>(
          stream: Firestore.instance
              .collection('users')
              .document(userId)
              .snapshots(),
          builder: (context, snapshot) {
            if(snapshot.hasData){
           return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      title: Text(userName),
                      background:Image.network(snapshot.data['photoUrl']) ,
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate([
                    SizedBox(height: 30,),
                    Text(
                  snapshot.data['aboutMe'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.teal),
                ),
                SizedBox(height: 30,),
                Text(
                  snapshot.data['nickname'],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.teal),
                ),
                SizedBox(height: 30,),
                Text(
                  'Using Alphabics Since',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.teal),
                ),
                SizedBox(height: 10,),
                Text(DateFormat('MMMM/yyyy').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(snapshot.data['createdAt']))),
                  
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 30, color: Colors.teal),
                ),
                SizedBox(height:10)
                  ]))
                ],
              );}
              else{
                return Container();
              }
          }
              
    ));
  }
}
