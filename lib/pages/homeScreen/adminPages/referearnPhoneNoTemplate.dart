import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class viewReferredNumbers extends StatefulWidget {
  DocumentSnapshot doc;
  viewReferredNumbers(this.doc);
  @override
  _viewReferredNumbersState createState() => _viewReferredNumbersState(doc);
}

class _viewReferredNumbersState extends State<viewReferredNumbers> {
  DocumentSnapshot doc;
  _viewReferredNumbersState(this.doc);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Numbers'),
        centerTitle: true,
      ),
      body: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.only(top: 10, bottom: 10),
          itemCount:
              doc.get("invitedTo").length, //doc.data['invitedTo'].length,
          itemBuilder: (context, index) {
            return Text(
              "[${index + 1}]${doc.get("invitedTo/index")}",
              //"[${index + 1}]${doc.data['invitedTo'][index]}",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22),
            );
          }),
    );
  }
}
