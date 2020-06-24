import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'loading.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String phoneNumber;

  String otp;

  AuthCredential credential;

  SharedPreferences prefs;

  FirebaseUser currentUser;

  final String photoUrl =
      'https://4.bp.blogspot.com/-txKoWDBmvzY/XHAcBmIiZxI/AAAAAAAAC5o/wOkD9xoHn28Dl0EEslKhuI-OzP8_xvTUwCLcBGAs/s1600/2.jpg';
 
  var isLoading = false;
  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  Future<void> getCurrentUser() async {
    try{
      isLoading =true;
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      print('Yhaaaa  aaaa find kiya user ko');
      if (user != null) {
      prefs = await SharedPreferences.getInstance();
      phoneNumber = prefs.getString('phonenumber');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Home(user, phoneNumber),
          ));
          //print('isLoading =============== ${isLoading.toString()}');
          setState(() {
            isLoading = false;
          });
         // print('isLoading false =============== ${isLoading.toString()}');
    } else {
      
     // print('isLoading =============== ${isLoading.toString()}');
      setState(() {
        isLoading = false;
      });
      //print('Else isLoading false =============== ${isLoading.toString()}');
      return;
    }
    }catch(error){
      setState(() {
        isLoading = false;
      });
      print('Error =====================  $error');
      
    }
    

    
  }

  Future<void> otpVerify(AuthCredential credential, FirebaseAuth auth) async {
    FirebaseUser firebaseUser =
        (await auth.signInWithCredential(credential)).user;

    if (firebaseUser != null) {
      print('yaha bhi aaya h if me....................................');
      // Check is already sign up
      final QuerySnapshot result = await Firestore.instance
          .collection('users')
          .where('id', isEqualTo: firebaseUser.uid)
          .getDocuments();
      final List<DocumentSnapshot> documents = result.documents;
      if (documents.length == 0) {
        // Update data to server if new user
        await Firestore.instance
            .collection('users')
            .document(firebaseUser.uid)
            .setData({
          'nickname': firebaseUser.displayName ?? phoneNumber,
          'photoUrl': photoUrl,
          'id': firebaseUser.uid,
          'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
          'chattingWith': null,
          'contacts': null,
          'aboutMe': 'I am a Hii Hello user'
        });
        // Write data to local
        currentUser = firebaseUser;
        prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setString('phonenumber', phoneNumber);
        await prefs.setString('id', currentUser.uid);
        await prefs.setString('nickname', currentUser.displayName);
        await prefs.setString('photoUrl', currentUser.photoUrl);
      } else {
        // Write data to local
        prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        await prefs.setString('phonenumber', phoneNumber);
        await prefs.setString('id', documents[0]['id']);
        await prefs.setString('nickname', documents[0]['nickname']);
        //await prefs.setString('photoUrl', documents[0]['photoUrl']);
        await prefs.setString('aboutMe', documents[0]['aboutMe']);
      }
      Fluttertoast.showToast(msg: "Sign in success");
      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(firebaseUser, phoneNumber),
          ));
    } else {
      print('yaha aaya h else me /////////////////////////');
      Fluttertoast.showToast(msg: "Sign in fail");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> sendOtp(String phoneNumber, BuildContext context) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          otpVerify(authCredential, _auth);
        },
        verificationFailed: null,
        codeSent: (String verificationId, [int forceResendingToken]) {
          //show dialog to take input from the user
          showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                    title: Text("Enter SMS Code"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        TextField(
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            otp = val;
                          },
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      FlatButton(
                          child: Text("Done"),
                          textColor: Colors.white,
                          color: Colors.teal,
                          onPressed: () async {
                            FirebaseAuth auth = FirebaseAuth.instance;

                            credential = PhoneAuthProvider.getCredential(
                                verificationId: verificationId, smsCode: otp);
                            otpVerify(credential, auth);
                          })
                    ],
                  ));
        },
        codeAutoRetrievalTimeout: null);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
          ? Loading()
          :Scaffold(
        body: Center(
      child:  Container(
              padding: EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (val) => phoneNumber = val,
                  ),
                  SizedBox(height: 10),
                  FlatButton(
                    child: Text('Request Otp'),
                    onPressed: () {
                      String phone = '+91$phoneNumber';

                      print(phone);
                      sendOtp(phone, context);
                    },
                  )
                ],
              ),
            ),
    ));
  }
}
