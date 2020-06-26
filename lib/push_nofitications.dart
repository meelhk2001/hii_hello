import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {

  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance = PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");
      
      _initialized = true;
    }
  }
}








/////////////////////////////////faltu notification
///
///
///
///

//  Future<void> sendNotification(receiver,msg)async{

//     var token = await getToken(receiver);
//     print('token : $token');

//     final data = {
//       "notification": {"body": "Accept Ride Request", "title": "This is Ride Request"},
//       "priority": "high",
//       "data": {
//         "click_action": "FLUTTER_NOTIFICATION_CLICK",
//         "id": "1",
//         "status": "done"
//       },
//       "to": "$token"
//     };

//     final headers = {
//       'content-type': 'application/json',
//       'Authorization': 'key=AAAAY2mZqb4:APA91bH38d3b4mgc4YpVJ0eBgDez1jxEzCNTq1Re6sJQNZ2OJvyvlZJYx7ZASIrAj1DnSfVJL-29qsyPX6u8MyakmzlY-MRZeXOodkIdYoWgwvPVhNhJmfrTC6ZC2wG7lcmgXElA6E09'
//     };


//     BaseOptions options = new BaseOptions(
//       connectTimeout: 5000,
//       receiveTimeout: 3000,
//       headers: headers,
//     );


//     try {
//       final response = await Dio(options).post(postUrl,
//           data: data);

//       if (response.statusCode == 200) {
//         Fluttertoast.showToast(msg: 'Request Sent To Driver');
//       } else {
//         print('notification sending failed');
//         // on failure do sth
//       }
//     }
//     catch(e){
//       print('exception $e');
//     }

//   }

//    Future<String> getToken(userId)async{

//     final Firestore _db = Firestore.instance;

//     var token;
//     await _db.collection('users')
//         .document(userId)
//         .collection('tokens').getDocuments().then((snapshot){
//           snapshot.documents.forEach((doc){
//             token = doc.documentID;
//           });
//     });

//     return token;


//   }


// //Now Receiving End 

//     class _LoginPageState extends State<LoginPage>
//     with SingleTickerProviderStateMixin {

//   final Firestore _db = Firestore.instance;
//   final FirebaseMessaging _fcm = FirebaseMessaging();

//   StreamSubscription iosSubscription;



// //this code will go inside intiState function 

// // if (Platform.isIOS) {
// //       iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
// //         // save the token  OR subscribe to a topic here
// //       });

// //       _fcm.requestNotificationPermissions(IosNotificationSettings());
// //     }
//     _fcm.configure(
//       onMessage: (Map<String, dynamic> message) async {
//         print("onMessage: $message");
//         showDialog(
//           context: context,
//           builder: (context) => AlertDialog(
//             content: ListTile(
//               title: Text(message['notification']['title']),
//               subtitle: Text(message['notification']['body']),
//             ),
//             actions: <Widget>[
//               FlatButton(
//                 child: Text('Ok'),
//                 onPressed: () => Navigator.of(context).pop(),
//               ),
//             ],
//           ),
//         );
//       },
//       onLaunch: (Map<String, dynamic> message) async {
//         print("onLaunch: $message");
//         // TODO optional
//       },
//       onResume: (Map<String, dynamic> message) async {
//         print("onResume: $message");
//         // TODO optional
//       },
//     );