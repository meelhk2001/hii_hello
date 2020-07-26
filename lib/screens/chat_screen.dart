import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hii_hello/screens/user_details.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:url_launcher/url_launcher.dart';

class Chat extends StatefulWidget {
  final String docId;
  final String imageUrl;
  final String name;
  String phoneNumber;
  Chat(this.docId, this.imageUrl, this.name, this.phoneNumber);
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  String id;
  String typedMessage;
  var listMessage;
  String groupChatId;
  SharedPreferences prefs;
  var textEditingController = TextEditingController();
  File imageFile;
  bool isLoading;
  final linkText = [
    '.com',
    '.gov',
    '.in',
    '.desi',
    '.jpg',
    '.net',
    '.org',
    '.de',
    '.icu',
    '.uk',
    '.ru',
    '.info',
    '.top',
    '.xyz',
    '.tk',
    '.cn',
    '.ga',
    '.cf',
    '.nl',
    '.us',
    '.pk',
    '.live',
    '.buzz',
    '.gq',
    '.tk',
    '.fit',
    '.cf',
    '.ga',
    '.ml',
    '.wang',
    '.top',
    '.eu',
    '.de',
    '.ca',
    '.hk',
    '.am',
    '.lv',
    '.dj',
    '.tv',
    '.as',
    '.bingo',
    '.blackfriday',
    '.edu',
    '.mil',
    '.arpa',
    '.app',
    '.blog',
    '.co',
    '.dev',
    '.io',
    '.biz',
    '.club',
    '.global',
    '.guru',
    '.me',
    '.media',
    '.news',
    '.online',
    '.site',
    '.space',
    '.tech',
    '.today',
    '.website',
    '.world',
    '.vg',
    '.wiki',
    '.one'
  ];
  //notification
  final Firestore _db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  void initState() {
    groupChatId = '';
    readLocal();

    _fcm.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // showDialog(
        //   context: context,
        //   builder: (context) => AlertDialog(
        //     content: ListTile(
        //       title: Text(message['notification']['title']),
        //       subtitle: Text(message['notification']['body']),
        //     ),
        //     actions: <Widget>[
        //       FlatButton(
        //         child: Text('Ok'),
        //         onPressed: () => Navigator.of(context).pop(),
        //       ),
        //     ],
        //   ),
        // );
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // TODO optional
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // TODO optional
      },
    );

    //StreamSubscription iosSubscription;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    groupChatId = '';
    readLocal();
    super.didChangeDependencies();
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1]['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildInput() {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 50,
        maxHeight: 130,
      ),
          child: Container(
        
        margin: EdgeInsets.only(bottom: 5, left: 5),
        child: Row(
          children: <Widget>[
            // Button send image

            // Edit text
            Flexible(
              child: Container(
                //height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal, width: 1.7),
                  color: Colors.white70,
                ),
                padding: EdgeInsets.only(left: 5, bottom: 10,top: 5),
                child: TextField(
                  // expands: true,

                  // minLines: null,
                  maxLines: null,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(51000),
                  ],

                  cursorColor: Colors.teal,
                  style: TextStyle(color: Colors.black, fontSize: 22.0),

                  controller: textEditingController,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: Colors.teal),
                  ),
                  onChanged: (val) {
                    typedMessage = val;
                  },
                  // focusNode: focusNode,
                ),
              ),
            ),

            // Button send message
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Container(
                //color: Colors.tealAccent,
                margin: EdgeInsets.symmetric(horizontal: 8.0),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    size: 40,
                  ),
                  onPressed: () => onSendMessage(typedMessage),
                  color: Colors.teal,
                ),
              ),
              //color: Colors.white,
            ),
          ],
        ),
        width: double.infinity,
        //height: 50.0,
        decoration: BoxDecoration(
          // border: Border(
          //     top: BorderSide(color: Colors.tealAccent[200], width: 0.5)),
          color: Color.fromRGBO(236, 229, 221, 1),
        ),
      ),
    );
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    widget.phoneNumber = prefs.getString('phoneNumber');
    id = prefs.getString('id') ?? '';
    if (id.hashCode <= widget.docId.hashCode) {
      groupChatId = '$id-${widget.docId}';
    } else {
      groupChatId = '${widget.docId}-$id';
    }

    await Firestore.instance
        .collection('users')
        .document(id)
        .updateData({'chattingWith': widget.docId});

    setState(() {});
  }

  Widget buildListMessage() {
    return Flexible(
      child: groupChatId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.teal)))
          : StreamBuilder(
              stream: Firestore.instance
                  .collection('messages')
                  .document(groupChatId)
                  .collection(groupChatId)
                  .orderBy('timestamp', descending: true)
                  .limit(101)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.teal)));
                } else {
                  listMessage = snapshot.data.documents;
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildChat(index, snapshot.data.documents[index], index),
                    itemCount: snapshot.data.documents.length,
                    reverse: true,
                    //controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Color.fromRGBO(236, 229, 221, 1),
      appBar: AppBar(
        leading: null,
        elevation: 0,
        title: Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
            ),
            SizedBox(
              width: 30,
            ),
            GestureDetector(child: Text(widget.name ?? 'Chat'),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetails(userId:widget.docId, userName: widget.name,),
                ));
            },
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          // List of messages
          buildListMessage(),
          // Input content
          buildInput(),
        ],
      ),
    );
  }

  Widget buildChat(int index, DocumentSnapshot document, int i) {
    bool hyperlink = false;
    if (!document['content'].toString().contains(" ")) {
      linkText.forEach((element) {
        if (document['content'].toString().contains(element)) {
          hyperlink = true;
        }
      });
    }

    if (document['idFrom'] == id) {
      // Right (my message)
      return Row(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(
                bottom: isLastMessageRight(index) ? 20.0 : 3.0, right: 0.0),
            padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
            decoration: BoxDecoration(
                color: document['read'] == 1 ? Colors.cyan[800] : Colors.teal,
                borderRadius: BorderRadius.circular(8.0)),
            // /;;;;';;
            child: ConstrainedBox(
              constraints: new BoxConstraints(
                //minHeight: 5.0,
                minWidth: 50.0,
                //maxHeight: 30.0,
                maxWidth: 300.0,
              ),
              child: InkWell(
                child: DecoratedBox(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      InkWell(
                        child: Text(
                          document[
                              'content'], /////////////////////////////////////////////////////////////////////////////////////

                          style: TextStyle(
                              color:
                                  hyperlink ? Colors.blue[900] : Colors.white,
                              fontSize: 18,
                              decoration:
                                  hyperlink ? TextDecoration.underline : null,
                              fontStyle: hyperlink ? FontStyle.italic : null),
                        ),
                        onTap: hyperlink
                            ? () async {
                                String text = document['content']
                                    .toString()
                                    .toLowerCase();
                                //document['content'].toString().toLowerCase();
                                text = text.replaceAll('https://', '');
                                text = text.replaceAll('http://', "");
                                text = text.replaceAll('https//', "");
                                text = text.replaceAll('http//', "");
                                //print('resume'.replaceAll('e', 'é'));

                                var url =
                                    'https://$text'; //document['content'].toString();
                                //await launch(url);

                                if (await canLaunch(url)) {
                                  await launch(url);
                                } else {
                                  throw 'Could not launch $url';
                                }
                              }
                            : () {},
                      ),
                      SizedBox(height: 5),
                      Text(
                        DateFormat('ddMMMyy h:mm a').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(document['timestamp']))),
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                      color: document['read'] == 1
                          ? Colors.cyan[800]
                          : Colors.teal,
                      borderRadius: BorderRadius.circular(8.0)),
                ),
                onLongPress: () {
                  scaffoldKey.currentState
                      .showBottomSheet((context) => Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                IconButton(
                                    icon: Icon(Icons.content_copy),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Clipboard.setData(ClipboardData(
                                        text: document['content'],
                                      ));

                                      Fluttertoast.showToast(
                                          msg: 'Message Copied');
                                    }),
                                IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () async {
                                      Navigator.of(context).pop();
                                      await Firestore.instance
                                          .collection('messages')
                                          .document(groupChatId)
                                          .collection(groupChatId)
                                          .document(document.documentID)
                                          .delete();
                                      setState(() {});
                                    }),
                                IconButton(
                                    icon: Icon(Icons.cancel),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                              ],
                            ),
                            color: Colors.teal,
                          ));
                },
              ),
            ),
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(document.documentID)
          .setData({'read': 0}, merge: true);

      // Left (peer message)///////////////////////////////////////////////////////////////////
      return Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                InkWell(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white70,
                        borderRadius: BorderRadius.circular(8.0)),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 300,
                        minWidth: 50,
                      ),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                            //color: Colors.white70,
                            borderRadius: BorderRadius.circular(8.0)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              child: Text(
                                document[
                                    'content'], ///////////////////////////////////////////////////////////////////////////
                                style: TextStyle(
                                    color: hyperlink
                                        ? Colors.blue[900]
                                        : Colors.teal,
                                    fontSize: 18,
                                    decoration: hyperlink
                                        ? TextDecoration.underline
                                        : null,
                                    fontStyle:
                                        hyperlink ? FontStyle.italic : null),
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              DateFormat('ddMMMyy h:mm a').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      int.parse(document['timestamp']))),
                              style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.0,
                                  fontStyle: FontStyle.italic),
                            ),
                          ],
                        ),
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(8.0, 5.0, 8.0, 5.0),
                    //width: 200.0,

                    // margin: EdgeInsets.only(left: 0.0),
                  ),
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(
                      text: document['content'],
                    ));
                    Fluttertoast.showToast(msg: 'Message Copied');
                  },
                  onTap: hyperlink
                      ? () async {
                          String text =
                              document['content'].toString().toLowerCase();
                          //document['content'].toString().toLowerCase();
                          text = text.replaceAll('https://', '');
                          text = text.replaceAll('http://', "");
                          text = text.replaceAll('https//', "");
                          text = text.replaceAll('http//', "");
                          //print('resume'.replaceAll('e', 'é'));

                          var url =
                              'https://$text'; //document['content'].toString();
                          //await launch(url);

                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            throw 'Could not launch $url';
                          }
                        }
                      : () {},
                )
              ],
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        margin: EdgeInsets.only(bottom: 3.0),
      );
    }
  }

  void onSendMessage(
    String content,
  ) {
    HapticFeedback.lightImpact();
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      // HapticFeedback.vibrate()
      textEditingController.clear();
      typedMessage = '';
      var documentReference = Firestore.instance
          .collection('messages')
          .document(groupChatId)
          .collection(groupChatId)
          .document(DateTime.now().millisecondsSinceEpoch.toString());
/////////////////////////////////////////////////////////////////////////////
      Firestore.instance.runTransaction((transaction) async {
        await transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': widget.docId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,
            'read': 1
          },
        );
        try {
          await Firestore.instance
              .collection('users')
              .document('${widget.docId}')
              .collection('contacts')
              .document(widget.phoneNumber)
              .updateData(
            {
              'id': id,
              'photoUrl': null,
              'createdAt': null,
              'chattingWith': null,
              'contacts': null,
            },
          );
          sendNotification('New Message');
        } catch (error) {
          await Firestore.instance
              .collection('users')
              .document('${widget.docId}')
              .collection('contacts')
              .document(widget.phoneNumber)
              .setData({
            'id': id,
            'nickname': widget.phoneNumber,
            'photoUrl': null,
            'createdAt': null,
            'chattingWith': null,
            'contacts': null,
          }, merge: true);
          sendNotification('New Message');
        }
      });

      //listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      textEditingController.clear();
      typedMessage = '';
      return;
      //Fluttertoast.showToast(msg: 'Nothing to send');
    }
  }

///////////////
  ///Strating of notification code

  Future<void> sendNotification(String title) async {
    String body;
    prefs = await SharedPreferences.getInstance();
    var _phone = await prefs.getString('phoneNumber');
    var result = await Firestore.instance
        .collection('users')
        .document(widget.docId)
        .collection('contacts')
        .document(_phone)
        .get();
    body = result['nickname'];

    var token = await getToken(widget.docId);
    print('token : $token');

    final data = {
      "notification": {"body": 'From : $body', "title": title},
      "priority": "high",
      "data": {
        "click_action": "FLUTTER_NOTIFICATION_CLICK",
        "id": "1",
        "status": "done",
        'sound': 'default'
      },
      "to": "$token"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAXbEZttU:APA91bGoF3JppZ75pswhJETzJqHKiwRXOVg-3HWAS-BhqUsDoUeDYZU3My18Jbs9Uo-Xab9AeT4I8hwhLBBw3BxgibyLQLTMPOE3tjQRotISLhYkbU3NNQ7nzI7xGZfASzvza8I_DZUo'
    };

    BaseOptions options = new BaseOptions(
      connectTimeout: 5000,
      receiveTimeout: 3000,
      headers: headers,
    );

    try {
      final postUrl = 'https://fcm.googleapis.com/fcm/send';
      final response = await Dio(options).post(postUrl, data: data);

      // if (response.statusCode == 200) {
      //   Fluttertoast.showToast(msg: 'Request Sent To Driver');
      // } else {
      //   print('notification sending failed');
      //   // on failure do sth
      // }
    } catch (e) {
      print('exception $e');
    }
  }

  Future<String> getToken(userId) async {
    final Firestore _db = Firestore.instance;

    print('ye h docId  =============          ${widget.docId}');

    var token;
    //String fcmToken = await _fcm.getToken();
    var result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: widget.docId)
        .getDocuments();
    token = result.documents[0]['token'];
    print('ye h token  =============          $token');
    return token;
  }

//////////////////
  ///Ending of Notification code

}
