import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/pages/homeScreen/adminPages/campaigns/user_list.dart';

class verify extends StatefulWidget {
  String path;
  String title;
  verify(this.title, this.path);

  @override
  _verifyState createState() => _verifyState();
}

class _verifyState extends State<verify> {
  List<DocumentSnapshot> snapshots = [];

  init() async {
    try {
      print(widget.path);
      snapshots = await CommonFunction().getPost(widget.path);
      setState(() {});
      print("len" + "${snapshots.length.toString()}");
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return snapshots.length != 0
        ? CustomScrollView(
            primary: false,
            slivers: <Widget>[
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid.count(
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  crossAxisCount: 2,
                  childAspectRatio: 2 / 3,
                  children: snapshots.map((item) {
                    return singleCard(item, context, "Admin");
                  }).toList(),
                ),
              )
            ],
          )
        : Center(
            child: Text(
              "Data Not found",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          );
  }

  Widget singleCard(DocumentSnapshot snapshot, context, postType, {subtype}) {
    if (((snapshot.data() as dynamic)["submittedBy"].where((item) {
          if (item["status"] == "applied" || item["status"] == "pending") {
            return true;
          }
          return false;
        })).length ==
        0) {
      return Container();
    }
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Material(
              borderRadius: BorderRadius.circular(10),
              color: Colors.blue,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => user_list(
                              taskUserList:
                                  (snapshot.data() as dynamic)["submittedBy"] ?? [], //new List(),
                              reward: (snapshot.data() as dynamic)["reward"],
                              docId: snapshot.id)));
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Color(CommonStyle().blueCardColor),
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: // Modified the code here to add the photo
                                      NetworkImage( (snapshot.data() as dynamic)["submittedBy"]
                                          [0]["imgUri"]
                                         
                                          ??
                                          ""))),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4, right: 2, top: 2, bottom: 2),
                        child: Text(
                          widget.path.contains("Internship")
                              ? (snapshot.data() as dynamic)["companyName"] ?? ""
                              : (snapshot.data() as dynamic)["submittedBy"][0]["companyName"],
                          style: TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: 100,
                        child: Text(
                          widget.path.contains("Internship")
                              ? (snapshot.data() as dynamic)["taskTitle"] ?? ""
                              : (snapshot.data() as dynamic)["submittedBy"][0]["taskTitle"] ?? "",
                          overflow: TextOverflow.clip,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              //color: Colors.white,

                              fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
        ),
        Positioned(
            top: 5,
            right: 8,
            child: CircleAvatar(
              backgroundColor: Colors.green,
              radius: 18,
              child: Text(
                widget.path.contains("Internship")
                    ? ((snapshot.data() as dynamic)["appliedBy"]
                        .where((item) {
                          if (item["status"] == "applied") {
                            return true;
                          }
                          return false;
                        })
                        .length
                        .toString())
                    : ((snapshot.data() as dynamic)["submittedBy"]
                        .where((item) {
                          if (item["status"] == "applied") {
                            return true;
                          }
                          return false;
                        })
                        .length
                        .toString()),
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            )),
        Positioned(
            top: 5,
            left: 8,
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 18,
              child: IconButton(
                icon: Icon(
                  Icons.delete,
                  size: 20,
                  color: Colors.red,
                ),
                onPressed: () async {
                  try {
                    CommonFunction().showProgressDialog(
                        isShowDialog: true, context: context);
                    await FirebaseFirestore.instance
                        .collection(widget.path)
                        .doc(snapshot.id)
                        .delete();
                    Fluttertoast.showToast(
                        msg: "delete successfully",
                        textColor: Colors.white,
                        backgroundColor: Colors.green);
                    CommonFunction().showProgressDialog(
                        isShowDialog: false, context: context);
                    setState(() {
                      snapshots.remove(snapshot);
                      dispose();
                    });
                  } catch (e) {}
                },
              ),
            ))
      ],
    );
  }
}
