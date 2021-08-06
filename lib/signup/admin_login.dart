import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/common_widgets.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/pages/homeScreen/adminPages/admin_homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  TextEditingController emailCont = TextEditingController();
  TextEditingController passCont = TextEditingController();
  FirebaseFirestore _firestore =
      FirebaseFirestore.instance; //() is removed and instance is used
  CommonWidget commonWidget = CommonWidget();
  late SharedPreferences prefs; //late is added
  CommonFunction commonFunction = CommonFunction();
  bool isShowProgress = false;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 40),
          padding: EdgeInsets.symmetric(
            horizontal: 0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              appLogo(),
              SizedBox(
                height: 20,
              ),
              commonWidget.commonTextField(
                controller: emailCont,
                hintText: "Email",
              ),
              commonWidget.commonTextField(
                  controller: passCont,
                  hintText: "Password",
                  obscureText: true),
              SizedBox(
                height: 30,
              ),
              Container(
                width: MediaQuery.of(context).size.width / 1.2,
                padding: EdgeInsets.symmetric(horizontal: 30),
                height: 50,
                // ignore: deprecated_member_use
                child: RaisedButton(
                  color: Color(CommonStyle().lightYellowColor),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60)),
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    userLogin();
                  },
                  child: Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              GestureDetector(
                onTap: () {
                  forgotPassReset();
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  forgotPassReset() async {
    try {
      if (emailCont.text.trim().isEmpty) {
        Fluttertoast.showToast(
            msg: "Enter email",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      }
      debugPrint("ForgotPassword - called");
      FirebaseAuth auth = FirebaseAuth.instance;
      await auth.sendPasswordResetEmail(email: emailCont.text.trim());
    } catch (e) {
      debugPrint("Exception : (ForgotPassword) -> ${e.toString()}");
    }
  }

  Widget appLogo() {
    return Container(
      height: 50,
      child: Text(
        "Admin Login",
        style: TextStyle(color: Color(CommonStyle().appbarcolor), fontSize: 30),
      ),
    );
  }

  userLogin() async {
    try {
      debugPrint("userLogin");
      String emialNo = emailCont.text.trim().toString();
      String password = passCont.text.trim().toString();
      if (emialNo.isEmpty) {
        Fluttertoast.showToast(
            msg: "Enter email",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (password.isEmpty) {
        Fluttertoast.showToast(
            msg: "Enter password",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      }
      bool isLogin = false;
      // Show Progress Dialog
      commonFunction.showProgressDialog(isShowDialog: true, context: context);
      //..........

      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential authResult = await auth.signInWithEmailAndPassword(
          email: emialNo, password: password);
      //  debugPrint("authRes - ${authResult.user.isEmailVerified}");   ignore due to error
      //admin login
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection("Agent").get();
      //adm=in section to be correct
      /*    if (authResult.user.isEmailVerified == true) {
        debugPrint("HIII");
        QuerySnapshot querySnapshot =
            await FirebaseFirestore.instance.collection("Agent").get();
        for (DocumentSnapshot snapshot in querySnapshot.docs) {
          debugPrint(
              "ID ${snapshot.id} ,, ${authResult.user!.uid}"); //! is added to avoid error
          if (snapshot.id == authResult.user!.uid) {
            //! added to avoid error
            isLogin = true;
            prefs.setString("userName", "Admin");
            prefs.setString("userPhoneNo", "+918279772115");
            prefs.setString("userEmailId", emialNo);
            prefs.setString("userPassword", password);
            prefs.setString("userInviteCode", "");
            prefs.setBool("isAdminLogin", true);
            prefs.setBool("isLogin", false);
            await commonFunction.showProgressDialog(
                isShowDialog: false, context: context);
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AdminHomePage()),
                (route) => false);
            break;
          }
        }
      }   */
      if (isLogin == false) {
        Fluttertoast.showToast(
            msg: "please try again",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "username or password is invalid",
          textColor: Colors.white,
          backgroundColor: Colors.red);
      debugPrint("Exception (LoginPage) - ${e.toString()}");
    }
    await commonFunction.showProgressDialog(
        isShowDialog: false, context: context);
  }
}
