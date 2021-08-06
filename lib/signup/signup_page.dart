import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/signup/login_page.dart';
import 'package:markboot/signup/otp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

CommonFunction c = CommonFunction();

class SignUpPage extends StatefulWidget {
  //User user;
  //String pass;
//  SignUpPage({
  //required this.user,
  //required this.pass
  // }); //required is added to remove error
  //const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isEmail = true;
  TextEditingController nameCont = TextEditingController();
  TextEditingController pass2Cont = TextEditingController();
  TextEditingController emailCont = TextEditingController();
  TextEditingController phoneCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  TextEditingController inviteCodeCont = TextEditingController();
  late SharedPreferences prefs; //late is added
  //CommonFunction commonFunction = CommonFunction();
  //CommonWidget commonWidget = CommonWidget();
  var isLoading = false; //it may be bool
  //Firebase
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(CommonStyle().new_theme),
      body: Container(
        height: MediaQuery.of(context).size.height,
        color: Color(CommonStyle().new_theme),
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: 10,
              ),
              appLogo(context),

              /*
      Container(
        margin: EdgeInsets.only(left: 30, right: 30),
        padding: EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: Color(CommonStyle().signuptextfield)),
              
      )  */

              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: nameCont,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "Name",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.amberAccent.shade400),
                    ),
                    contentPadding: EdgeInsets.only(left: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: phoneCont,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "Phone No.",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.amberAccent.shade400),
                    ),
                    contentPadding: EdgeInsets.only(left: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: emailCont,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: isEmail ? "Email Id" : "Phone No.",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.amberAccent.shade400),
                    ),
                    contentPadding: EdgeInsets.only(left: 0),
                  ),
                ),
              ),
              isEmail
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        obscureText: true,
                        controller: passCont,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintText: "Enter Password",
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent.shade400),
                          ),
                          contentPadding: EdgeInsets.only(left: 0),
                        ),
                      ),
                    )
                  : SizedBox(),
              isEmail
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(40, 0, 40, 12),
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        cursorColor: Colors.white,
                        obscureText: true,
                        controller: pass2Cont,
                        textAlign: TextAlign.left,
                        decoration: InputDecoration(
                          hintText: "Re-enter Password",
                          hintStyle: TextStyle(color: Colors.white),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.amberAccent.shade400),
                          ),
                          contentPadding: EdgeInsets.only(left: 0),
                        ),
                      ),
                    )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 0, 40, 8),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: Colors.white,
                  controller: inviteCodeCont,
                  textAlign: TextAlign.left,
                  decoration: InputDecoration(
                    hintText: "Invite Code (optional)",
                    hintStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.amberAccent.shade400),
                    ),
                    contentPadding: EdgeInsets.only(left: 0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: () async {
                    await canLaunch("https://markboot.com")
                        ? await launch("https://markboot.com")
                        : throw 'Could not launch "https://markboot.com"';
                  },
                  child: RichText(
                    text: TextSpan(
                        text: "By signing up, you agree our ",
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                              text: "terms",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: () async {
                    await canLaunch("https://markboot.com")
                        ? await launch("https://markboot.com")
                        : throw 'Could not launch "https://markboot.com"';
                  },
                  child: RichText(
                    text: TextSpan(
                        text: "and ",
                        style: TextStyle(color: Colors.white),
                        children: [
                          TextSpan(
                              text: "privacy policy",
                              style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold))
                        ]),
                  ),
                ),
              ),
              SizedBox(
                height: 24,
              ),
              isLoading
                  ? CircularProgressIndicator()
                  : Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 40),
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
                          onPressed: () {
                            c.showProgressDialog(
                                isShowDialog: true, context: context);
                            FocusScope.of(context)
                                .unfocus(); // This is used to hide the keyboard once the signup button is pressed
                            signUp(context, emailCont, passCont, pass2Cont,
                                nameCont, inviteCodeCont, phoneCont);
                          },
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff051094),
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(
                height: 15,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "Existing User?  ",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                      Text(
                        " Sign in",
                        style: TextStyle(
                            decorationColor: Colors.white,
                            decoration: TextDecoration.underline,
                            color: Colors.white,
                            fontSize: 15),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ),
      ),
    );
  }
}

Widget appLogo(context) {
  return Container(
    //height: 50,
    child: Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Container(
          height: MediaQuery.of(context).size.height * 0.21,
          width: MediaQuery.of(context).size.width * 0.58,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/icons/mb_icon-r.png"),
                fit: BoxFit.fitWidth),
          ),
        ),
        Container(
          //   color: Colors.blue,
          //padding: EdgeInsets.all(8),
          //width: MediaQuery.of(context).size.width, this is ignored due to error
          // height: _height * .10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   "Mark",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //       color: Color(CommonStyle().markcolor),
              //       fontSize: 40,
              //       fontWeight: FontWeight.bold),
              // ),
              // Text(
              //   "Boot",
              //   textAlign: TextAlign.center,
              //   style: TextStyle(
              //       color: Color(CommonStyle().signupbootcolor),
              //       fontSize: 40,
              //       fontWeight: FontWeight.bold),
              // ),
            ],
          ),
        )
      ],
    ),
  );
}

signUp(context, emailCont, passCont, pass2Cont, nameCont, inviteCodeCont,
    phoneCont) async {
  if (phoneCont != null) {
    var email = emailCont.text.trim();
    var pass1 = passCont.text.trim();
    var pass2 = pass2Cont.text.trim();
    String name = nameCont.text.trim().toString();
    String inviteCode = inviteCodeCont.text.trim().toString();
    String phoneNo = phoneCont.text.trim().toString();
    List<DocumentSnapshot> snaps = await CommonFunction().getPost("Users");

    for (DocumentSnapshot snap in snaps) {
      // print(phoneNo);
      if (snap.id == "+91$phoneNo") {
        // documentID is replaced by id
        Fluttertoast.showToast(msg: "User already exists try log in");
        return;
      }
    }
    if (name.isEmpty) {
      Fluttertoast.showToast(
          msg: "Enter name.",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    } else if (phoneNo.isEmpty) {
      Fluttertoast.showToast(
          msg: "Enter phone number.",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    } else if (email.isEmpty) {
      Fluttertoast.showToast(
          msg: "Enter email id.",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    } else if (pass1.isEmpty) {
      Fluttertoast.showToast(
          msg: "Enter password.",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      return;
    } else {
      if (pass1 == pass2) {
        if (pass1.length < 6) {
          Fluttertoast.showToast(msg: "please enter a strong password");
          return;
        }
        try {
          String email = emailCont.text.trim().toString();
          String name = nameCont.text.trim().toString();
          String phoneNo = phoneCont.text.trim().toString();
          String password = passCont.text.trim().toString();
          String inviteCode = inviteCodeCont.text.trim().toString();

          if (name.isEmpty) {
            Fluttertoast.showToast(
                msg: "Enter name.",
                backgroundColor: Colors.red,
                textColor: Colors.white);
            return;
          } else if (phoneNo.isEmpty) {
            Fluttertoast.showToast(
                msg: "Enter phone number.",
                backgroundColor: Colors.red,
                textColor: Colors.white);
            return;
          } else {
            print("final");
            print(phoneNo);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return OTPScreen(phoneNo, email, name, password, inviteCode);
            }));
          }
        } catch (e) {
          debugPrint("Exception : (SignUpService) - ${e.toString()}");
        }
      }
    }
  }

  //old code
  /*   if (isEmail) {
      var email = emailCont.text.trim();
      var pass1 = passCont.text.trim();
      var pass2 = pass2Cont.text.trim();
      String name = nameCont.text.trim().toString();
      String inviteCode = inviteCodeCont.text.trim().toString();
      String phoneNo = phoneCont.text.trim().toString();
      List<DocumentSnapshot> snaps = await CommonFunction().getPost("Users");   */

  // This function is called always to check if the phone number user entered is not already registered
  /*    for (DocumentSnapshot snap in snaps) {
        if (snap.documentID == "+91$phoneNo") {
          Fluttertoast.showToast(msg: "User already exists try log in");
          return;
        } 
      } */
  /*   if (name.isEmpty) {
        Fluttertoast.showToast(
            msg: "Enter name.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (phoneNo.isEmpty) {
        Fluttertoast.showToast(
            msg: "Enter phone number.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (email.isEmpty) {
        Fluttertoast.showToast(
            msg: "Enter email id.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (pass1.isEmpty) {
        Fluttertoast.showToast(
            msg: "Enter password.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else {
        if (pass2 == pass1) {
          if (pass1.length < 6) {
            Fluttertoast.showToast(msg: "please enter a strong password");
            return;
          }
          try {
            setState(() {
              isLoading = true;
            });
            FirebaseAuth auth = FirebaseAuth.instance;
            AuthResult authResult = await auth.createUserWithEmailAndPassword(
                email: email, password: pass1);
            FirebaseUser user = await auth.currentUser();
            await user.reload();
            try {
              await user.sendEmailVerification();
              Fluttertoast.showToast(
                  msg: "verification email sent please verify");
              setState(() {
                isLoading = false;
              });
              Future.delayed(Duration(seconds: 0), () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return VerificationConfirmPage(email, pass1, phoneNo, name,
                      inviteCode: inviteCode);
                }));
              });
              if (user.isEmailVerified) {
                print("verified");
              } else {
                print("not verified");
              }
            } catch (err) {
              setState(() {
                isLoading = false;
              });
              Fluttertoast.showToast(msg: err.message);
              print(err);
            }
          } catch (err) {
            setState(() {
              isLoading = false;
            });
            Fluttertoast.showToast(msg: err.message);
            print(err);
          }
        } else if (pass1 != pass2) {
          Fluttertoast.showToast(msg: "Password do not match");
          return;
        }
      }
    } else {
      try {
        String name = nameCont.text.trim().toString();
        String phoneNo = emailCont.text.trim().toString();
        //String password = passCont.text.trim().toString();
        String inviteCode = inviteCodeCont.text.trim().toString();

        if (name.isEmpty) {
          Fluttertoast.showToast(
              msg: "Enter name.",
              backgroundColor: Colors.red,
              textColor: Colors.white);
          return;
        } else if (phoneNo.isEmpty) {
          Fluttertoast.showToast(
              msg: "Enter phone number.",
              backgroundColor: Colors.red,
              textColor: Colors.white);
          return;
        }
        //else if (email.isEmpty) {
        //  Fluttertoast.showToast(
        //      msg: "Enter email id.",
        //      backgroundColor: Colors.red,
        //      textColor: Colors.white);
        //  return;
        //} else if (password.isEmpty) {
        //  Fluttertoast.showToast(
        //      msg: "Enter password.",
        //      backgroundColor: Colors.red,
        //      textColor: Colors.white);
        //  return;
        //}

        if (widget.user.isEmailVerified == false) {
          AuthResult authResult = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
                  email: widget.user.email, password: widget.pass);
          if (authResult.user.isEmailVerified == false) {
            BotToast.showText(text: "Please verify your email id.");
            return;
          }
        }

        // show ProgressBar
        commonFunction.showProgressDialog(isShowDialog: true, context: context);

        DocumentSnapshot snapshot =
            await _firestore.collection("Users").document("+91$phoneNo").get();
        debugPrint("SNAPSHOT ${snapshot.exists}");
        if (snapshot.exists == false) {
          prefs.setString("userName", name);
          prefs.setString("userPhoneNo", "+91$phoneNo");
          prefs.setString("userEmailId", widget.user.email);
          prefs.setString("userPassword", widget.pass);
          prefs.setString("userInviteCode", inviteCode);
          Map<String, String> userData = {
            "name": name,
            "phoneNo": phoneNo,
            "emailId": widget.user.email,
            "inviteCode": inviteCode,
            "userId": widget.user.uid.toString()
          };
          await FirebaseFirestore.instance
              .collection("Users")
              .document("+91$phoneNo") //change document to docs
              .setData(userData, merge: true); //setdata to set
          await commonFunction.showProgressDialog(
              isShowDialog: false, context: context);
          prefs.setBool("isLogin", true);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false);
        } else {
          await commonFunction.showProgressDialog(
              isShowDialog: false, context: context);
          Fluttertoast.showToast(msg: "Mobile no already in used");
        }
      } catch (e) {
        debugPrint("Exception : (SignUpService) - ${e.toString()}");
      }
    }
  }
}

*/
}
