import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:markboot/common/commonFunc.dart';

class AmountReqUserListPage extends StatefulWidget {
  @override
  _AmountReqUserListPageState createState() => _AmountReqUserListPageState();
}

class _AmountReqUserListPageState extends State<AmountReqUserListPage>
    with SingleTickerProviderStateMixin {
  List<DocumentSnapshot> usersList = []; //new List();
  bool isShowInitBar = true;
  List maps_gigs = [];
  List maps_campaign = [];
  List maps_offers = [];
  late DocumentSnapshot user;

  getpref() async {
    // FOR THE GIGS
    List mapi = [];
    List<DocumentSnapshot> snaps =
        await CommonFunction().getPost("Posts/Gigs/Tasks");
    //print(snaps[0].data);
    for (DocumentSnapshot snapshot in snaps) {
      for (var map in snapshot.get("submittedBy")) {
        //for (var map in snapshot.data["submittedBy"]) {
        print(map);
        if (map["status"] == "pending") {
          map["documentId"] = snapshot.id.toString();
          print("mapi=$map");
          //setState(() {
          mapi.add(map);

          //});
        }
      }
    }
    setState(() {
      maps_gigs = mapi;
    });

    // FOR THE OFFERS
    List mapi_offers = [];
    snaps = await CommonFunction().getPost("Posts/Offers/Tasks");
    //print(snaps[0].data);
    for (DocumentSnapshot snapshot in snaps) {
      //for (var map in snapshot.data["submittedBy"]) {
      for (var map in snapshot.get("submittedBy")) {
        print("map=$map");
        if (map["status"] == "pending") {
          map["documentId"] = snapshot.id.toString();
          print("maps=$map");
          //setState(() {
          mapi_offers.add(map);

          //});
        }
      }
    }
    setState(() {
      maps_offers = mapi_offers;
    });

    // FOR THE CAMPAIGN
    List mapi_cam = [];
    snaps = await CommonFunction().getPost("Posts/Gigs/Campaign Tasks");
    //print(snaps[0].data);
    for (DocumentSnapshot snapshot in snaps) {
      for (var map in snapshot.get("submittedBy")) {
        //for (var map in snapshot.data["submittedBy"]) {
        //print(map);
        if (map["status"] == "pending") {
          map["documentId"] = snapshot.id.toString();
          print(map);

          //setState(() {
          mapi_cam.add(map);

          //});
        }
      }
    }
    setState(() {
      maps_campaign = mapi_cam;
    });
    // print(maps.length);

    print("gigs=${maps_gigs.length}");
    print("cam=${maps_campaign.length}");
    print(maps_offers.length);
  }

  init() async {
    getpref();
    //    QuerySnapshot querySnapshot = await Firestore.instance.collection("Users").getDocuments();
//    if(querySnapshot !=null ){
//      for(DocumentSnapshot snapshot in querySnapshot.documents) {
//        Map<String,dynamic>userData = snapshot.data;
//        String requestAmount = userData["requestAmount"] ??"0";
//        if(int.parse(requestAmount)>0) {
//          usersList.add(snapshot);
//        }
//      }
//    }
//    setState(() {
//
//    });
    isShowInitBar = false;
  }

  late TabController _tabController;
  @override
  void initState() {
    init();
    _tabController = TabController(length: 3, vsync: this);

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Color(0xff051094),
            title: Text("Amount Request"),
            bottom: TabBar(
              labelColor: Color(0xff051094),
              unselectedLabelColor: Colors.white,
              //indicatorSize: TabBarIndicatorSize.label,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8))),
              controller: _tabController,
              tabs: <Widget>[
                // moneyback- cashbacks ,wow offers-50 on 500,top offers - coupons
                Container(
                  width: 150,
                  child: Tab(
                    child: Text("Gigs"),
                  ),
                ),
                Container(width: 150, child: Tab(child: Text("Campaign"))),
                Container(width: 150, child: Tab(child: Text("Offers"))),
              ],
            )),
        body: TabBarView(
          controller: _tabController,
          children: <Widget>[getgigs(), getcampaign(), getoffers()],
        ));
  }

  getgigs() {
    return isShowInitBar == true
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : (maps_gigs.length > 0
            ? ListView.builder(
                itemBuilder: (context, index) {
                  // return Text("hello");
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: taskUserCard(maps_gigs[index], "gigs"),
                  );
                },
                itemCount: maps_gigs.length,
              )
            : Center(
                child: Container(
                  child: Text(
                    "No users found",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ));
  }

  getcampaign() {
    return isShowInitBar == true
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : (maps_campaign.length > 0
            ? ListView.builder(
                itemBuilder: (context, index) {
                  // return Text("hello");
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: taskUserCard(maps_campaign[index], "campaign"),
                  );
                },
                itemCount: maps_campaign.length,
              )
            : Center(
                child: Container(
                  child: Text(
                    "No users found",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ));
  }

  // ignore: missing_return
  Future<DocumentSnapshot> getUser(String phone) async {
    List<DocumentSnapshot> usersList = await CommonFunction().getPost("Users");
    for (var userDocument in usersList) {
      if (userDocument.id.toString() == "phone") {
        print(userDocument.id.toString());
        return userDocument;
      }
    }
    throw () {};
  }

  getoffers() {
    return isShowInitBar == true
        ? Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : StreamBuilder(
            stream: _firestore
                .collection("UsersOffers")
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (context, snapShot) {
              if (snapShot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView.builder(
                    itemCount: (snapShot.data as dynamic).docs.length,
                    itemBuilder: (ctx, index) {
                      return FutureBuilder(
                          future: FirebaseFirestore.instance
                              .collection("Users")
                              .doc((snapShot.data as dynamic).docs[index]
                                  ["user phone"])
                              .get(),
                          builder: (context, snapshotA) {
                            if (snapshotA.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else {
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 30,
                                  child: Text(
                                    (snapShot.data as dynamic).docs[index]
                                        ['offer name'],
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: (snapShot.data as dynamic)
                                              .docs[index]['status'] ==
                                          "pending"
                                      ? Color(0xff051094)
                                      : (snapShot.data as dynamic).docs[index]
                                                  ['status'] ==
                                              "approved"
                                          ? Colors.green
                                          : Colors.redAccent,
                                ),
                                title: Text((snapShot.data as dynamic)
                                    .docs[index]['user phone']),
                                subtitle: Text(
                                    "${(snapshotA.data as dynamic)["emailId"]}"),
                                trailing: ElevatedButton(
                                  child: Text(
                                    (snapShot.data as dynamic).docs[index]
                                                ['status'] ==
                                            "pending"
                                        ? "Pending\nRs.${(snapShot.data as dynamic).docs[index]["reward"].toString()}"
                                        : (snapShot.data as dynamic).docs[index]
                                                    ['status'] ==
                                                "approved"
                                            ? "Approved\nRs.${(snapShot.data as dynamic).docs[index]["reward"].toString()}"
                                            : "Rejected\nRs.${(snapShot.data as dynamic).docs[index]["reward"].toString()}",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Color(0xff051094)),
                                  ),
                                  onPressed: () {
                                    if ((snapShot.data as dynamic).docs[index]
                                          ['status'] ==
                                      "pending") {
                                    updateData(int A) {
                                      final firestoreInstance =
                                          FirebaseFirestore.instance;
                                      if (A == 1) {
                                        int amount = (snapshotA.data
                                                as dynamic)["pendingAmount"] -
                                            int.parse((snapShot.data as dynamic)
                                                .docs[index]["reward"]);
                                        firestoreInstance
                                            .collection("Users")
                                            .doc((snapShot.data as dynamic)
                                                .docs[index]["user phone"])
                                            .update({"pendingAmount": amount});
                                        Navigator.of(context).pop();
                                      } else {
                                        int pAmount = (snapshotA.data
                                                as dynamic)["pendingAmount"] -
                                            int.parse((snapShot.data as dynamic)
                                                .docs[index]["reward"]);
                                        int aAmount = (snapshotA.data
                                                as dynamic)["approvedAmount"] +
                                            int.parse((snapShot.data as dynamic)
                                                .docs[index]["reward"]);
                                        firestoreInstance
                                            .collection("Users")
                                            .doc((snapShot.data as dynamic)
                                                .docs[index]["user phone"])
                                            .update({"pendingAmount": pAmount});
                                        firestoreInstance
                                            .collection("Users")
                                            .doc((snapShot.data as dynamic)
                                                .docs[index]["user phone"])
                                            //.documents[index]["user phone"])
                                            .update(
                                                {"approvedAmount": aAmount});
                                        Navigator.of(context).pop();
                                      }
                                      return;
                                    }

                                    showDialog(
                                        //return is removed
                                        context: context,
                                        builder: (BuildContext context) {
                                          final firestoreInstance =
                                              FirebaseFirestore.instance;
                                          QuerySnapshot? snap = snapShot.data
                                              as QuerySnapshot<
                                                  Object?>?; //cast is added
                                          //snapShot.data; // Snapshot
                                          List<DocumentSnapshot> items =
                                              (snap as dynamic)
                                                  .docs; // List of Documents
                                          DocumentSnapshot item = items[index];
                                          return AlertDialog(
                                            title: Text("Choose One"),
                                            actions: [
                                              FlatButton(
                                                child: Text("approve"),
                                                onPressed: () {
                                                  updateData(0);
                                                  setState(() {
                                                    firestoreInstance
                                                        .collection(
                                                            "UsersOffers")
                                                        .doc(item.id)
                                                        .update({
                                                      "status": "approved"
                                                    });
                                                  });
                                                },
                                              ),
                                              FlatButton(
                                                  onPressed: () {
                                                    updateData(1);
                                                    setState(() {
                                                      firestoreInstance
                                                          .collection(
                                                              "UsersOffers")
                                                          .doc(item.id)
                                                          .update({
                                                        "status": "rejected"
                                                      });
                                                    });
                                                  },
                                                  child: Text("reject"))
                                            ],
                                          );
                                        });
                                  }
                                  },
                                ),
                                // onTap: () {
                                  
                                // },
                              );
                            }
                          });
                    });
              }
            },
          );
  }

  Widget taskUserCard(Map<String, dynamic> userData, String type) {
    //print(userData);
    return Container(
      //height: 100,
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8), color: Color(0xff051094)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[leftWidget(userData), rightWidget(userData, type)],
      ),
    );
  }

  Widget leftWidget(Map<String, dynamic> userData) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 15),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(userData["taskTitle"] ?? "",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(
            height: 5,
          ),
          Text(
            userData["name"] ?? "",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            userData["emailId"] ?? "",
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            userData["phoneNo"] ?? "",
            style: TextStyle(color: Colors.white, fontSize: 12),
          )
        ],
      ),
    );
  }

  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Widget rightWidget(Map<String, dynamic> userData, String type) {
    print(userData);
    return Row(
      children: <Widget>[
        Container(
          height: 40,
          child: RaisedButton(
            onPressed: () async {
              print("hello");
              List<DocumentSnapshot> d =
                  await CommonFunction().getPost("Users");

              for (var doc in d) {
                if (doc.id.toString() == userData["phoneNo"]) {
                  setState(() {
                    user = doc;
                  });
                }
              }
              var u = user.data;
              //    print("u=${u}");
              print(user.get("pendingAmount"));
              print(user.get("approvedAmount"));
              //print(user.data["pendingAmount"]);
              //print(user.data["approvedAmount"]);
              print(userData["reward"]);
              int pending = int.parse((user.data() as dynamic)["pendingAmount"]
                  .toString()); //?? "0");
              int approved = int.parse(
                  (user.data() as dynamic)["approvedAmount"]
                      .toString()); //?? "0");
              int reward = int.parse(userData["reward"]);
              setState(() {
                pending = pending - reward;
                approved = approved + reward;
                (u as dynamic)["pendingAmount"] = pending;
                (u as dynamic)["approvedAmount"] = approved;
              });
              //  print(u);
              await _firestore
                  .collection("Users")
                  .doc(userData["phoneNo"])
                  .set((u as dynamic), SetOptions(merge: true));

              if (type == "gigs") {
                List<DocumentSnapshot> snaps =
                    await CommonFunction().getPost("Posts/Gigs/Tasks");
                var res;
                for (var task in snaps) {
                  if (task.id == userData["documentId"]) {
                    res = task.get("submittedBy");
                    //      res = task.data["submittedBy"];
                    for (var r in res) {
                      if (r["userId"].toString() ==
                          userData["userId"].toString()) {
                        setState(() {
                          res[res.indexOf(r)]["status"] = "approved";
                          print(res[res.indexOf(r)]);
                        });
                      }
                    }
                  }

                  print(res);
                }
                Map<String, dynamic> updatedPost = {"submittedBy": res};

                await _firestore
                    .collection("Posts")
                    .doc("Gigs")
                    .collection("Tasks")
                    .doc(userData["documentId"])
                    .set(updatedPost, SetOptions(merge: true));
              } else if (type == "campaign") {
                List<DocumentSnapshot> snaps =
                    await CommonFunction().getPost("Posts/Gigs/Campaign Tasks");
                var res;
                for (var task in snaps) {
                  if (task.id == userData["documentId"]) {
                    res = task.get("submittedBy");
                    // res = task.data["submittedBy"];
                    // print(res);
                    for (var r in res) {
//                    print("hello");
//                    print(r["userId"]+" "+userData["userId"]);
                      if (r["userId"].toString() ==
                          userData["userId"].toString()) {
                        setState(() {
                          res[res.indexOf(r)]["status"] = "approved";
                          print(res[res.indexOf(r)]);
                        });
                      }
                    }
                  }

                  print(res);
                }
                Map<String, dynamic> updatedPost = {"submittedBy": res};

                await _firestore
                    .collection("Posts")
                    .doc("Gigs")
                    .collection("Campaign Tasks")
                    .doc(userData["documentId"])
                    .set(updatedPost, SetOptions(merge: true));
              } else if (type == "offers") {
                List<DocumentSnapshot> snaps =
                    await CommonFunction().getPost("Posts/Offers/Tasks");
                var res;
                for (var task in snaps) {
                  if (task.id == userData["documentId"]) {
                    res = task.get("submittedBy");
                    //res = task.data["submittedBy"];
                    // print(res);
                    for (var r in res) {
//                    print("hello");
//                    print(r["userId"]+" "+userData["userId"]);
                      if (r["userId"].toString() ==
                          userData["userId"].toString()) {
                        setState(() {
                          res[res.indexOf(r)]["status"] = "approved";
                          print(res[res.indexOf(r)]);
                        });
                      }
                    }
                  }

                  print(res);
                }
                Map<String, dynamic> updatedPost = {"submittedBy": res};

                await _firestore
                    .collection("Posts")
                    .doc("Offers")
                    .collection("Tasks")
                    .doc(userData["documentId"])
                    .set(updatedPost, SetOptions(merge: true));
              }

              await getpref();
            },
            child: Row(
              children: <Widget>[
                Text(userData["reward"] + "Rs." ?? ""),
                SizedBox(
                  width: 4,
                ),
                Text(
                  "Approve",
                  style: TextStyle(color: Colors.green),
                )
              ],
            ),
          ),
        ),
//        Container(
//            child: IconButton(
//              onPressed: (){
//                downloadTaskImg(userData["uploadWorkUri"]);
//              },
//              icon: Icon(Icons.file_download,
//                size: 20,color: Colors.white,
//              ),
//            )
//        )
      ],
    );
  }
}
