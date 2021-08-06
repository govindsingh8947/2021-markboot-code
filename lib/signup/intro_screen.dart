import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/main.dart';
import 'package:markboot/pages/homeScreen/adminPages/admin_homepage.dart';
import 'package:markboot/pages/homeScreen/home.dart';
import 'package:markboot/signup/login_page.dart';
import 'package:markboot/signup/signup_page.dart';
import 'package:rxdart/rxdart.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// This is supposed to send notifications to the user but for some reason this is not working
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin(); //flutter_messaging dependencies

// Streams are created so that app can respond to notification-related events since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>(); //rxdart dependencies

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

/*  const MethodChannel platform =//use services library      edited new
    MethodChannel('dexterx.dev/flutter_local_notifications_example');  */

NotificationAppLaunchDetails notificationAppLaunchDetails =
    NotificationAppLaunchDetails(false, "");

class ReceivedNotification {
  final int id;
  final String? title;
  final String? body;
  final String? payload;

  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });
}

String? selectedNotificationPayload;

Future<void> main() async {
  // await WidgetsFlutterBinding.ensureInitialized();
}

class IntroPage extends StatefulWidget {
  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  late double _width = 0;
  late double _height = 0;
  late SharedPreferences prefs;
  CommonFunction commonFunction = CommonFunction();
  bool isShowInitProgress = false;

  List<String> introImages = [
    "assets/icons/purchase.png",
    "assets/icons/money.png",
    "assets/icons/person.png"
  ];

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  Future<void> init() async {
    _requestIOSPermissions();
    _configureDidReceiveLocalNotificationSubject();
    _configureSelectNotificationSubject();

    await initLocalNotification();

    _firebaseMessaging.subscribeToTopic("all");
    prefs = await SharedPreferences.getInstance();
    print("dododod");
    print(await SharedPreferences.getInstance());
    bool isLogin = prefs.getBool("isLogin") ?? false;
    bool isAdminLogin = prefs.getBool("isAdminLogin") ?? false;

    // If the user is loged in then he will be directed to the homepage()
    if (isLogin) {
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      });
      // If the admin was loged in then he will be sent to the adminhomePage()
    } else if (isAdminLogin) {
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AdminHomePage()));
      });

      // Third case no one is loged in and we have to show the login signup page
    } else {
      visibilitybool = true;
      isShowInitProgress = false;
      setState(() {});
    }
  }

  void _requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((ReceivedNotification receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title.toString())
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body.toString())
              : null,
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              child: Text('Ok'),
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                //   moveToMyLoanPage();
              },
            )
          ],
        ),
      );
    });
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      // ignore: unnecessary_brace_in_string_interps
      debugPrint("Notification : DATA - ${payload}");
    });
  }

  initLocalNotification() async {
    notificationAppLaunchDetails = await flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails() as NotificationAppLaunchDetails;

    AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    // Note: permissions aren't requested here just to demonstrate that can be done later using the `requestPermissions()` method
    // of the `IOSFlutterLocalNotificationsPlugin` class
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(
              id: id, title: title, body: body, payload: payload));
        });
    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid =
            new AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: initializationSettingsIOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      if (payload != null) {
        debugPrint('notification payload: ' + payload);
      }
      selectNotificationSubject.add(payload.toString());
    });
  }

  Future<void> _showNotification(String title, String body) async {
    debugPrint("ShowNotificationPUB");
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.max, priority: Priority.high, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(0, title, body, platformChannelSpecifics, payload: 'item x');
  }

  @override
  void initState() {
    // _firebaseMessaging.onMessage.listen(
    //   onBackgroundMessage: (Map<String, dynamic> message) async {
    //     print("onMessage: $message");
    //     _showNotification(
    //         message["notification"]["title"], message["notification"]["body"]);
    //   },
    //   onLaunch: (Map<String, dynamic> message) async {
    //     print("onLaunch: $message");
    //   },
    //   onResume: (Map<String, dynamic> message) async {
    //     print("onResume: $message");
    //   },
    // );

    _firebaseMessaging.requestPermission(
        sound: true, badge: true, alert: true, provisional: true);
    _firebaseMessaging.onTokenRefresh.listen((event) {
      print(event);
    });
    // _firebaseMessaging.onIosSettingsRegistered
    //     .listen((IosNotificationSettings settings) {
    //   print("Settings registered: $settings");
    // });
    _firebaseMessaging.getToken().then((token) {
      print("TOKen $token");
    });

    init();
    super.initState();
  } // Call to the custom init function and some code about sending a notification

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor :Color(0xff051094),
      backgroundColor: Color(CommonStyle().new_theme),
      body: isShowInitProgress == false
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                //mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[    
                   SizedBox(
                    height: MediaQuery.of(context).size.height * 0.03,
                  ),              
                  header(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.01,
                  ),
                  swiperBody(),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  bottom()
                ],
              ),
            )

          // This code runs initially when the app starts and then instantly isShowInitProgress becomes false that means the above code runs
          : Center(
              child: Container(
                width: 30,
                height: 30,
                child: LoadingFlipping.circle(
                  borderColor: Colors.blue,
                  size: 50,
                  borderSize: 5,
                ),
              ),
            ),
    );
  }

  Widget header() {
    return Container(
      //   color: Colors.blue,
      //padding: EdgeInsets.all(8),
      //width: MediaQuery.of(context).size.width,
      //height: MediaQuery.of(context).size.height * 0.09,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.21,
            width: MediaQuery.of(context).size.width*0.58,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage("assets/icons/mb_icon-r.png"),
                  fit: BoxFit.fitWidth
                  ),
            ),
          )
          // Text(
          //   "Mark",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //       color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
          // ),
          // Text(
          //   "Boot",
          //   textAlign: TextAlign.center,
          //   style: TextStyle(
          //       color: Colors.yellow,
          //       fontSize: 40,
          //       fontWeight: FontWeight.bold),
          // ),
        ],
      ),
    );
  }

  Widget swiperBody() {
    return Container(
     // color: Colors.black,

      height: MediaQuery.of(context).size.height * 0.42,
      child: Swiper(
        autoplay: true,
        pagination: SwiperPagination(
            builder: DotSwiperPaginationBuilder(
                color: Colors.white,
                activeColor: Color(CommonStyle().lightYellowColor),
                activeSize: 13.0,
                size: 10)),
         itemWidth: 250,
         itemHeight: 270,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 100,            
            height: 270,
            padding: EdgeInsets.all(50),
            //margin: EdgeInsets.only(left: 30, right: 30, bottom: 40),
            child: Image(height: 200,width: 200,image: AssetImage(introImages[index]),),
            // child: ClipOval(
              
            //     child: Image.asset(
                  
            //   introImages[index],
            // )),
          );
        },
        itemCount: 3,
        scale: 0.2,
        fade: 0.5,
      ),
    );
  }

  Widget bottom() {
    if (!visibilitybool) {
      return LoadingFlipping.circle(
        borderSize: 5,
        borderColor: Colors.amberAccent, //Colors.blue,
      );
    }
    return Visibility(
      visible: visibilitybool,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: <Widget>[
            Center(
              child: Container(
                width: 200,
                height: MediaQuery.of(context).size.height * 0.06,
                // ignore: deprecated_member_use
                child: RaisedButton(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                  child: Text(
                    "Login",
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
              height: 10,
            ),
            Container(
              width: 200,
              height: MediaQuery.of(context).size.height * 0.06,
              // ignore: deprecated_member_use
              child: RaisedButton(
                color: Colors.amberAccent[400],
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(60)),
                onPressed: () async {
//                await CommonFunction().sendAndRetrieveMessage("this is body1","this is title1");
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpPage()));
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
          ],
        ),
      ),
    );
  }
}
