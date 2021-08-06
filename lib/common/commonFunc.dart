import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:loading_animations/loading_animations.dart';

class CommonFunction {
  final String serverToken =
      'AAAALKQaw9U:APA91bHOFcWpFCw1mSZq7bRhlSkQBdKXg_OhV4M1__RrGwzx7uZubmOD37nZdnmZKzfbSNDMwDFGVbAhTpsYpu0lePZkuwjW2SgOUhNb57Cwd0YPI6cbjSXIKvojYFpNirTuB1L3rVkT';
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> showProgressDialog(
      {required bool isShowDialog, @required context}) async {
    //async is added
    if (isShowDialog) {
      showDialog(
          //return is removed
          context: context,
          builder: (context) {
            return Center(
              child: Container(
                width: 30,
                height: 30,
                child: LoadingFlipping.circle(
                  borderColor: Colors.blue,
                  borderSize: 5,
                ),
              ),
            );
          });
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  Future<List<DocumentSnapshot>> getPost(String path) async {
    try {
      List<DocumentSnapshot> documents = []; //= new List<DocumentSnapshot>();
//      debugPrint("SnapshotNAME 123");
//      print(path);
      var querySnapshot = await _firestore.collection(path).get();
      print(querySnapshot.docs[0].data()); //getdocument changes to get
      print(querySnapshot);
      for (var snapshot in querySnapshot.docs) {
        //document changes to docs
        try {
          if ((snapshot.data() as dynamic)["Status"]) {
            documents.add(snapshot);
          }
        } catch (e) {
          documents.add(snapshot);
        }
      }
      return documents;
    } catch (e) {
      debugPrint("Exception (getRecentPost) : ${e.toString()}");
      return [];
    }
  }

  Future<Map<String, dynamic>> sendAndRetrieveMessage(
      String body, String title) async {
/*    await firebaseMessaging.requestNotificationPermissions(
      const IosNotificationSettings(
          sound: true, badge: true, alert: true, provisional: false),
    );             */
    var jsonRes = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverToken',
      },
      body: json.encode(
        <String, dynamic>{
          'notification': <String, dynamic>{'body': body, 'title': title},
          'priority': 'high',
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'id': '1',
            'status': 'done'
          },
          'to': "/topics/all",
        },
      ),
    );

    var jsonData = jsonRes.body;
    debugPrint("msgReqData $jsonData");

    final Completer<Map<String, dynamic>> completer =
        Completer<Map<String, dynamic>>();

    firebaseMessaging.getInitialMessage();
//    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//      RemoteNotification? notification = message.notification;
//      AndroidNotification android = message.notification?.android;
//    });

    /*   firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        completer.complete(message);
      },
    );               */
    //it is avoided to avoid error

    //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//  Map<String, String> data = message.data;

    //Owner owner = Owner.fromMap(jsonDecode(data['owner']));
    // User user = User.fromMap(jsonDecode(data['user']));
    // Picture picture = Picture.fromMap(jsonDecode(data['picture']));

    // print('The user ${user.name} liked your picture "${picture.title}"!');
//});

    return completer.future;
  }
}
