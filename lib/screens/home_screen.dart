import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_screen.dart';
import 'contact_screen.dart';
import 'edit_yourself.dart';

class Home extends StatefulWidget {
  final FirebaseUser user;
  final String phoneNumber;
  Home(this.user, this.phoneNumber);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isLoading;
  int doci;
  SharedPreferences prefs;
  
  final photoUrl =
      'https://4.bp.blogspot.com/-txKoWDBmvzY/XHAcBmIiZxI/AAAAAAAAC5o/wOkD9xoHn28Dl0EEslKhuI-OzP8_xvTUwCLcBGAs/s1600/2.jpg';
    String realPhotoUrl ;

  Widget buildItem(BuildContext context, DocumentSnapshot contactDocument) {
    // DocumentSnapshot document = snapshot.data.documents;
    if (contactDocument['id'] == widget.user.uid) {
      return Container();
    } else {
      return StreamBuilder<Object>(
          stream: Firestore.instance
              .collection('users')
              .document(contactDocument['id'])
              .snapshots(), //('id', isEqualTo:contactDocument['id'] ).snapshots(),
          builder: (context, snapshot) {
            AsyncSnapshot<dynamic> snapshots =
                snapshot as AsyncSnapshot<dynamic>;
            var document = snapshots.data;
            // print('document ============== $document');
            if (snapshot.hasData) {
              return GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      ClipRRect(
                        child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                            child: CircularProgressIndicator(
                                strokeWidth: 1.0,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.teal)),
                            width: 50.0,
                            height: 50.0,
                            padding: EdgeInsets.all(15.0),
                          ),
                          imageUrl: document['photoUrl'] ?? photoUrl,
                          width: 50.0,
                          height: 50.0,
                          fit: BoxFit.cover,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        clipBehavior: Clip.hardEdge,
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              child: Text(
                                ' ${contactDocument['nickname'] ?? widget.phoneNumber}',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                            ),
                            Container(
                              child: Text(
                                '${document['aboutMe'] ?? 'I am a Hii Hello User'}',
                                style: TextStyle(color: Colors.white),
                              ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                            )
                          ],
                        ),
                        margin: EdgeInsets.only(left: 20.0),
                      ),
                      SizedBox(width: 10)
                    ],
                  ),
                  margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),

                  padding: EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 10.0),
                  // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                ),
                onTap: () {
                  print(' chatting with ${document.documentID}');
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Chat(
                              document.documentID,
                              document['photoUrl'] ?? photoUrl,
                              contactDocument['nickname'],
                              widget.phoneNumber)));
                },
              );
            } else {
              return Container(
                child: Text('Add Contacts'),
              );
            }
          });
    }
  }




      Future<bool> onExitPress() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to exit an App'),
        actions: <Widget>[
          new FlatButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
          new FlatButton(
            onPressed: () => SystemNavigator.pop(),//Navigator.of(context).pop(true),
            child: new Text('Yes'),
          ),
        ],
      ),
    )) ?? false;
  }




  @override
  Widget build(BuildContext context) {
    realPhotoUrl = photoUrl;
    return WillPopScope(
      onWillPop: (){
        
        onExitPress();
        },
          child: Scaffold(
        appBar: AppBar(
          leading: GestureDetector(
            child: Padding(
              padding: const EdgeInsets.only(left: 5),
              child: StreamBuilder<Object>( 
                stream: Firestore.instance.collection('users').document(widget.user.uid).snapshots(),
                builder: (context, snapshotForPhotoUrl) {
                  AsyncSnapshot<dynamic> snapshotsForPhotoUrl =
                  snapshotForPhotoUrl as AsyncSnapshot<dynamic>;
                   realPhotoUrl = snapshotsForPhotoUrl.data['photoUrl'] ?? photoUrl;
                  return CircleAvatar(
                    backgroundImage: NetworkImage(realPhotoUrl ?? photoUrl),
                  );
                }
              ),
            ),
            onTap: () {
              showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                        content: Image.network(
                          realPhotoUrl,
                          fit: BoxFit.fill,
                        ),
                      ));
            },
          ),
          centerTitle: true,
          title: Text('Home Screen'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.settings,size: 30,),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => EditYourself(widget.user.uid)));
                }),
                
          ],
        ),
        body: Container(
              child: StreamBuilder(
        stream: Firestore.instance
            .collection('users')
            .document('${widget.user.uid}')
            .collection('contacts')
            .snapshots(),
        builder: (context, contactSnapshot) {
          //contactSnapshot.data.documents[0];
          if (!contactSnapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
              ),
            );
          } else {
            return ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemBuilder: (context, index) => buildItem(
        context,
        contactSnapshot.data.documents[index],
              ),
              itemCount: contactSnapshot.data.documents.length,
            );
          }
        },
              ),
            ),
          
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddContacts(widget.user),
                ));
          },
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 35,
          ),
          backgroundColor: Colors.teal,
        ),
      ),
    );
  }
}
