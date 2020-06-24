import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class EditYourself extends StatefulWidget {
  final String uid;

  EditYourself(this.uid);

  @override
  _EditYourselfState createState() => _EditYourselfState();
}

class _EditYourselfState extends State<EditYourself> {
  var aboutMe = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  File avatarImageFile;
  String photoUrl =
      'https://4.bp.blogspot.com/-txKoWDBmvzY/XHAcBmIiZxI/AAAAAAAAC5o/wOkD9xoHn28Dl0EEslKhuI-OzP8_xvTUwCLcBGAs/s1600/2.jpg';
  String realPhotoUrl;
  SharedPreferences prefs;
  @override
  void initState() {
    readLocal();
    super.initState();
  }

  Future<void> readLocal() async {
    realPhotoUrl = photoUrl;
    prefs = await SharedPreferences.getInstance();
    aboutMe.text = prefs.getString('aboutMe') ?? 'I am a Hii Hello User';
    //realPhotoUrl = prefs.getString('photoUrl') ?? photoUrl;
    setState(() {
      realPhotoUrl = prefs.getString('photoUrl') ?? photoUrl;
    });
  }

  Future<void> done(String aboutMe) async {
    await Firestore.instance
        .collection('users')
        .document(widget.uid)
        .setData({'aboutMe': aboutMe}, merge: true);
    prefs = await SharedPreferences.getInstance();
    await prefs.setString('aboutMe', aboutMe);
  }

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        avatarImageFile = image;
        isLoading = true;
      });
    }
    uploadFile();
  }

  Future uploadFile() async {
    String fileName = widget.uid;
    StorageReference reference = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = reference.putFile(avatarImageFile);
    StorageTaskSnapshot storageTaskSnapshot;
    uploadTask.onComplete.then((value) {
      if (value.error == null) {
        storageTaskSnapshot = value;
        storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          realPhotoUrl = downloadUrl;
          Firestore.instance
              .collection('users')
              .document(widget.uid)
              .updateData({'photoUrl': realPhotoUrl}).then((data) async {
            await prefs.setString('photoUrl', realPhotoUrl);
            setState(() {
              isLoading = false;
            });
          }).catchError((err) {
            setState(() {
              isLoading = false;
            });
          });
        }, onError: (err) {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }, onError: (err) {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('settings'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.done,
                color: Colors.white,
              ),
              onPressed: () {
                done(aboutMe.text);
                Navigator.of(context).pop();
              })
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              //SizedBox(height: 40),
              Container(
                child: Stack(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.9,
                      child: isLoading
                          ? Center(child: CircularProgressIndicator())
                          : Image.network(
                              realPhotoUrl,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.width * 0.9,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                            color: Colors.black12,
                            child: FlatButton.icon(
                              label: Text(''),
                              icon: Icon(
                                Icons.mode_edit,
                                color: Colors.white,
                              ),
                              onPressed: 
                                getImage
                              
                            )),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 40),
              Text(
                'About me',
                style: TextStyle(
                    fontSize: 30, color: Colors.teal, letterSpacing: 1.0),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                maxLength: 51,
                minLines: 2,
                maxLines: 10,
                cursorColor: Colors.teal,
                style: TextStyle(
                  color: Colors.black,
                ),
                decoration: InputDecoration.collapsed(
                  hintText: 'Type about yourself...',
                  hintStyle: TextStyle(color: Colors.teal),
                ),
                controller: aboutMe,
              ),
              SizedBox(
                height: 40,
              ),
              Row(
                children: <Widget>[
                  FlatButton.icon(
                      color: Colors.teal,
                      label: Text(
                        'Log out',
                        style: TextStyle(color: Colors.white),
                      ),
                      icon: Icon(
                        Icons.exit_to_app,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        _auth.signOut();
                        Navigator.of(context).pop();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginScreen(),
                            ));
                      }),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
