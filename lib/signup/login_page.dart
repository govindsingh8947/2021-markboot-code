import 'package:bot_toast/bot_toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/common_widgets.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/pages/homeScreen/adminPages/admin_homepage.dart';
import 'package:markboot/pages/homeScreen/home.dart';
import 'package:markboot/signup/forgot_page.dart';
import 'package:markboot/signup/signup_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController phoneCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //instance is used instead of ()
  CommonWidget commonWidget = CommonWidget();
  late SharedPreferences prefs; //late is added to remove errror
  CommonFunction commonFunction = CommonFunction();
  late String userVerificationId; //late is added to ignore error
  bool isLoading = false;
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
    //double width = MediaQuery.of(context).size.width;
    Widget appLogo() {
      return Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.21,
            width: MediaQuery.of(context).size.width * 0.58,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/icons/mb_icon-r.png"),
                  fit: BoxFit.fitWidth),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.05,
          )
          // RichText(
          //   text: TextSpan(
          //       text: 'Mark',
          //       style: TextStyle(
          //           color: Colors.black,
          //           fontSize: 40,
          //           fontWeight: FontWeight.bold),
          //       children: <TextSpan>[
          //         TextSpan(
          //           text: 'Boot',
          //           style: TextStyle(
          //               color: Color(CommonStyle().new_theme),
          //               fontSize: 40,
          //               fontWeight: FontWeight.bold),
          //         )
          //       ]),
          // ),
        ],
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Color(CommonStyle()
            .new_theme), //Color(CommonStyle().introBackgroundColor),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 70,
                ),
                appLogo(),
                SizedBox(
                  height: 20,
                ),
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50, 0, 50, 12),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      cursorColor: Colors.white,
                      controller: phoneCont,
                      textAlign: TextAlign.left,
                      decoration: InputDecoration(
                        hintText: "Enter The Phone No",

                        hintStyle: TextStyle(color: Colors.white),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.amberAccent.shade400),
                        ),
                        contentPadding: EdgeInsets.only(left: 0),
                        //icon: Icon(Icons.person, color: Colors.white,),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(50, 0, 50, 12),
                  child: TextField(
                    obscureText: true,
                    controller: passCont,
                    style: TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
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
                      //icon: Icon(Icons.lock, color: Colors.white,),
                    ),
                  ),
                ),
//            commonWidget.commonTextField(controller: passCont,hintText: "Password",obscureText: true),
                SizedBox(
                  height: 30,
                ),
                Container(
                  width: isLoading ? 100 : 220,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  height: 40,
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(20)
//              ),

                  child: isLoading
                      ? LoadingFlipping.circle(
                          borderSize: 5,
                          borderColor:
                              Colors.amberAccent.shade400, //Colors.blue,
                        )
                      // ignore: deprecated_member_use
                      : RaisedButton(
                          color: Colors.amberAccent[
                              400], // Color(CommonStyle().lightYellowColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {
                            FocusScope.of(context)
                                .unfocus(); // closing the keyboard
                            userLogin();
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff051094),
                            ),
                          ),
                        ),
                ),
                SizedBox(
                  height: 45,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Don't have an account?",
                          style: TextStyle(color: Colors.white, fontSize: 15),
                        ),
                        Text(
                          " Sign up",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.amberAccent[400],
                              fontSize: 15),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 0,
                ),
                GestureDetector(
                  onTap: () {
                    if (phoneCont.text.length == 10) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ForgotPasswordPage(phone: phoneCont.text),
                        ),
                      );
                    } else {
                      Fluttertoast.showToast(
                          msg:
                              "Please Enter your registered mobile number above and then try again!");
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Forgot Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  userLogin() async {
    try {
      debugPrint("userLogin");
      String phoneNo = phoneCont.text.trim().toString();
      String password = passCont.text.trim().toString();
      print(password);
      if (phoneNo.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Enter phone number",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (password.isEmpty) {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Enter password",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      }

      // Show Progress Dialog
      commonFunction.showProgressDialog(isShowDialog: true, context: context);
      //..........
      if (_isNumeric(phoneNo)) {
        print("hello");
        login_user(phoneNo, password);
      } else {
        print("admin");
        admin_user(phoneNo, password);
      }
    } catch (e) {
      debugPrint("Exception (LoginPage) - ${e.toString()}");
    }
    commonFunction.showProgressDialog(isShowDialog: false, context: context);
  }

  // ignore: non_constant_identifier_names
  login_user(String phoneNo, String password) async {
    print(phoneNo);
    try {
      setState(() {
        isLoading = true;
      });
      DocumentSnapshot snapshot =
          await _firestore.collection("Users").doc("+91$phoneNo").get();
      debugPrint("SNAPSHOT ${snapshot.exists}");
      if (snapshot.exists == true) {
        var userData = snapshot.data() as dynamic;
        //String userPassword = userData["password"] ?? "";
        debugPrint("USERDATA ${userData["emailId"]}");
        UserCredential authResult = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
                email: userData["emailId"], password: password);
        if (authResult.user != null) {
          prefs.setString("userName", userData["name"] ?? "");
          prefs.setString("userPhoneNo", "+91$phoneNo");
          // prefs.setString("userPhoneNo", "+91$phoneNo" ?? "");  opertaor ?? removed above
          prefs.setString("userEmailId", userData["emailId"] ?? "");
          prefs.setString("userPassword", password); //?? " " is removed
          prefs.setString("userInviteCode", userData["inviteCode"] ?? "");
          prefs.setString("userId", userData["userId"] ?? "");
          prefs.setString("referralCode", userData["referralCode"] ?? "");
          prefs.setBool("isLogin", true);
          print(prefs.getString("userPhoneNo"));
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false);
        } else {
          setState(() {
            isLoading = false;
          });
          debugPrint("LOGIN UNSUCCESSFUL");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Phone number doesn't exist.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint("Exception :(login_user) -> $e");
      if (e.toString().contains("ERROR_WRONG_PASSWORD")) {
        BotToast.showText(
            text:
                "The password is invalid or the user does not have a password",
            contentColor: Colors.red);
      }
    }
  }

  admin_user(String emialNo, String password) async {
    setState(() {
      isLoading = true;
    });
    bool isLogin = false;

    DocumentSnapshot snapshot = await _firestore
        .collection("Agent")
        .doc("wOJeT8psKFbGWLvOEW8EKzxY4gH2")
        .get();
    debugPrint("SNAPSHOT ${snapshot.exists}");
    if (snapshot.exists == true) {
      Map<String, dynamic> userData =
          (snapshot.data() as dynamic) as Map<String, dynamic>;
      String userPassword = userData["password"] ?? "";
      debugPrint("USERDATA $userData");
      if (password == userPassword) {
        prefs.setString("userName", "Admin");
        prefs.setString("userPhoneNo", "+918279772115");
        prefs.setString("userEmailId", emialNo);
        prefs.setString("userPassword", password);
        prefs.setString("userInviteCode", "");
        prefs.setBool("isAdminLogin", true);
        prefs.setBool("isLogin", false);
        //prefs.setBool("isLogin", true);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage()),
            (route) => false);
      } else {
        setState(() {
          isLoading = false;
        });
        Fluttertoast.showToast(
            msg: "Sorry coudn\'t login Please enter valid credentials",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        debugPrint("LOGIN UNSUCCESSFUL");
      }
    } else {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(
          msg: "Email ID doesn't exist.",
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }

    // FirebaseAuth auth = FirebaseAuth.instance;
    // AuthResult authResult = await auth.signInWithEmailAndPassword(
    //     email: emialNo, password: password);
    // await authResult.user.reload();
    // FirebaseUser user = authResult.user;
    // debugPrint("authRes - ${user.isEmailVerified}");
    // debugPrint("authRes - ");

    // if (authResult.user.isEmailVerified == true) {
    //   debugPrint("HIII");
    //   QuerySnapshot querySnapshot =
    //       await Firestore.instance.collection("Agent").getDocuments();
    //   for (DocumentSnapshot snapshot in querySnapshot.documents) {
    //     debugPrint("ID ${snapshot.documentID} ,, ${authResult.user.uid}");
    //     if (snapshot.documentID == authResult.user.uid) {
    //       isLogin = true;
    //       prefs.setString("userName", "Admin");
    //       prefs.setString("userPhoneNo", "+918279772115");
    //       prefs.setString("userEmailId", emialNo);
    //       prefs.setString("userPassword", password);
    //       prefs.setString("userInviteCode", "");
    //       prefs.setBool("isAdminLogin", true);
    //       prefs.setBool("isLogin", false);
    //       await commonFunction.showProgressDialog(
    //           isShowDialog: false, context: context);
    //       Navigator.pushAndRemoveUntil(
    //           context,
    //           MaterialPageRoute(builder: (context) => AdminHomePage()),
    //           (route) => false);
    //       break;
    //     }
    //   }
    //}
    // if (isLogin == false) {
    //   Fluttertoast.showToast(
    //       msg: "please try again",
    //       backgroundColor: Colors.red,
    //       textColor: Colors.white);
    // }
  }
}
