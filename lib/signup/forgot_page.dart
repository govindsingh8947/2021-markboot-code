import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/pages/homeScreen/home.dart';
import 'package:pinput/pin_put/pin_put.dart';
import 'package:timer_button/timer_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  ForgotPasswordPage({required this.phone});
  String phone;

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

String _otp = null as String;

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late String pass, repass;
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode = ""; //verification is initialized
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();
  final BoxDecoration pinPutDecoration = BoxDecoration(
    color: const Color.fromRGBO(43, 46, 66, 1),
    borderRadius: BorderRadius.circular(10.0),
    border: Border.all(
      color: const Color.fromRGBO(126, 203, 224, 1),
    ),
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue.shade900,
      key: _scaffoldkey,
      // appBar: AppBar(
      //   title: Text('OTP Verification'),
      // ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.21,
              width: MediaQuery.of(context).size.width * 0.58,
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/icons/mb_icon-r.png"),
                    fit: BoxFit.fitWidth),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 50, 12),
              child: TextField(
                onChanged: (val) {
                  _otp = val;
                },
                obscureText: false,
                style: TextStyle(color: Colors.white),
                cursorColor: Colors.white,
                textAlign: TextAlign.left,
                decoration: InputDecoration(
                  hintText: "Enter OTP",
                  hintStyle: TextStyle(color: Colors.white),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.amberAccent.shade400),
                  ),
                  contentPadding: EdgeInsets.only(left: 0),
                  //icon: Icon(Icons.lock, color: Colors.white,),
                ),
              ),
            ),
          ),
          // GestureDetector(
          //   onTap: () {
          //     _verifyPhone();
          //   },
          //   child: Text(
          //     " Resend OTP",
          //     style: TextStyle(
          //         decoration: TextDecoration.underline,
          //         color: Colors.white,
          //         fontSize: 15),
          //   ),
          // ),
           new TimerButton(
                            label: "Resend OTP",
                            timeOutInSeconds: 30,
                            buttonType: ButtonType.FlatButton,
                            onPressed: () {
                             _verifyPhone();
                            },
                            disabledColor: Colors.red,
                            color: Colors.transparent,
                            disabledTextStyle: new TextStyle(fontSize: 15.0,color: Colors.grey),
                            activeTextStyle: new TextStyle(
                                fontSize: 15.0, color: Color(0xFFFFC107)),
                          ),
          SizedBox(height: 60),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 60),
            width: MediaQuery.of(context).size.width,
            height: 40,
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.amberAccent.shade400),
              ),
              // color: Color(CommonStyle().signupbuttonbg),
              //  shape: RoundedRectangleBorder(
              //    borderRadius: BorderRadius.circular(60)),
              onPressed: () async {
                try {
                  await FirebaseAuth.instance
                      .signInWithCredential(PhoneAuthProvider.credential(
                          verificationId: _verificationCode, smsCode: _otp))
                      .then((value) async {
                    if (value.user != null) {
                      print("hemlo g");
                      print(widget.phone);
                      Navigator.pop(context);
                      var snapshot = await FirebaseFirestore.instance
                          .collection("Users")
                          .doc("+91${widget.phone}")
                          .get();
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                          email: (snapshot.data() as dynamic)["emailId"]);
                      print((snapshot.data() as dynamic)["emailId"]);
                      Fluttertoast.showToast(
                          msg:
                              "Reset Link sent to ${(snapshot.data() as dynamic)["emailId"]}",
                          backgroundColor: Colors.black,
                          textColor: Colors.white);
                      Navigator.pop(context);
                    }
                  });
                } catch (e) {
                  FocusScope.of(context).unfocus();
                  _scaffoldkey.currentState! //! is added to avoid error
                      // ignore: deprecated_member_use
                      .showSnackBar(SnackBar(content: Text('invalid OTP')));
                }
              },

              child: Text(
                "Submit",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff051094),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _verifyPhone() async {
    print("helo");
    await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '+91${widget.phone}',
        verificationCompleted: (PhoneAuthCredential credential) async {
          await FirebaseAuth.instance
              .signInWithCredential(credential)
              .then((value) async {
            if (value.user != null) {
              print("done");
            }
          });
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
        },
        codeSent: (verficationID, resendToken) {
          setState(() {
            _verificationCode = verficationID;
          });
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          setState(() {
            _verificationCode = verificationID;
          });
        },
        timeout: Duration(seconds: 120));
  }

  @override
  void initState() {
    super.initState();
    _verifyPhone();
  }
}
