import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:image_picker/image_picker.dart';

class SendEmailAdmin extends StatefulWidget {
  @override
  _SendEmailAdminState createState() => _SendEmailAdminState();
}

class _SendEmailAdminState extends State<SendEmailAdmin> {
  final ImagePicker picker = ImagePicker();
  late PickedFile pickedFile;
  late FilePickerResult filePickerResult = FilePickerResult([]);
  TextEditingController subjectCont = TextEditingController();
  TextEditingController bodyCont = TextEditingController();
  List<String> userEmailList =
      []; //so this contains the email ids of all the users in the database

  init() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("Users").get();
    if (querySnapshot != null && querySnapshot.docs.length > 0) {
      for (DocumentSnapshot snapshot in querySnapshot.docs) {
        userEmailList.add((snapshot.data() as dynamic)["emailId"]);
        //userEmailList.add(snapshot.data["emailId"]);
      }
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff051094),
        title: Text("Send Email"),
        actions: [
          IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: () async {
              filePickerResult =
                  (await FilePicker.platform.pickFiles(allowMultiple: true))!;
              setState(() {});
            },
            //{
            // filePickerResult = await FilePicker.platform
            //        .pickFiles(allowMultiple: true); //()! is added
            //    setState(() {});
            //    },
          ),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: () {
                sendEmail();
                // print('sent');
                Navigator.of(context).pop();
              },
            ),
          )
        ],
      ),
      body: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(
                  height: 30,
                ),
                TextField(
                    controller: subjectCont,
                    decoration: InputDecoration(
                        labelText: "Subject", border: OutlineInputBorder())),
                SizedBox(
                  height: 10,
                ),
                TextField(
                    controller: bodyCont,
                    maxLength: 300,
                    maxLines: 5,
                    decoration: InputDecoration(
                        labelText: "Body", border: OutlineInputBorder())),
                SizedBox(
                  height: 30,
                ),
                Column(
                  children: filePickerResult != null
                      ? filePickerResult.files.map((e) {
                          //null check sign is added
                          return Stack(
                            children: [
                              Container(
                                height: 200,
                                width: MediaQuery.of(context).size.width,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                child: Image.file(
                                  File(e.path
                                      as String), //as String is added to remove error
                                  //File(e.path),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Container(
                                height: 40,
                                decoration: BoxDecoration(
                                    color:
                                        Colors.grey.shade400.withOpacity(0.6)),
                                child: Align(
                                  alignment: Alignment.centerRight,
                                  child: IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                    onPressed: () {
                                      filePickerResult.files
                                          .remove(e); //! is added
                                      setState(() {});
                                    },
                                  ),
                                ),
                              )
                            ],
                          );
                        }).toList()
                      : [Container()],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  sendEmail() async {
    String subject = subjectCont.text.trim();
    String body = bodyCont.text.trim();
    if (subject.isEmpty) {
      BotToast.showText(text: "Please enter subject", contentColor: Colors.red);
      return;
    }
    if (body.isEmpty) {
      BotToast.showText(
          text: "Please enter body content", contentColor: Colors.red);
      return;
    }
    MailOptions mail;
    if (filePickerResult.paths != null) {
      //! is added after filepickerresult
      mail = MailOptions(
        body: body,
        subject: subject,
        isHTML: false,
        attachments:
            filePickerResult.paths as List<String>, //after result code is added
        //attachments: filePickerResult!.paths,  this line is removed
        //attachments: filePickerResult.paths,
        bccRecipients: userEmailList,
      );
    } else {
      mail = MailOptions(
        body: body,
        subject: subject,
        isHTML: false,
        bccRecipients: userEmailList,
      );
    }

    var platformResponse;
    final MailerResponse response = await FlutterMailer.send(mail);
    switch (response) {
      case MailerResponse.saved:

        /// ios only
        platformResponse = 'mail was saved to draft';
        break;
      case MailerResponse.sent:

        /// ios only
        platformResponse = 'mail was sent';
        break;
      case MailerResponse.cancelled:

        /// ios only
        platformResponse = 'mail was cancelled';
        break;
      case MailerResponse.android:
        platformResponse = 'intent was successful';
        break;
      default:
        platformResponse = 'unknown';
        break;
    }
    debugPrint("Response is here:  $platformResponse");
  }
}
