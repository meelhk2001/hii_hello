import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddContacts extends StatelessWidget {
  final FirebaseUser user;
  AddContacts(this.user);
  var textEditingController = TextEditingController();
  var nickname = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add new Contact'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              Text(
                'Add details',
                style: TextStyle(
                    fontSize: 30, color: Colors.teal, letterSpacing: 1.0),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                cursorColor: Colors.teal,
                controller: textEditingController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    hintStyle: TextStyle(color: Colors.teal)),
                style: TextStyle(
                    fontSize: 25, letterSpacing: 2, color: Colors.teal),
              ),
              SizedBox(
                height: 20,
              ),
              RaisedButton(
                onPressed: () async {
                  QuerySnapshot result = await Firestore.instance
                      .collection('users')
                      .where('nickname', isEqualTo: textEditingController.text)
                      .getDocuments();
                  final List<DocumentSnapshot> documents = result.documents;
                  if (documents.length == 0) {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              content: Text('User Not Found'),
                              actions: <Widget>[
                                FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text('Okey'),
                                )
                              ],
                            ));
                  } else {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Enter nickname'),
                              content: TextField(
                                controller: nickname,
                              ),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('cancel'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                                FlatButton(
                                  onPressed: () async {
                                    if (nickname.text != null) {
                                      await Firestore.instance
                                          .collection('users')
                                          .document('${user.uid}')
                                          .collection('contacts')
                                          .document(textEditingController.text)
                                          .setData({
                                          'id': documents[0]['id'],
                                          'nickname': nickname.text,
                                          'photoUrl': documents[0]['photoUrl'],
                                          'createdAt': documents[0]
                                              ['createdAt'],
                                          'chattingWith': documents[0]
                                              ['chattingWith'],
                                          'contacts': null,
                                      }, merge: true);
                                      Navigator.pop(context);
                                      Navigator.of(context).pop();
                                      //textEditingController.clear();
                                      //nickname.clear();
                                    }
                                  },
                                  child: Text('Okey'),
                                ),
                                
                              ],
                            ));
                  }
                },
                elevation: 0,
                color: Colors.teal,
                child: Text('Find', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
