import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/signup/intro_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences prefs; //late is added
  bool isShowInitProgress = true;

  // This is used for sending the notifications to the user of the app
  start() async {    
    return Future.delayed(Duration(seconds: 5), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
        return IntroPage();
      }));
    });
  }
  //Navigator.pushReplacement means it will delete previous route

  @override //when a object is inserted into tree whose state change
  void initState() {
    super.initState();
    start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(CommonStyle().new_theme),
      body: Container(
          alignment: Alignment.center,
          child: SizedBox(
            height: 5000,
            width: 500,
            child: Lottie.asset("assets/Json/splash.json", repeat: false),
          )),
    );
  }
}
