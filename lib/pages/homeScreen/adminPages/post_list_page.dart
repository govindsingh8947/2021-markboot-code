import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/pages/homeScreen/adminPages/taskUserList_page.dart';
import 'package:markboot/pages/homeScreen/adminPages/tournament_admin_page.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'internship_userlist_page.dart';

class PostListPage extends StatefulWidget {
  String path;
  String title;

  PostListPage(
      {required this.title, required this.path}); //required is added to both

  @override
  _PostListPageState createState() => _PostListPageState();
}

class _PostListPageState extends State<PostListPage> {
  late List<DocumentSnapshot> snapshots = []; //late is added
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    // monitor network fetch
    await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use loadFailed(),if no data return,use LoadNodata()
    setState(() {});
    _refreshController.loadComplete();
  }

  init() async {
    try {
      print(widget.path);
      snapshots = await CommonFunction().getPost(widget.path);
      setState(() {});
    } catch (e) {
      print("233232323");
      debugPrint("Exception : (init) -> $e");
    }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xff051094),
        title: Text(
          widget.title + " Posts",
        ),
      ),
      body: SmartRefresher(
        enablePullDown: true,
        header: WaterDropHeader(),
        controller: _refreshController,
        onRefresh: _onRefresh,
        onLoading: _onLoading,
        child: CustomScrollView(
          primary: false,
          slivers: <Widget>[
            snapshots.length > 0
                ? SliverPadding(
                    padding: const EdgeInsets.all(20),
                    sliver: SliverGrid.count(
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: 2,
                      childAspectRatio: 2 / 3,
                      children: snapshots.map((item) {
                        //print("in here");
                        //print(item);
                        return singleCard(item, context, "Admin");
                      }).toList(),
                    ),
                  )
                : (snapshots == null
                    ? SliverToBoxAdapter(
                        child: Container(
                        margin: EdgeInsets.only(top: 50),
                        child: Center(
                          child: Container(
                              width: 30,
                              height: 30,
                              child: LoadingFlipping.circle(
                                borderColor: Colors.blue,
                                borderSize: 5,
                              )),
                        ),
                      ))
                    : SliverToBoxAdapter(
                        child: Container(
                          height: MediaQuery.of(context).size.height - 100,
                          child: Center(
                            child: Container(
                              child: Text(
                                "No Data Found",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      )),
          ],
        ),
      ),
    );
  }

  Widget singleCard(DocumentSnapshot snapshot, context, postType, {subtype}) {
    print("Inside here i am ");
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
                  if (widget.path.contains("Internship")) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InternshipUserListPage(
                                  docId: snapshot.id,
                                  internshipUserList: (snapshot.data()
                                          as dynamic)["appliedBy"] ??
                                      [], //new List(),
                                )));
                  } else if (widget.path.contains("Tournament")) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TournamentAdminDetailsPage(
                                  taskUserList: (snapshot.data()
                                          as dynamic)["submittedBy"] ??
                                      [], //new List(),
                                  //doc ID is to set after checking code
                                  docId: '',
                                )));
                  } else {
                    // for the gigs page
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TaskUserListPage(
                                taskUserList: (snapshot.data()
                                        as dynamic)["submittedBy"] ??
                                    [], //new List(),
                                reward: (snapshot.data() as dynamic)["reward"],
                                docId: snapshot.id)));
                  }
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
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 4, right: 2, top: 2, bottom: 2),
                        child: Text(
                          widget.path.contains("Internship")
                              ? 
                              (snapshot.data() as dynamic)["appliedBy"][0]["companyName"]
                              // snapshot.get(
                              //         "appliedBy//0//companyname") 
                                      ?? //snapshot.data()["appliedBAy"][0]
                                  // ["companyName"] ??
                                  //    ? snapshot.data["appliedBy"][0]["companyName"] ??
                                  //    ? snapshot.data["appliedBy"][0]["companyName"] ??
                                  ""
                              : 
                              // snapshot.get(
                              //     "submittedBy//0//comapnyName"),
                                   //data["submittedBy/0/comapnyName"][0]["companyName"],
                          (snapshot.data() as dynamic)["submittedBy"][0]["companyName"],
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
                              ? (snapshot.data() as dynamic)["appliedBy"][0]["tasktitle"] ??
                                  " " //snapshot.data["appliedBy"][0]["taskTitle"] ?? ""
                              : (snapshot.data() as dynamic)["submittedBy"][0]
                                      ["taskTitle"] ??
                                  "",
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
                    snapshots.remove(snapshot);
                    setState(() {});
                  } catch (e) {
                    print("!2121");
                  }
                },
              ),
            ))
      ],
    );
  }
}
