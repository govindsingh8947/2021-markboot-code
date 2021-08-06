import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';

// This is kinda like the more information page of the items displayed in the home page
class TasksPageDetails extends StatefulWidget {
  DocumentSnapshot snapshot;
  String type;
  String subType;
  bool isDisabled; // This is false by default
  TasksPageDetails(
      {required this.snapshot, //@required is replaced
      required this.type, //required is added
      required this.subType, //required is added
      this.isDisabled = false});
  @override
  _TasksPageDetailsState createState() => _TasksPageDetailsState(type, subType);
}

class _TasksPageDetailsState extends State<TasksPageDetails>
    with SingleTickerProviderStateMixin {
  String type, subtype;
  int currentStepNumber = 0;
  _TasksPageDetailsState(this.type, this.subtype);
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String phoneNo;
  late SharedPreferences prefs;
  late Map<String, dynamic> userData;
  bool isApplied = false;
  List<String> pendingPostList = [];
  List<int> textColors = [0xff00E676, 0xffEEFF41, 0xffE0E0E0, 0xffffffff];
  List<int> colors = [
    0xff11232D,
    0xff1C2D41,
    0Xff343A4D,
    0xff4F4641,
    0xff434343,
    0xff2A2A28
  ];
  Random random = Random();
  final picker = ImagePicker();
  ReceivePort _port = ReceivePort();

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: animationController, curve: Curves.ease))
      ..addListener(() {
        setState(() {});
      });
    init();

    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });

    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }

  // Animation ------------------
  late AnimationController animationController;
  bool isCampaign = false;
  late Animation animation;
  late File _workedImgFile = null as File;
  late String name;
  late String emailId;
  late String userId;
  TextEditingController collegeNameCont = TextEditingController();
  TextEditingController showUser2 = TextEditingController();
  TextEditingController showUser1 = TextEditingController();
  TextEditingController Username = TextEditingController();
  TextEditingController Phone_number = TextEditingController();
  TextEditingController code = TextEditingController();
  TextEditingController OrderId = TextEditingController();
  bool isGetCampaignCode = false;
  late String referralCode;
  final key = new GlobalKey<ScaffoldState>();
  Map<String, dynamic> pendingTasksMap = new Map();
  List<String> pendingTaskList = []; //new List();
  bool isSubmitted = false;
  String referredUser = "0";
  Map<String, dynamic> campaignList = new Map();
  late String _localPath;
  late String status = null as String;
  late Color col;
  late String linkRefer;
  late String ongoing;
  int userStatus = 0;
  int maxStatus = 0;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<String> statusList = [];

  Future<void> init() async {
    print("im the one ye");
    // print("hello+${(widget.snapshot.data() as dynamic)}");
    // print("Posts/${widget.type}/${widget.subType}");
    prefs = await SharedPreferences.getInstance();
    name = prefs.getString("userName")!; //null check is added
    name = prefs.getString("userName")!;
    phoneNo = prefs.getString("userPhoneNo")!; //null check is added
    emailId = prefs.getString("userEmailId")!;
    userId = prefs.getString("userId")!;
    referralCode = prefs.getString("referralCode") ?? "";
    // print((widget.snapshot.data() as dynamic)["requiredField"]);
    try {
      List tasks = await CommonFunction()
          .getPost("Posts/${widget.type}/${widget.subType}");
      print("dadadad");
      //print("Tasks =$tasks");
      // print(widget.type);
      // print(widget.subType);
      // print(widget.snapshot.id);
      for (DocumentSnapshot doc in tasks) {
        // print("dadad");
        // //print(doc.data());
        // print(widget.snapshot.id);
        // print((doc.data() as dynamic));
        if (widget.snapshot.id == doc.id) {
          List users = (doc.data() as dynamic)["submittedBy"]; //doc.data[
          //"submittedBy"]; // this will contain a map from the database with all the information
          print("Above the users list printing------------------------------");
          //print(users);

          /// Added this null safety feature !!!!!!!!!!!!! this won't actually run for the gigs section
          print("Inside this ");
          for (var user in users) {
            /// Here changed the name to phone number
            /// Have to change the code over here find the new document verify the uid of the user using his phone
            /// number
            print("dsdasdsa");
            if (phoneNo == user["phoneNo"]) {
              isApplied = true;
              print("121212121212");
              print(user["status"]);
              status = user["status"];
              if (widget.subType == "Tasks") {
                statusList = ['Submitted', 'Accepted'];
                if (status == "applied") {
                  status = "Submitted";
                  currentStepNumber = 0;
                  col = Color(0xff051094);
                } else if (status == "rejected") {
                  status = "Rejected";
                  statusList = ['Submitted', 'Rejected'];
                  col = Colors.red;
                } else {
                  statusList = ['Submitted', 'Accepted'];
                  status = "Accepted";
                  col = Colors.green;
                }
              } else {
                statusList = ['Applied', 'On Going', 'Completed'];
                if (status == "applied") {
                  status = "Applied";
                  currentStepNumber = 0;
                  col = Color(0xff051094);
                } else if (status == "rejected") {
                  statusList = ['Applied', 'Rejected'];
                  status = "Rejected";
                  col = Colors.red;
                } else if (status == "ongoing") {
                  userStatus = user["UserStatus"];
                  status = "ongoing";
                  currentStepNumber = 1;
                  col = Colors.red;
                  linkRefer = user["link"];
                } else {
                  status = "Accepted";
                  currentStepNumber = 2;
                  userStatus = user["UserStatus"];
                  col = Colors.green;
                }
              }
            }
          }
        }
      }
      _localPath =
          (await _findLocalPath()) + Platform.pathSeparator + 'Download';

      final savedDir = Directory(_localPath);
      bool hasExisted = await savedDir.exists();
      if (!hasExisted) {
        savedDir.create();
      }
      setState(() {});
    } catch (e) {
      print("22");
      debugPrint("Exception: (Init) -> $e");
    }
  }

  Future<String> _findLocalPath() async {
    final directory = await getExternalStorageDirectory();
    return directory!.path; //! is added
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print('permission   $info');
  }

  @override
  Widget build(BuildContext context) {
    //print("hello");
    return SafeArea(
      child: Scaffold(
          key: key,
          backgroundColor: Colors.white,
          body: Stack(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  if (animationController.isCompleted) {
                    animationController.reverse();
                  }
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverAppBar(
                        backgroundColor: Colors.transparent,
                        stretch: true,
                        expandedHeight:
                            MediaQuery.of(context).size.height * 0.70,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Visibility(
                              visible:
                                  widget.subType // this is actually never true
                                      .toLowerCase()
                                      .contains("campaign tasks"), // ??
                              // false,
                              child: Text(
                                  "$userStatus/${(widget.snapshot.data() as dynamic)["maxStatus"]}")),
                          background: Hero(
                            tag: "img",
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 30),
                              decoration: BoxDecoration(
                                  color: Colors.white38,
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage((widget.snapshot
                                          .data() as dynamic)["imgUri"]))),
                              child: Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 20,
                                        right: 10,
                                        top: 15,
                                      ),
                                      child: Text(
                                        (widget.snapshot.data()
                                                as dynamic)["taskTitle"] ??
                                            "",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      margin:
                                          EdgeInsets.only(left: 20, right: 50),
                                      child: Row(
                                        children: <Widget>[
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: NetworkImage(
                                                (widget.snapshot.data()
                                                    as dynamic)["logoUri"]),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            (widget.snapshot.data() as dynamic)[
                                                    "companyName"] ??
                                                "",
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.white),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(""),
                                    ),

                                    // This visibility will also be never shown then why is it here!!!
                                    Visibility(
                                      visible: widget.subType
                                          .toLowerCase()
                                          .contains("campaign tasks"), //??
                                      //   false,
                                      child: Container(
                                        height: 80,
                                        padding: EdgeInsets.only(left: 20),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        decoration: BoxDecoration(
                                          color: Colors.white10,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            placeholderBuilder: (context, size, widget) {
                              return Container(
                                height: 150.0,
                                width: 150.0,
                                child: LoadingFlipping.circle(
                                  borderColor: Color(
                                      CommonStyle().new_theme), //Colors.blue,
                                  borderSize: 5,
                                ),
                              );
                            },
                          ),
                        )),
                    SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate(
                            [
                              Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Title",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            // color: Color(
                                            //     CommonStyle().lightYellowColor),
                                            color: Colors.black),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        (widget.snapshot.data()
                                                as dynamic)["taskTitle"] ??
                                            "",
                                        style: TextStyle(
                                            fontSize: 15,
                                            //     color: Color(0xff051094)),
                                            color: Colors.black54),
                                      )
                                    ],
                                  )),
                              SizedBox(
                                height: 10,
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        "Company Name ",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black
                                            // color: Color(
                                            //     CommonStyle().lightYellowColor),
                                            ),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        (widget.snapshot.data()
                                                as dynamic)["companyName"] ??
                                            "",
                                        style: TextStyle(
                                            fontSize: 15,
                                            // color: Color(0xff051094)
                                            color: Colors.black54),
                                      ),
                                    ],
                                  )),
                              SizedBox(
                                height: 10,
                              ),

                              /// This will only be visible for the tournament page when at the moment has no data
                              Visibility(
                                visible: widget.subType
                                    .toLowerCase()
                                    .contains("task"), // ??
                                //   false,
                                child: Container(
                                    margin: EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Visibility(
                                          visible: !widget.subType
                                              .toLowerCase()
                                              .contains("campaign"),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Task",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black
                                                    // color: Color(
                                                    //     CommonStyle().lightYellowColor),
                                                    ),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                (widget.snapshot.data()
                                                            as dynamic)[
                                                        "taskDesc"] ??
                                                    "",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    // color: Color(0xff051094)
                                                    color: Colors.black54),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 10,
                              ),

                              /// This will also be most probably never shown
                              Visibility(
                                visible: widget.subType
                                    .toLowerCase()
                                    .contains("campaign"), // ??
                                //false,
                                child: Container(
                                    margin: EdgeInsets.only(top: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Text(
                                          "Description",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black
                                              // color: Color(
                                              //     CommonStyle().lightYellowColor),
                                              ),
                                        ),
                                        SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          (widget.snapshot.data()
                                                  as dynamic)["taskDesc"] ??
                                              "",
                                          style: TextStyle(
                                              fontSize: 15,
                                              // color: Color(0xff051094)
                                              color: Colors.black54),
                                        ),
                                      ],
                                    )),
                              ),
                              SizedBox(
                                height: 5,
                              ),

                              Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      child: Text(
                                        "Reward",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Container(
                                        child: Row(
                                      children: <Widget>[
                                        Image.asset(
                                          "assets/icons/bank.png",
                                          width: 15,
                                          height: 15,
                                          color: Color(0xff051094),
                                        ),
                                        Text(
                                          (widget.snapshot.data()
                                                  as dynamic)["reward"] ??
                                              "",
                                          style: GoogleFonts.lato(
                                              fontSize: 20,
                                              color: Color(0xff051094)),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              ),

                              SizedBox(
                                height: 10,
                              ),

                              (status != "Applied" &&
                                      status != "Accepted" &&
                                      status != "rejected" &&
                                      status != "Submitted" &&
                                      status != "ongoing" &&
                                      !widget.subType
                                          .toLowerCase()
                                          .contains("campaign"))
                                  ? GestureDetector(
                                      onTap: () async {
                                        _requestPermission();
                                        downloadTaskImg((widget.snapshot.data()
                                            as dynamic)["samplePicUri"]);
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 20, right: 8),
                                        child: GestureDetector(
                                          child: Text(
                                            "See Sample Picture",
                                            style: TextStyle(
                                                color: Color(0xff051094),
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                              // SizedBox(
                              //   height: 30,
                              // ),

                              /// This will also never be visible, it will be visible only in the case of tournament
                              Visibility(
                                visible:
                                    widget.subType == "Tasks" ? true : false,
                                child: isApplied == true
                                    ? Padding(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Status",
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  // color: Color(
                                                  //     CommonStyle().lightYellowColor),
                                                  color: Colors.black),
                                            ),
                                            Text(
                                              status,
                                              style: TextStyle(
                                                  fontSize: 20, color: col),
                                            )
                                          ],
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            height: 50,
                                            child: RaisedButton(
                                              //color: Colors.white,
                                              color: Color(0xff051094),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              onPressed: () {
                                                _launchURL((widget.snapshot
                                                            .data()
                                                        as dynamic)["link"] ??
                                                    "");
                                              },
                                              child: Text(
                                                "Visit Website",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            height: 50,
                                            child: RaisedButton(
                                              color: Color(0xff051094),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              onPressed: () {
                                                if (!widget.isDisabled) {
                                                  if (isApplied == false) {
                                                    if (animationController
                                                        .isCompleted) {
                                                      animationController
                                                          .reverse();
                                                    } else {
                                                      animationController
                                                          .forward();
                                                    }
                                                  }
                                                }
                                              },
                                              child: Text(
                                                "SUBMIT",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                              ),

                              /// I don't know what the person that made this login had in mind but i just removed the exclamation and
                              /// this is working now
                              !(widget.subType == "Campaign Tasks")
                                  ? Text(
                                      "") // this will be shown for all the other cases
                                  : isApplied == false
                                      ? Container(
                                          height: 50,
                                          child: RaisedButton(
                                            //  color: Colors.blueAccent,
                                            color: Color(0xff051094),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            onPressed: () {
                                              apply_post_service_cam();
                                            },
                                            child: Text(
                                              "Apply",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15),
                                            ),
                                          ),
                                        )
                                      : Container(
                                          padding: EdgeInsets.only(bottom: 20),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              if (status == "ongoing")
                                                Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Link:  ",
                                                              style: TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  // color: Color(
                                                                  //     CommonStyle().lightYellowColor),
                                                                  color: Colors
                                                                      .black),
                                                            ),
                                                          ],
                                                        ),
                                                        if (linkRefer != "" ||
                                                            linkRefer != null)
                                                          Expanded(
                                                            child:
                                                                SingleChildScrollView(
                                                                    scrollDirection:
                                                                        Axis.horizontal,
                                                                    child: Text(
                                                                      linkRefer,
                                                                      style: TextStyle(
                                                                          fontSize: 18,
                                                                          //     color: Color(0xff051094)),
                                                                          color: Color(0xff051094)),
                                                                    )),
                                                          )
                                                        else
                                                          Container(),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Row(
                                                            children: [
                                                              if (linkRefer !=
                                                                      "" ||
                                                                  linkRefer !=
                                                                      null)
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    Clipboard.setData(
                                                                        new ClipboardData(
                                                                            text:
                                                                                linkRefer));
                                                                    Fluttertoast
                                                                        .showToast(
                                                                            msg:
                                                                                "copied link to clipboard");
                                                                  },
                                                                  child: Icon(Icons
                                                                      .content_copy),
                                                                )
                                                              else
                                                                Container(),
                                                              IconButton(
                                                                  icon: Icon(Icons
                                                                      .share_rounded),
                                                                  onPressed:
                                                                      () {
                                                                    Share.share(
                                                                      linkRefer,
                                                                    );
                                                                  })
                                                            ],
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                  ],
                                                )
                                              else
                                                Container(),
                                              Divider(
                                                thickness: 5,
                                              ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 10),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Text(
                                                      "Status",
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          // color: Color(
                                                          //     CommonStyle().lightYellowColor),
                                                          color: Colors.black),
                                                    ),
                                                    Text(
                                                      status,
                                                      style: TextStyle(
                                                          fontSize: 20,
                                                          color: col),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: animation != null
                      ? MediaQuery.of(context).size.height *
                          0.5 *
                          animation.value
                      : 0,
                  color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 40,
                          // height: animation != null
                          //     ? MediaQuery.of(context).size.height *
                          //         0.5 *
                          //         animation.value
                          //     : 0, //animation != null ? 50 * animation?.value : 0,
                        ),
                        Container(
                          height: 40,
                          // height: animation != null
                          //     ? MediaQuery.of(context).size.height *
                          //         0.5 *
                          //         animation.value
                          //     : 0, //animation != null ? 50 * animation?.value : 0,
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: TextField(
                            controller: collegeNameCont,
                            onTap: () {},
                            decoration: InputDecoration(hintText: "Email Id"),
                          ),
                        ),
                        (widget.snapshot.data() as dynamic)["requiredField"]
                                .contains("Username")
                            ? Container(
                                height: 40,
                                // height: animation != null
                                //     ? MediaQuery.of(context).size.height *
                                //         0.5 *
                                //         animation.value
                                //     : 0,
                                //animation != null
                                //      ? 50 * animation?.value
                                //       : 0,
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: TextField(
                                  controller: Username,
                                  onTap: () {},
                                  decoration:
                                      InputDecoration(hintText: "Username"),
                                ),
                              )
                            : Container(),
                        (widget.snapshot.data() as dynamic)["requiredField"]
                                .contains("Phone Number")
                            ? Container(
                                height: 40,
                                // height: animation != null
                                //     ? MediaQuery.of(context).size.height *
                                //         0.5 *
                                //         animation.value
                                //     : 0, //animation != null
                                //            ? 50 * animation?.value
                                //          : 0,
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: TextField(
                                  controller: Phone_number,
                                  onTap: () {},
                                  decoration:
                                      InputDecoration(hintText: "Phone Number"),
                                ),
                              )
                            : Container(),
                        (widget.snapshot.data() as dynamic)["requiredField"]
                                .contains("code")
                            ? Container(
                                height: 40,
                                // height: animation != null
                                //     ? MediaQuery.of(context).size.height *
                                //         0.5 *
                                //         animation.value
                                //     : 0, //animation != null
                                //  ? 50 * animation?.value
                                //   : 0,
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: TextField(
                                  controller: code,
                                  onTap: () {},
                                  decoration: InputDecoration(hintText: "code"),
                                ),
                              )
                            : Container(),
                        (widget.snapshot.data() as dynamic)["requiredField"]
                                .contains("Order Id")
                            ? Container(
                                height: 40,
                                // height: animation != null
                                //     ? MediaQuery.of(context).size.height *
                                //         0.5 *
                                //         animation.value
                                //     : 0, //animation != null
                                //? 50 * animation?.value
                                //: 0,
                                padding: EdgeInsets.symmetric(horizontal: 40),
                                child: TextField(
                                  controller: OrderId,
                                  onTap: () {},
                                  decoration:
                                      InputDecoration(hintText: "Order Id"),
                                ),
                              )
                            : Container(),
                        SizedBox(
                          height: 40,
                          // height: animation != null
                          //     ? MediaQuery.of(context).size.height *
                          //         0.5 *
                          //         animation.value
                          //     : 0, //animation != null ? 20 * animation?.value : 0,
                        ),
                        GestureDetector(
                            onTap: () {
                              showPickImageDialog(_workedImgFile);
                            },
                            child: showCamera(_workedImgFile)),
                        SizedBox(
                          height: 40,
                          // height: animation != null
                          //     ? MediaQuery.of(context).size.height *
                          //         0.5 *
                          //         animation.value
                          //     : 0, //animation != null ? 40 * animation.value : 0,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 60),
                          height: 40,
                          // height: animation != null
                          //     ? MediaQuery.of(context).size.height *
                          //         0.5 *
                          //         animation.value
                          //     : 0, //50 * animation.value,
                          width: MediaQuery.of(context).size.width,
                          child: RaisedButton(
                            //color: Color(CommonStyle().blueColor),
                            color: Color(0xff051094),

                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                            onPressed: () {
                              debugPrint("Pressed");
                              FocusScope.of(context).unfocus();
                              if (collegeNameCont.text.isEmpty ||
                                  ((widget.snapshot.data()
                                              as dynamic)["requiredField"]
                                          .contains("Username") &&
                                      Username.text.length == 0) ||
                                  ((widget.snapshot.data()
                                              as dynamic)["requiredField"]
                                          .contains("Phone Number") &&
                                      Phone_number.text.length == 0) ||
                                  ((widget.snapshot.data()
                                              as dynamic)["requiredField"]
                                          .contains("code") &&
                                      code.text.length == 0) ||
                                  ((widget.snapshot.data()
                                              as dynamic)["requiredField"]
                                          .contains("Order Id") &&
                                      OrderId.text.length == 0)) {
                                Fluttertoast.showToast(
                                    msg: "Enter all fields",
                                    backgroundColor: Colors.red,
                                    textColor: Colors.white);
                                return;
                              } else {
                                applyPostService();
                              }
                            },
                            child: Text(
                              "Submit",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }

  Widget showCamera(fileImg) {
    return Center(
        child: fileImg == null
            ? Container(
                width: 100,
                height: 80,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10)),
                child: Container(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      "assets/icons/camera.png",
                      width: 20,
                      height: 20,
                      fit: BoxFit.cover,
                    )),
              )
            : Container(
                width: 100,
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white38)),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      fileImg,
                      fit: BoxFit.fill,
                    )),
              ));
  }

  showPickImageDialog(showfileImg) {
    return showDialog(
        context: context,
        builder: (context) {
          return Material(
            color: Colors.transparent,
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xff051094),
                    borderRadius: BorderRadius.circular(10)),
                height: 260,
                width: 200,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        pickImageGallery(showfileImg);
                      },
                      child: Text("Gallery"),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    RaisedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        pickImageCamera(showfileImg);
                      },
                      child: Text("Camera"),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  pickImageGallery(pickFileImg) async {
    try {
      final pickedFile =
          await picker.getImage(source: ImageSource.gallery, imageQuality: 30);

      setState(() {
        _workedImgFile = File(pickedFile!.path); //! is added
      });
    } catch (e) {
      debugPrint("Exception : (pickImage) -> $e");
    }
  }

  pickImageCamera(showfileImg) async {
    try {
      final pickedFile =
          await picker.getImage(source: ImageSource.camera, imageQuality: 30);

      setState(() {
        _workedImgFile = File(pickedFile!.path); //! is added
      });
    } catch (e) {
      debugPrint("Exception : (pickImage) -> $e");
    }
  }

  Widget bottomButton(context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      color: Colors.white,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              height: 50,
              child: RaisedButton(
                color: Color(CommonStyle().lightYellowColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: () {
                  // debugPrint("PPPPPP");
                  _launchURL((widget.snapshot.data() as dynamic)["link"] ?? "");
                },
                child: Text(
                  "Visit Website",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            child: Container(
              height: 50,
              child: RaisedButton(
                color: Color(CommonStyle().lightYellowColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: () {
                  FocusScope.of(context).unfocus();
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
          )
        ],
      ),
    );
  }

  Widget singleItem(title, desc, {crossAlign = CrossAxisAlignment.center}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 1),
          color: Color(CommonStyle().blueCardColor), //Color(0xff1f7872),
          borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: crossAlign,
        children: <Widget>[
          Container(
            child: Text(
              title,
              style: TextStyle(
                  color: Color(CommonStyle().lightYellowColor), fontSize: 18),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              desc ?? "",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
          )
        ],
      ),
    );
  }

  _launchURL(url) async {
    if (!url.contains("http")) {
      url = "https://" + url;
    }

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void downloadTaskImg(imgUri) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: imgUri,
        savedDir: _localPath,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification: true,
        // click on notification to open downloaded file (for Android)
      );
      // print(taskId);
      if (taskId != null && taskId.isNotEmpty) {
        Fluttertoast.showToast(
            msg: "Downloading...",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        downloadTaskImgSecond(imgUri);
        Fluttertoast.showToast(
            msg: "Download failed. Tyring Again",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      }
    } on PlatformException catch (error) {
      print(error);
    }
  }

  void downloadTaskImgSecond(imgUri) async {
    try {
      final taskId = await FlutterDownloader.enqueue(
        url: imgUri,
        savedDir: _localPath,
        showNotification:
            true, // show download progress in status bar (for Android)
        openFileFromNotification:
            true, // click on notification to open downloaded file (for Android)
      );
      //print(taskId);
      if (taskId != null && taskId.isNotEmpty) {
        Fluttertoast.showToast(
            msg: "Downloading...",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "Download failed. Try again later!",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      }
    } on PlatformException catch (error) {
      print(error);
    }
  }

  Widget header() {
    return Container(
      height: 500,
      decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
              fit: BoxFit.cover, image: AssetImage("assets/icons/list.png"))),
    );
  }

  Future<void> requestAccessAPI() async {
    try {
      CommonFunction().showProgressDialog(isShowDialog: true, context: context);
      bool isSubmitted = true;
      String referralCode = generateCode();
      userData["referralCode"] = referralCode;
      campaignList[widget.snapshot.id] = false;
      userData["campaignList"] = campaignList;
      String pendigAmount = userData["pendingAmount"] ?? "0";
      pendigAmount = (int.parse(pendigAmount) + //?? "0") +
              int.parse((widget.snapshot.data() as dynamic)["reward"] ?? "0"))
          .toString();
      userData["pendingAmount"] = pendigAmount;

      await _firestore
          .collection("Users")
          .doc(phoneNo)
          .set(userData, SetOptions(merge: true))
          .whenComplete(() {
        isApplied = true;
        pendingPostList.add((widget.snapshot as dynamic).id.toString());
        prefs.setStringList("pendingTasks", pendingPostList);
        prefs.setString("referralCode", referralCode);
        isGetCampaignCode = true;
        setState(() {});
      }).catchError((error) {
        isSubmitted = false;
      });

      if (isSubmitted == true) {
        Fluttertoast.showToast(
            msg: "Access successfully",
            backgroundColor: Colors.green,
            textColor: Colors.white);
      } else {
        Fluttertoast.showToast(
            msg: "please try again",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
// update post data
    } catch (e) {
      debugPrint("Exception : (ReqAccessAPI)> $e");
    }
    CommonFunction().showProgressDialog(isShowDialog: false, context: context);
  }

  String generateCode() {
    List<String> abc = [
      "A",
      "B",
      "C",
      "D",
      "E",
      "F",
      "G",
      "H",
      "I",
      "J",
      "K",
      "L",
      "M",
      "N",
      "O",
      "P",
      "Q",
      "R",
      "S",
      "T",
      "U",
      "V",
      "W",
      "X",
      "Y",
      "Z"
    ];
    List<String> numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9"];

    Random random = Random();
    String randomCode = "";

    for (int i = 0; i < 7; i++) {
      int chooseList = random.nextInt(2);
      if (chooseList == 0) {
        randomCode += abc[random.nextInt(26)];
      } else {
        randomCode += numbers[random.nextInt(9)];
      }
    }

    return randomCode;
  }

  late DocumentSnapshot present_absent = null as DocumentSnapshot;
  late Map<String, dynamic> updatedPost;
  Future<void> apply_post_service_cam() async {
    List<DocumentSnapshot> d =
        await CommonFunction().getPost("Posts/Gigs/Campaign Tasks");
    print("d =$d");
    //DocumentSnapshot present_absent; // = null;
    for (DocumentSnapshot snapshot in d) {
      if (snapshot.id == widget.snapshot.id) {
        setState(() {
          present_absent = snapshot;
        });
      }
    }
    if (present_absent != null) {
    } else {}

    //print("Posts/Gigs/Campaign Tasks/${widget.snapshot.id}");
    try {
      bool isSubmitted = true;
      CommonFunction().showProgressDialog(isShowDialog: true, context: context);
      print("hemlo g2");
      // update post data
      Map<String, dynamic> map = new Map<String, dynamic>();
      map = {
        "name": name,
        "emailId": emailId,
        "phoneNo": phoneNo,
        "userId": userId,
        "imgUri": (widget.snapshot.data() as dynamic)["imgUri"],
        "logoUri": (widget.snapshot.data() as dynamic)["logoUri"],
        "UserStatus": 0,
        "maxStatus": (widget.snapshot.data() as dynamic)["maxStatus"],
        "target": (widget.snapshot.data() as dynamic)["target"],
        "taskDesc": (widget.snapshot.data() as dynamic)["taskDesc"],
        "reward": (widget.snapshot.data() as dynamic)["reward"] ?? "",
        "status": "applied",
        "companyName": (widget.snapshot.data() as dynamic)["companyName"],
        "taskTitle": (widget.snapshot.data() as dynamic)["taskTitle"],
      };
      //print(map);
      //(widget.snapshot as dynamic).data() = map;
      (widget.snapshot as dynamic).data()["submitedBy"] = map;
      //    Map<String, dynamic> updatedPost;
      if (present_absent != null) {
        var m = present_absent["submittedBy"];
        m.add(map);
        setState(() {
          updatedPost = {"submittedBy": m};
        });
      } else {
        setState(() {
          updatedPost = {
            "submittedBy": [map]
          };
        });
      }
      pendingTasksMap[(widget.snapshot as dynamic).id] = false;

      /// Adding the task information to the users account
      await _firestore
          .collection("Users")
          .doc(phoneNo)
          .set({"pendingTasks": pendingTasksMap}, SetOptions(merge: true));
      await _firestore
          .collection("Posts")
          .doc("Gigs")
          .collection("Campaign Tasks")
          .doc(widget.snapshot.id)
          .set(updatedPost, SetOptions(merge: true));
      pendingPostList.add(widget.snapshot.id.toString());
      prefs.setStringList("pendingTasks", pendingPostList);
      if (isSubmitted == true) {
        Fluttertoast.showToast(
            msg: "Submitted successfully",
            backgroundColor: Colors.green,
            textColor: Colors.white);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: "getting some error",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (e) {
      debugPrint("Exception : (applyPostService) -> $e");
      print("1212121212121212121dfsaf");
    }
    CommonFunction().showProgressDialog(isShowDialog: false, context: context);
  }

  Future<void> applyPostService() async {
    print("ye ye boi");
    List<DocumentSnapshot> d =
        await CommonFunction().getPost("Posts/Gigs/Tasks");
    //DocumentSnapshot present_absent; //null;

    for (DocumentSnapshot snapshot in d) {
      print(snapshot.id);
      print(widget.snapshot.id);
      if (snapshot.id == widget.snapshot.id) {
        setState(() {
          present_absent = snapshot;
        });
      }
    }
    try {
      bool isSubmitted = true;
      CommonFunction().showProgressDialog(isShowDialog: true, context: context);
      Map<String, String> map = new Map<String, String>();
      List userTaskList = (widget.snapshot.data() as dynamic)["submittedBy"] ??
          []; //new List<Map<String, String>>();
      for (var item in userTaskList) {
        map = ({
          "name": item["name"] ?? "",
          "emailId": item["emailId"] ?? "",
          "uploadWorkUri": item["uploadWorkUri"] ?? "",
          "userId": item["userId"] ?? "",
          "phoneNo": item["phoneNo"] ?? "",
        });
      }
      String workedImgFileUri = await uploadToStorage(_workedImgFile);

      map = {
        "name": name,
        "emailId": emailId,
        "phoneNo": phoneNo,
        "userId": userId,
        "uploadWorkUri": workedImgFileUri,
        "imgUri": (widget.snapshot.data() as dynamic)["imgUri"],
        "logoUri": (widget.snapshot.data() as dynamic)["logoUri"],
        "taskDesc": (widget.snapshot.data() as dynamic)["taskDesc"],
        "reward": (widget.snapshot.data() as dynamic)["reward"] ?? "",
        "status": "applied",
        "companyName": (widget.snapshot.data() as dynamic)["companyName"],
        "taskTitle": (widget.snapshot.data() as dynamic)["taskTitle"],
        "user email": collegeNameCont.text,
      };
      for (var required
          in (widget.snapshot.data() as dynamic)["requiredField"]) {
        // print(required);
        if (required == "Username") {
          map["Username"] = Username.text.trim().toString();
        }
        if (required == "Phone Number") {
          map["Phone Number"] = Phone_number.text.trim().toString();
        }
        if (required == "code") {
          map["code"] = code.text.trim().toString();
        }
        if (required == "Order Id") {
          map["Order Id"] = OrderId.text.trim().toString();
        }
      }
      //print(map);
      (widget.snapshot as dynamic).data()["submitedBy"] = map;
      Map<String, dynamic> updatedPost = {};
      if (present_absent != null) {
        var m = present_absent["submittedBy"];
        m.add(map);
        setState(() {
          updatedPost = {"submittedBy": m};
        });
      } else {
        setState(() {
          updatedPost = {
            "submittedBy": [map]
          };
        });
      }
      pendingTasksMap[widget.snapshot.id] = false;
      await _firestore
          .collection("Users")
          .doc(phoneNo)
          .set({"pendingTasks": pendingTasksMap}, SetOptions(merge: true));
      await _firestore
          .collection("Posts")
          .doc("Gigs")
          .collection("Tasks")
          .doc(widget.snapshot.id)
          .set(updatedPost, SetOptions(merge: true));
      pendingPostList.add(widget.snapshot.id.toString());
      prefs.setStringList("pendingTasks", pendingPostList);
      setState(() {
        isSubmitted = true;
      });
      if (isSubmitted == true) {
        Fluttertoast.showToast(
            msg: "Submitted successfully",
            backgroundColor: Colors.green,
            textColor: Colors.white);
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: "getting some error",
            backgroundColor: Colors.red,
            textColor: Colors.white);
      }
    } catch (e) {
      print("1212");
      debugPrint("Exception : (applyPostService) -> $e");
    }
    CommonFunction().showProgressDialog(isShowDialog: false, context: context);
  }

  Future<String> uploadToStorage(File file) async {
    final Reference storageReference =
        FirebaseStorage.instance.ref().child(file.path);
    final UploadTask uploadTask = storageReference.putFile(file);

    debugPrint("Upload ${uploadTask.whenComplete(() => null)}");
    TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);
    var downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
