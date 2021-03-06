import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/common_widgets.dart';
import 'package:markboot/common/style.dart';

enum OfferType {
  Important,
  UnImportant,
}

class offers extends StatefulWidget {
  //String type;
  //String subtype;

  offers();

  @override
  _offersState createState() => _offersState();
}

class _offersState extends State<offers> {
  CommonWidget commonWidget = CommonWidget();
  List<String> types = ["Moneyback", "Wow Offers"];
  late String selectedType = "Moneyback";
  bool isClickcompanyLogo = true;
  TextEditingController com_name = TextEditingController();
  TextEditingController user_name = TextEditingController();
  TextEditingController user_email = TextEditingController();
  TextEditingController user_phone = TextEditingController();
  TextEditingController user_reward = TextEditingController();
//  TextEditingController  = TextEditingController();
  TextEditingController descrip = TextEditingController();
  late File _companyFileImg = File("");
  final picker = ImagePicker();
  var isClickoffer = false;
  var isClickpost = false;

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

  /* init() {}
  Future<String> uploadToStorage(File uploadfile) async {
   //FirebaseStorage = storage
    final StorageReference storageReference =
        FirebaseStorage.instance.ref().child("image").child(uploadfile.path);
    final StorageUploadTask uploadTask = storageReference.putFile(uploadfile);
    debugPrint("Upload ${uploadTask.isComplete}");
    StorageTaskSnapshot snapshot = await uploadTask.onComplete;
    var downloadUrl = await snapshot.ref.getDownloadURL();
    debugPrint("URL $downloadUrl");
    return downloadUrl;
  }
  */

  init() {}
  Future<String> uploadToStorage(File uploadfile) async {
    //FirebaseStorage = storage
    final Reference storageReference =
        FirebaseStorage.instance.ref().child("image").child(uploadfile.path);
    final UploadTask uploadTask = storageReference.putFile(uploadfile);
    debugPrint("Upload ${uploadTask.snapshotEvents}"); //.isComplete replaced
    TaskSnapshot snapshot = await uploadTask.whenComplete(() {}); //.onComplete;
    var downloadUrl = await snapshot.ref.getDownloadURL();
    debugPrint("URL $downloadUrl");
    return downloadUrl;
  }

  @override
  void initState() {
    init();
    // TODO: implement initState
    super.initState();
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
                    color: Color(CommonStyle().blueColor),
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
          await picker.getImage(source: ImageSource.gallery, imageQuality: 100);

      setState(() {
        debugPrint("ISCLICK $isClickcompanyLogo");
        if (isClickcompanyLogo == true) {
          _companyFileImg = File(pickedFile!.path); //! is added
        }
        isClickcompanyLogo = false;
      });
    } catch (e) {
      debugPrint("Exception : (pickImage) -> $e");
    }
  }

  pickImageCamera(showfileImg) async {
    try {
      final pickedFile =
          await picker.getImage(source: ImageSource.camera, imageQuality: 100);
      setState(() {
        if (isClickcompanyLogo == true) {
          debugPrint("COMPANYLOOOOOGO");
          _companyFileImg = File(pickedFile!.path); //! is added
        }
      });
    } catch (e) {
      debugPrint("Exception : (pickImage) -> $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff051094),
        title: Text(
          "Offers",
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Color(CommonStyle().backgroundColor),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Center(
            //     child: commonWidget.commonTextField(
            //         controller: com_name,
            //         inputText: "Offer Name",
            //         hintText: '')),
            // SizedBox(
            //   height: 20,
            // ),
            // DropdownButton(
            //   hint: Text("Select the offers"),
            //   value: selectedType,
            //   items: List.generate(
            //       2,
            //       (index) => DropdownMenuItem(
            //             child: Text(types[index]),
            //             value: types[index],
            //           )),
            //   onChanged: (val) {
            //     setState(() {
            //       selectedType = val as String; // as String is added
            //     });
            //   },
            // ),
            // Center(
            //     child: commonWidget.commonTextField(
            //         controller: user_name, inputText: "Name", hintText: '')),
            // SizedBox(
            //   height: 20,
            // ),
            Center(
                child: commonWidget.commonTextField(
                    controller: user_email,
                    inputText: "email address",
                    hintText: '')),
            SizedBox(
              height: 20,
            ),
            Center(
                child: commonWidget.commonTextField(
                    controller: user_phone,
                    inputText: "Phone No",
                    hintText: '')),
            SizedBox(
              height: 20,
            ),
            Center(
                child: commonWidget.commonTextField(
                    controller: user_reward,
                    inputText: "Reward",
                    hintText: '')),
            SizedBox(
              height: 30,
            ),
            //   Center(
            //     child: Text("Logo"),
            //   ),
            //   GestureDetector(
            //       onTap: () {
            //         showPickImageDialog(_companyFileImg);
            //         isClickcompanyLogo = true;
            //         setState(() {});
            //       },
            //       child: showCamera(_companyFileImg)),
            //   SizedBox(
            //     height: 20,
            //   ),
            //  Center(child: commonWidget.commonTextField(controller: descrip,inputText: "Description", hintText: 'disc')),
            //  SizedBox(
            //    height: 30,
            //  ),
            //   SizedBox(
            //     height: 5,
            //   ),
            Container(
              height: 50,
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(maxWidth: 260),
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: RaisedButton(
                color: Color(CommonStyle().lightYellowColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                onPressed: () async {
                  FocusScope.of(context).unfocus();
//                  checkTaskService();
                  String company = com_name.text.trim().toString();
                  String name = user_name.text.trim().toString();
                  String phone = user_phone.text.trim().toString();
                  String email = user_email.text.trim().toString();
                  String reward = user_reward.text.trim().toString();
                  // String desc = descrip.toString();

//                  String company="google";
//                  String name="ashish";
//                  String phone="8532956668";
//                  String reward="20";
//                  String desc="nmndmnsd";
//                  String email="ashish@gmail.com";
//                  print(company.length);
//                  print(company.isEmpty);

                  if (phone.isEmpty || email.isEmpty || reward.isEmpty) {
                    print("Please enter the data");
                  } else {
                    List<DocumentSnapshot> users =
                        await CommonFunction().getPost("Users");
                    List<DocumentSnapshot> campaigns;
                    if (selectedType == "Moneyback") {
                      campaigns = await CommonFunction()
                          .getPost("Posts/Offers/Cashbacks");
                    } else {
                      print("else");
                      campaigns = await CommonFunction()
                          .getPost("Posts/Offers/50 on 500");
                    }
                    //  print(users);
                    print(campaigns);
                    DocumentSnapshot use = null as DocumentSnapshot;
                    DocumentSnapshot campaign = null as DocumentSnapshot;
                    for (var user in users) {
//                      print(user.documentID.toString()=="+91${phone}");
                      // print(user.data);
//                      print(user.data["emailId"]);
                      //                    print(email);
                      //                  print("\n");
                      if (user.id.toString() == "+91${phone}" &&
                          (user.data() as dynamic)["emailId"] == email) {
                        //this line is used instead of next
                        //user.data["emailId"] == email) {
                        print("user Got it");
                        setState(() {
                          use = user;
                        });
                      }
                    }
                    for (var cam in campaigns) {
                      print("BAi Bai");
                      print((cam.data() as dynamic)["taskTile"]);
                      print(company);
                      //print(cam.data["taskTitle"]);   this line removed to remove error
                      if (((cam.data() as dynamic)["taskTile"]) == company) {
                        // if (cam.data["taskTitle"].toString() == company) {
                        print(" campaign Got it");
                        setState(() {
                          campaign = cam;
                        });
                      }
                      //this code remove due to error
                      if (use != null && cam != null) {
                        print("found");
                        _showMyDialog(use, campaign);
                        break;
                      } else {
                        print("Data not Found");
                      }
                    }
                    //      _showMyDialog(use, campaign);
                  }
                },
                child: Text(
                  "Submit",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  fieldClear() {
    //selectedType = null;
    com_name.clear();
    user_name.clear();
    user_phone.clear();
    user_email.clear();
    user_reward.clear();
  }

  Future<void> _showMyDialog(
      DocumentSnapshot user, DocumentSnapshot campaign) async {
    print(user.data());
    return showDialog<void>(
      context: context,
      //barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do want to Accept that product?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('approved'),
              onPressed: () {
                //_pending_approved(user, campaign);
                // _pending_approved(userId);
                // Navigator.pop(context);
                upload_data(user, campaign, "approved");
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('pending'),
              onPressed: () {
                //_pending_approved(user, campaign);
                // _pending_approved(userId);
                Navigator.pop(context);
                upload_data(user, campaign, "pending");
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('rejected'),
              onPressed: () async {
                upload_data(user, campaign, "rejected");
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> _pending_approved(
      DocumentSnapshot user, DocumentSnapshot campaign) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Do want to Accept that product?'),
                //Text('Would you like to approve of this message?'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('approved'),
              onPressed: () async {
                upload_data(user, campaign, "approved");

                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('Pending'),
              onPressed: () async {
                upload_data(user, campaign, "pending");

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  upload_data(
      DocumentSnapshot user, DocumentSnapshot campaign, String status) async {
    // For the user Side
    //var u = user.data;
    print(user.get("name"));
    // print(u["name"]);
    final firestoreInstance = FirebaseFirestore.instance;
    CommonFunction().showProgressDialog(isShowDialog: true, context: context);
    //String PicUri = await uploadToStorage(_companyFileImg);

    setState(() {
      if (status == "pending") {
        firestoreInstance.collection("Users").doc(user.id).update({
          "pendingAmount":
              user.get("pendingAmount") + int.parse(user_reward.text)
          //"pendingAmount": user.get("pendingAmount")["pendingAmount"] + int.parse(user_reward.text)
        });
        firestoreInstance.collection("UsersOffers").add({
          "offer name": com_name.text.toString(),
          "reward": user_reward.text.toString(),
          "time": Timestamp.now(),
          "status": status,
          "user phone": user.id,
          // "logoUri": PicUri,
        }).then((value) {
          Fluttertoast.showToast(msg: "offer added in pending list");
        });
      } else if (status == "approved") {
        firestoreInstance.collection("Users").doc(user.id).update({
          "approvedAmount":
              user.get("approvedAmount") + int.parse(user_reward.text)
          //"approvedAmount": u["approvedAmount"] + int.parse(user_reward.text)
        });
        firestoreInstance.collection("UsersOffers").add({
          "offer name": com_name.text.toString(),
          "reward": user_reward.text.toString(),
          "time": Timestamp.now(),
          "status": status,
          "user phone": user.id,
          // "logoUri": PicUri,
        }).then((value) {
          Fluttertoast.showToast(msg: "offer added in approved list");
        });
      } else {
        firestoreInstance.collection("UsersOffers").add({
          "offer name": com_name.text.toString(),
          "reward": user_reward.text.toString(),
          "time": Timestamp.now(),
          "status": status,
          "user phone": user.id,
          //"logoUri": PicUri,
        }).then((value) {
          Fluttertoast.showToast(msg: "offer added in rejected list");
          Navigator.pop(context);
        });
      }
      //var users_cam = u["offersList"];
      //users_cam["${user.documentID}"] = false;
      ////print(u["campaignList"]);
      //// users_cam.add(({"${campaign.documentID}" : false}));
      //u["offersList"] = users_cam;
    });
    print(user);

    // For Task Side

    //List<DocumentSnapshot> campaigns_task =
    //    await CommonFunction().getPost("Posts/Offers/Tasks");
//
    //int flag = 0;
    //DocumentSnapshot cam;
    //for (var cams in campaigns_task) {
    //  if (cams.documentID.toString() == campaign.documentID) {
    //    setState(() {
    //      flag = 1;
    //      cam = cams;
    //    });
    //  }
    //}
//
    //print(flag);
//
    //List userr;
    //if (flag == 1) {
    //  userr = cam.data["submittedBy"];
    //  for (var ut in userr) {
    //    //print(ut);
    //    if (ut["name"] == u["name"]) {
    //      print("user present");
    //      print(userr.indexOf(ut));
    //      userr.remove(ut);
    //      break;
    //    }
    //  }
    //  userr.add({
    //    "name": u["name"] ?? "",
    //    "emailId": u["emailId"] ?? "",
    //    "uploadWorkUri": campaign.data["imgUri"] ?? "",
    //    "taskTitle": campaign.data["taskTitle"],
    //    "companyName": campaign.data["companyName"],
    //    "userId": u["userId"] ?? "",
    //    "phoneNo": u["phoneNo"] ?? "",
    //    "description": "kdskdsk",
    //    "status": status,
    //    "reward": user_reward.text.trim().toString()
    //  });
    //} else {
    //  userr = [];
    //  userr.add({
    //    "name": u["name"] ?? "",
    //    "emailId": u["emailId"] ?? "",
    //    "uploadWorkUri": campaign.data["imgUri"] ?? "",
    //    "taskTitle": campaign.data["taskTitle"],
    //    "companyName": campaign.data["companyName"],
    //    "userId": u["userId"] ?? "",
    //    "phoneNo": u["phoneNo"] ?? "",
    //    "description": "kdskdsk",
    //    "status": status,
    //    "reward": user_reward.text.trim().toString()
    //  });
    //}
//
    //print(userr);
    //Map<String, dynamic> updatedPost = {"submittedBy": userr};
    //print(updatedPost);
//
    //await _firestore
    //    .collection("Posts")
    //    .document("Offers")
    //    .collection("Tasks")
    //    .document(campaign.documentID)
    //    .setData(updatedPost, merge: true);
  }
}

//import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/material.dart';
//import 'package:fluttertoast/fluttertoast.dart';
//import 'package:markBoot/common/commonFunc.dart';
//import 'package:markBoot/common/common_widget.dart';
//import 'package:markBoot/common/style.dart';
//import 'package:markBoot/pages/homeScreen/adminPages/taskUserList_page.dart';
//
//class OffersPageTab extends StatefulWidget {
//
//  bool isRedirectFromProfile;
//  Map<String,dynamic> docList ;
//
//  OffersPageTab({this.docList,this.isRedirectFromProfile});
//
//  @override
//  _OffersPageTabState createState() => _OffersPageTabState();
//}
//
//class _OffersPageTabState extends State<OffersPageTab>with SingleTickerProviderStateMixin {
//
//  List<DocumentSnapshot> cashbackDocumentList ;
//  List<DocumentSnapshot> on500DocumentList ;
//  List<DocumentSnapshot> couponsDocumentList ;
//  TabController _tabController ;
//  List<Map<String,dynamic>> cashbackMapList = new List();
//  List<Map<String,dynamic>> on500MapList = new List();
//  List<Map<String,dynamic>> couponsMapList = new List();
//
//  List<int> cardColor = [CommonStyle().cardColor1,CommonStyle().cardColor2,CommonStyle().cardColor3,CommonStyle().cardColor4];
//
//
//
//  Future<void> _onCashbackRefresh() async{
//    cashbackDocumentList = await CommonFunction().getPost("Posts/Offers/Cashbacks");
//
//    return;
//  }
//  Future<void> _on500Refresh() async{
//    on500DocumentList = await CommonFunction().getPost("Posts/Offers/50 on 500");
//    setState(() {
//
//    });
//    return;
//  }
//  Future<void> _onCouponsRefresh() async{
//    on500DocumentList = await CommonFunction().getPost("Posts/Offers/Coupons");
//    setState(() {
//
//    });
//    return;
//  }
//
//  init() async {
//    try {
//      cashbackDocumentList = await CommonFunction().getPost("Posts/Offers/Cashbacks");
//      setState(() {
//
//      });
//      on500DocumentList = await CommonFunction().getPost("Posts/Offers/50 on 500");
//
//      setState(() {
//
//      });
//      couponsDocumentList = await CommonFunction().getPost("Posts/Offers/Coupons");
//      setState(() {
//
//      });
//    }
//    catch(e) {
//      debugPrint("Exception : (init)-> $e");
//    }
//  }
//
//  @override
//  void initState() {
//    _tabController = TabController(length: 3, vsync: this);
//    init();
//    // TODO: implement initState
//    super.initState();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//        backgroundColor: Colors.white,
//        appBar: AppBar(
//            backgroundColor: Color(CommonStyle().blueColor),
//            title: Text(widget.isRedirectFromProfile == true ?"Applied" : "Offers",
//              style: TextStyle(color: Colors.white),
//            ),
//            bottom: TabBar(
//              labelColor:Color(CommonStyle().lightYellowColor),
//              unselectedLabelColor: Colors.grey,
//              controller: _tabController,
//              tabs: <Widget>[
//                // moneyback- cashbacks ,wow offers-50 on 500,top offers - coupons
//                Tab(
//                  child: Text("Moneyback"),
//                ),
//                Tab(
//                    child: Text("Wow Offers")
//                ),
//                Tab(
//                    child: Text("Top Offers")
//                ),
//              ],
//            )
//        ),
//        body: TabBarView(
//          controller: _tabController,
//          children: <Widget>[
//            cashbackWidget(),
//            on500Widget(),
//            couponsWidget(),
//          ],
//        )
//    );
//  }
//
//  cashbackWidget() {
//    int index =0;
//    return RefreshIndicator(
//      onRefresh: _onCashbackRefresh,
//      child: CustomScrollView(
//        primary: false,
//        slivers: <Widget>[
//          cashbackDocumentList !=null && cashbackDocumentList.length >0 ?
//          SliverPadding(
//            padding: const EdgeInsets.all(20),
//            sliver: SliverGrid.count(
//              crossAxisSpacing: 10,
//              mainAxisSpacing: 10,
//              crossAxisCount: 2,
//              childAspectRatio: 2/3,
//              children: cashbackDocumentList.map((item) {
//                index++;
//                return  singleCard(item,context,"Admin",path: "Posts/Offers/Cashbacks",snapshots: cashbackDocumentList);
//              }).toList(),
//            ),
//          ) :
//          (
//              cashbackDocumentList == null ?
//              SliverToBoxAdapter(
//                  child: Container(
//                    margin: EdgeInsets.only(top: 50),
//                    child: Center(
//                      child: Container(
//                          width: 30,
//                          height: 30,
//                          child: CircularProgressIndicator()),
//                    ),
//                  )
//              )
//                  : SliverToBoxAdapter(
//                child: Container(
//                  height: MediaQuery.of(context).size.height-200,
//                  child: Center(
//                    child: Container(
//                      child: Text("No Data Found",
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontWeight:FontWeight.bold,
//                            fontSize: 18
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//              )
//          ),
//        ],
//      ),
//    );
//  }
//  on500Widget() {
//    int index =0;
//    return RefreshIndicator(
//      onRefresh: _onCashbackRefresh,
//      child: CustomScrollView(
//        primary: false,
//        slivers: <Widget>[
//          on500DocumentList !=null && on500DocumentList.length >0 ?
//          SliverPadding(
//            padding: const EdgeInsets.all(20),
//            sliver: SliverGrid.count(
//              crossAxisSpacing: 10,
//              mainAxisSpacing: 10,
//              crossAxisCount: 2,
//              childAspectRatio: 2/3,
//              children: on500DocumentList.map((item) {
//                index++;
//                return  singleCard(item,context,"Admin",path : "Posts/Offers/50 on 500",snapshots: on500DocumentList);
//              }).toList(),
//            ),
//          ) :
//          (
//              on500DocumentList == null ?
//              SliverToBoxAdapter(
//                  child: Container(
//                    margin: EdgeInsets.only(top: 50),
//                    child: Center(
//                      child: Container(
//                          width: 30,
//                          height: 30,
//                          child: CircularProgressIndicator()),
//                    ),
//                  )
//              )
//                  : SliverToBoxAdapter(
//                child: Container(
//                  height: MediaQuery.of(context).size.height-200,
//                  child: Center(
//                    child: Container(
//                      child: Text("No Data Found",
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontWeight:FontWeight.bold,
//                            fontSize: 18
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//              )
//          ),
//        ],
//      ),
//    );
//  }
//  couponsWidget() {
//    int index =0;
//    return RefreshIndicator(
//      onRefresh: _onCashbackRefresh,
//      child: CustomScrollView(
//        primary: false,
//        slivers: <Widget>[
//          couponsDocumentList !=null && couponsDocumentList.length >0 ?
//          SliverPadding(
//            padding: const EdgeInsets.all(20),
//            sliver: SliverGrid.count(
//              crossAxisSpacing: 10,
//              mainAxisSpacing: 10,
//              crossAxisCount: 2,
//              childAspectRatio: 2/3,
//              children: couponsDocumentList.map((item) {
//                index++;
//                return  singleCard(item,context,"Admin",path: "Posts/Offers/Coupons",snapshots: couponsDocumentList);
//              }).toList(),
//            ),
//          ) :
//          (
//              couponsDocumentList == null ?
//              SliverToBoxAdapter(
//                  child: Container(
//                    margin: EdgeInsets.only(top: 50),
//                    child: Center(
//                      child: Container(
//                          width: 30,
//                          height: 30,
//                          child: CircularProgressIndicator()),
//                    ),
//                  )
//              )
//                  : SliverToBoxAdapter(
//                child: Container(
//                  height: MediaQuery.of(context).size.height-200,
//                  child: Center(
//                    child: Container(
//                      child: Text("No Data Found",
//                        style: TextStyle(
//                            color: Colors.white,
//                            fontWeight:FontWeight.bold,
//                            fontSize: 18
//                        ),
//                      ),
//                    ),
//                  ),
//                ),
//              )
//          ),
//        ],
//      ),
//    );
//  }
//
//  Widget singleCard(DocumentSnapshot snapshot,context,postType,{subtype,path,snapshots} ) {
//    return Stack(
//      children: <Widget>[
//        Container(
//          decoration: BoxDecoration(
//              color: Colors.white,
//              borderRadius: BorderRadius.circular(10)
//          ),
//          child: Material(
//              borderRadius: BorderRadius.circular(10),
//              color: Colors.blue,
//              child: InkWell(
//                onTap: (){
//                    Navigator.push(context, MaterialPageRoute(
//                        builder: (context)=>TaskUserListPage(taskUserList: snapshot["offersSubmittedBy"] ?? new List(),)
//                    ));
//
//                },
//                child: Container(
//                  decoration: BoxDecoration(
//                      color: Color(CommonStyle().blueCardColor),
//                      borderRadius: BorderRadius.circular(10)
//                  ),
//                  child: Column(
//                    crossAxisAlignment: CrossAxisAlignment.start,
//                    children: <Widget>[
//                      Expanded(
//                        child: Container(
//                          decoration: BoxDecoration(
//                              borderRadius: BorderRadius.circular(10),
//                              image: DecorationImage(
//                                  fit: BoxFit.cover,
//                                  image: NetworkImage(snapshot["imgUri"])
//                              )
//                          ),
//                        ),
//                      ),
//                      Padding(
//                        padding: const EdgeInsets.only(left: 4,right: 2,top: 2,bottom: 2),
//                        child: Text(snapshot["companyName"] ?? "",
//                          style: TextStyle(
//                            color: Colors.white,
//                            fontSize: 14,
//                          ),
//                        ),
//                      ),
//                      Container(
//                        padding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
//                        height: 50,
//                        child: Text(snapshot["taskTitle"],
//                          overflow: TextOverflow.clip,
//                          style: TextStyle(
//                              color: Colors.white,
//                              fontSize: 10
//                          ),
//                        ),
//                      ),
//                    ],
//                  ),
//                ),
//              )
//          ),
//        ),
//        Positioned(
//            top: 5,
//            right: 8,
//            child: CircleAvatar(
//              backgroundColor:Colors.green,
//              radius: 18,
//              child: Text(snapshot["offersSubmittedBy"] == null ? "0" : snapshot["offersSubmittedBy"].length.toString(),
//                style: TextStyle(
//                    color: Colors.white,
//                    fontSize: 15
//                ),
//              ),
//            )
//        ),
//        Positioned(
//            top: 5,
//            left: 8,
//            child: CircleAvatar(
//              backgroundColor:Colors.grey,
//              radius: 18,
//              child: IconButton(
//                icon: Icon(Icons.delete,size: 20,color: Colors.red,),
//                onPressed: ()async{
//                  try{
//                    CommonFunction().showProgressDialog(isShowDialog: true, context: context);
//                    await Firestore.instance.collection(path).document(snapshot.documentID).delete();
//                    Fluttertoast.showToast(msg: "delete successfully",
//                        textColor: Colors.white,backgroundColor: Colors.green
//                    );
//                    CommonFunction().showProgressDialog(isShowDialog: false, context: context);
//                    snapshots.remove(snapshot);
//                    setState(() {
//
//                    });
//                  }
//                  catch(e){
//
//                  }
//                },
//              ),
//            )
//        )
//      ],
//    );
//  }
//
//}
