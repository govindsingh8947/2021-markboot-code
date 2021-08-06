import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/pages/homeScreen/adminPages/campaigns/ongoing.dart';
import 'package:markboot/pages/homeScreen/adminPages/campaigns/register.dart';
import 'package:markboot/pages/homeScreen/adminPages/campaigns/verify.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class Campaigns extends StatefulWidget {
  @override
  _CampaignsState createState() => _CampaignsState();
}

class _CampaignsState extends State<Campaigns>
    with SingleTickerProviderStateMixin {
  List<DocumentSnapshot> usersList = []; //new List() is removed
  bool isShowInitBar = true;
  List maps_gigs = [];
  List maps_campaign = [];
  List maps_offers = [];
  List<String> items = ["1", "2", "3", "4", "5", "6", "7", "8"];
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

  getpref() async {
    // FOR THE GIGS
    List mapi = [];
    List<DocumentSnapshot> snaps =
        await CommonFunction().getPost("Posts/Gigs/Tasks");
    //print(snaps[0].data);
    for (DocumentSnapshot snapshot in snaps) {
      for (var map in snapshot.get("submittedBy"))
      //for (var map in snapshot.data["submittedBy"])
      {
        //print(map);
        if (map["status"] == "pending") {
          map["documentId"] = snapshot.id.toString();
          print(map);

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
      for (var map in snapshot.get("submittedBy")) //next line is replaced
      //for (var map in snapshot.data["submittedBy"])
      {
        //print(map);
        if (map["status"] == "pending") {
          map["documentId"] = snapshot.id.toString();
          print(map);

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
      for (var map in snapshot.get("submittedBy"))
      //for (var map in snapshot.data["submittedBy"])
      {
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

    print(maps_gigs.length);
    print(maps_campaign.length);
    print(maps_offers.length);
  }

  init() async {
    getpref();
    isShowInitBar = false;
  }

  late TabController _tabController; //late is added
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
            title: Text("Campaign"),
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
                    child: Text("Verify"),
                  ),
                ),
                Container(width: 150, child: Tab(child: Text("OnGoing"))),
                Container(width: 150, child: Tab(child: Text("Register"))),
              ],
            )),
        body: SmartRefresher(
          enablePullDown: true,
          header: WaterDropHeader(),
          controller: _refreshController,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          child: TabBarView(
            controller: _tabController,
            children: <Widget>[
              verify("Campaign", "Posts/Gigs/Campaign Tasks"),
              ongoing(),
              register()
            ],
          ),
        ));
  }
}
