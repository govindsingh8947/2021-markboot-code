import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:markboot/common/bottombarnavigation.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/common_widgets.dart';
import 'package:markboot/common/style.dart';
import 'package:markboot/pages/homeScreen/tab/gigs/gigs_page_tab.dart';
import 'package:markboot/pages/homeScreen/tab/gigs/tasks_page.dart';
import 'package:markboot/pages/homeScreen/tab/internship/internship_details.dart';
import 'package:markboot/pages/homeScreen/tab/internship/internship_tab.dart';
import 'package:markboot/pages/homeScreen/tab/offers/cashbacks_page.dart';
import 'package:markboot/pages/homeScreen/tab/offers/offers_page_tab.dart';
import 'package:markboot/pages/homeScreen/tab/tournament/tournament_tab.dart';
import 'package:permission_handler/permission_handler.dart';
import 'tab/profile/user_profile_tab.dart';
import 'tab/tournament/tournament_details_page.dart';

late ScrollController _scrollController; //late is added

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late double _containerMaxHeight = 56,
      _offset,
      _delta = 0,
      _oldOffset = 0; //late is added
  int _currentIndex = 0;
  late PageController _pageController;
  int currentIndex = 0;
  late double _width, _height;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  CommonWidget commonWidget = CommonWidget();
  CommonFunction commonFunction = CommonFunction();
  late List<DocumentSnapshot> documentList;

  init() async {
    documentList = await commonFunction.getPost("Posts/Offers/Cashback");
    // debugPrint("DocumentSNAP $documentList");
    setState(() {});
  }

  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print('permission   $info');
  }

  @override
  void initState() {
    init();
    super.initState();
    _requestPermission();
    _pageController = PageController();
    _offset = 0;
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          double offset = _scrollController.offset;
          _delta += (offset - _oldOffset);
          if (_delta > _containerMaxHeight)
            _delta = _containerMaxHeight;
          else if (_delta < 0) _delta = 0;
          _oldOffset = offset;
          _offset = -_delta;
        });
        // debugPrint("OFFSET $_offset");
      });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;
    return SafeArea(
      child: Scaffold(
        //backgroundColor: Color(CommonStyle().darkBlueColor),
        backgroundColor: Color(CommonStyle().new_theme), //Color(0xff051094),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SizedBox.expand(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  currentIndex = index;
                  if (currentIndex != 0) {
                    _offset = 0;
                  }
                  setState(() => _currentIndex = index);
                },
                children: <Widget>[
                  HomeTab(), // basically this is the home page of the app
                  GigsPageTab(),
                  OffersPageTab(
                    docList: {},
                    isRedirectFromProfile: false,
                  ),
                  InternshipPageTab(),
                  TournamentPageTab(
                    docList: {},
                    isRedirectFromProfile: false,
                  ),
                  UserProfileTab(),
                ],
              ),
            );
          },
        ),

        // This is the bottom navigation bar of the home page
        bottomNavigationBar: Container(
            width: double.infinity,
            color: Colors.red,
            height: _offset + 56,
            child: BottomNavyBar(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              backgroundColor:
                  Color(CommonStyle().new_theme), //Color(0xff051094),
              selectedIndex: _currentIndex,
              onItemSelected: (index) {
                setState(() => _currentIndex = index);
                _pageController.jumpToPage(index);
              },
              items: <BottomNavyBarItem>[
                BottomNavyBarItem(
                    activeColor: Colors.white,
                    inactiveColor: Colors.white,
                    textAlign: TextAlign.start,
                    title: Text('Home'),
                    icon: Image.asset(
                      "assets/icons/home.png",
                      width: MediaQuery.of(context).size.width * 0.05,
                      height: 20,
                      color: Colors.white,
                    )),
                BottomNavyBarItem(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white,
                  title: Text('Gigs'),
                  icon: Image.asset(
                    "assets/icons/gigs.png",
                    width: MediaQuery.of(context).size.width * 0.05,
                    height: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start, //THIS IS ADDED
                ),
//              home,gigs,offers,internship, tournament,profile
                BottomNavyBarItem(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white,
                  title: Text('Offers'),
                  icon: Image.asset(
                    "assets/icons/offers.png",
                    width: MediaQuery.of(context).size.width * 0.055,
                    height: 28,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start, //THIS IS ADDED
                ),
                BottomNavyBarItem(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white,
                  title: Text('Internship'),
                  icon: Image.asset(
                    "assets/icons/internship.png",
                    width: MediaQuery.of(context).size.width * 0.05,
                    height: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start, //THIS IS ADDED
                ),
                BottomNavyBarItem(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white,
                  title: Text('Tournament'),
                  icon: Image.asset(
                    "assets/icons/tourn.png",
                    width: MediaQuery.of(context).size.width * 0.05,
                    height: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start, //THIS IS ADDED
                ),
                BottomNavyBarItem(
                  activeColor: Colors.white,
                  inactiveColor: Colors.white,
                  title: Text('Profile'),
                  icon: Image.asset(
                    "assets/icons/user.png",
                    width: MediaQuery.of(context).size.width * 0.05,
                    height: 20,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.start, //THIS IS ADDED
                ),
              ],
            )),
      ),
    );
  }

  Future<void> _onRefresh() async {
    documentList = await commonFunction.getPost("Posts/Offers/Cashbacks");
    // debugPrint("REFRESHSNAP $documentList");
    return;
  }
}

// This is the home page of the app that is shown to the user
class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with SingleTickerProviderStateMixin {
  List<String> introImages = [
    "assets/icons/list.png",
    "assets/icons/money.png",
    "assets/icons/purchase.png"
  ];
  late List<DocumentSnapshot> documentList_cash = [];
  late List<DocumentSnapshot> documentList_50_50 = [];

  late List<Map> headerSwipeList = [];
  late TabController _tabController;
  SwiperController swiperCont = new SwiperController();

  init() async {
    try {
      documentList_cash = await CommonFunction().getPost(
          "Posts/Offers/Cashbacks"); // cashback offers are fetched from the database
      documentList_50_50 = await CommonFunction()
          .getPost("Posts/Offers/50 on 500"); //?? is removed from above line

      int i = 1;
      // ignore: deprecated_member_use
      headerSwipeList = []; //new List();
      for (DocumentSnapshot snapshot in documentList_cash) {
        // it contains 7 items
        // print(documentList_cash.length);
        DocumentSnapshot snap = snapshot;
        if ((snapshot.data() as dynamic) != null &&
            (snapshot.data() as dynamic) == true) {
          print(snapshot.id);
          headerSwipeList.add({"type": "Cashbacks", "docx": snap});
        }

        if ((snapshot.data() as dynamic)["isImportant"] !=
                null && //snapshot.data["isImportant"]
            (snapshot.data() as dynamic)["isImportant"] == true) {
          print(snapshot.id);
          headerSwipeList.add({"type": "Cashbacks", "docx": snap});

          // print("Above the headerSwipe List =================================");
          // print(headerSwipeList);
          if (i == 4) break;
          i++;
        }
      }

      // Two documents will be added in this list initially
      for (DocumentSnapshot snapshot in documentList_50_50) {
        // print('doclist50_50');
        // print(documentList_50_50.length);
        DocumentSnapshot snap = snapshot;

        if ((snap.data() as dynamic)["isImportant"] !=
                null && //square to braces  snapshot.data()
            (snap.data() as dynamic)["isImportant"] == true) {
          //data("isImportant")
          headerSwipeList.add({"type": "50 on 50", "docx": snap});
          if (i == 4) break;
          i++;
        }
      }
      setState(() {});
    } catch (e) {
      debugPrint("Exception : (init)-> $e");
    }
  }

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // backgroundColor: Color(CommonStyle().blueColor),
          backgroundColor: Color(CommonStyle().new_theme), //Color(0xff051094),
          title: Text(
            "MarkBoot",
            style: TextStyle(
                fontWeight:
                    FontWeight.bold), // this is where the app bar begins
          ),
        ),
        body: CustomScrollView(
          controller: _scrollController,
          slivers: <Widget>[
//            SliverToBoxAdapter(
//              child: Align(
//                alignment: Alignment.centerLeft,
//                child: Container(
//                  margin: EdgeInsets.only(left: 20,top: 10),
//                  child: CircleAvatar(
//                    radius: 30,
//                    backgroundImage: AssetImage("assets/icons/mb_icon.png",),
//                  ),
//                ),
//              )
//            ),
            SliverToBoxAdapter(child: swiperBody()),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 10,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(height: 750, child: RecentPageView()),
            )
          ],
        ));
  }

  Widget swiperBody() {
    return Container(
        height: 200,
        margin: EdgeInsets.only(top: 10),
        child: headerSwipeList == null
            ? Container(
                margin: EdgeInsets.only(top: 0),
                child: Center(
                  child: Container(
                      child: LoadingFlipping.circle(
                    borderColor: Color(CommonStyle().new_theme), //Colors.blue,
                    size: 50,
                    borderSize: 5,
                  )),
                ),
              )
            : Swiper(
                //loop: true,
                autoplay: true,
                //controller: SwiperController(),
                pagination: SwiperPagination(
                    builder: DotSwiperPaginationBuilder(
                        color: Colors.white,
                        activeColor: Color(CommonStyle()
                            .new_theme), //Color(CommonStyle().lightYellowColor),
                        activeSize: 20.0,
                        size: 10 //10
                        )),
                itemHeight: 100,
                itemBuilder: (BuildContext context, int index) {
                  return Stack(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          // print(headerSwipeList[index]["type"]);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CashbacksPageDetails(
                                        snapshot: headerSwipeList[index]
                                            ["docx"],
                                        type: "Offers",
                                        subType: headerSwipeList[index]["type"],
                                      )));
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  headerSwipeList[index]["docx"]["offerUri"]),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Text(
                          "",
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    ],
                  );
                },
                itemCount:
                    headerSwipeList == null ? 0 : (headerSwipeList.length),
                scale: 0.6,
                fade: 0.5,
                viewportFraction: 0.95,
              ));
  }
}

// This the grid thing here
class RecentPageView extends StatefulWidget {
  @override
  _RecentPageViewState createState() => _RecentPageViewState();
}

class _RecentPageViewState extends State<RecentPageView> {
  PageController _controller = PageController(
    initialPage: 0,
  );
  int activePageIndex = 0;
  late List<DocumentSnapshot> gigsSnapList = []; // = new List();
  late List<DocumentSnapshot> offersSnapList = []; // = new List();
  late List<DocumentSnapshot> internshipSnapList = []; // = new List();
  late List<DocumentSnapshot> tournamentSnapList = []; //= new List();
  List<int> cardColor = [
    CommonStyle().cardColor1,
    CommonStyle().cardColor2,
    CommonStyle().cardColor3,
    CommonStyle().cardColor4
  ];

  init() async {
    try {
      QuerySnapshot gigsQuerySnap = await FirebaseFirestore.instance
          .collection("Posts")
          .doc("Gigs")
          .collection("Gigs")
          .get();
      int len = 0;
      for (DocumentSnapshot snapshot in gigsQuerySnap.docs) {
        print("hemo g");
        if ((snapshot.data() as dynamic)["Status"]) {
          gigsSnapList.add(snapshot);
          len++;
        }
        if (len >= 4) break;
      }
      setState(() {});

      // Only a maximum of 4 offers will be shown/ added to the list of offerSnapList
      QuerySnapshot offersQuerySnap = await FirebaseFirestore.instance
          .collection("Posts")
          .doc("Offers")
          .collection("Cashbacks")
          .get();
      len = 0;
      for (DocumentSnapshot snapshot in offersQuerySnap.docs) {
        offersSnapList.add(snapshot);
        len++;
        if (len >= 4) break;
      }
      QuerySnapshot internshipQuerySnap = await FirebaseFirestore.instance
          .collection("Posts")
          .doc("Internship")
          .collection("Internship")
          .get();
      len = 0;
      for (DocumentSnapshot snapshot in internshipQuerySnap.docs) {
        internshipSnapList.add(snapshot);
        len++;
        if (len >= 4) break;
      }

      /// There is no Tournament document so this is dead code at the moment
      ///
      /// !_____________________________________________________!
      QuerySnapshot tournamentQuerySnap = await FirebaseFirestore.instance
          .collection("Posts")
          .doc("Tournament")
          .collection("Tournament")
          .get();
      len = 0;
      for (DocumentSnapshot snapshot in tournamentQuerySnap.docs) {
        tournamentSnapList.add(snapshot);
        len++;
        if (len >= 4) break;
      }
      setState(() {});
    } catch (e) {
      debugPrint("Error : $e");
    }
  }

  @override
  void initState() {
    init();
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          height: 80,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          //color: Color(CommonStyle().blueColor),
          color: Color(CommonStyle().new_theme), //Color(0xff051094),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Text(
                  "RECENTS",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      if (activePageIndex != 0) {
                        setState(() {
                          activePageIndex = 0;
                          _controller.jumpToPage(activePageIndex);
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 70,
                      height: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: activePageIndex == 0
                              ? Color(CommonStyle().lightYellowColor)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Gigs",
                        style: TextStyle(
                            color: activePageIndex == 0
                                ? Colors.white
                                : Color(0xff051094),
                            fontSize: 14),
                      ),
                    ),
                  ),

                  // Changes ahead
                  GestureDetector(
                    onTap: () {
                      print("123");
                      if (activePageIndex != 1) {
                        setState(() {
                          activePageIndex = 1;
                          _controller.jumpToPage(activePageIndex);
                        });
                      }
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: 70,
                      height: 25,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: activePageIndex == 1
                              ? Color(CommonStyle().lightYellowColor)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        "Offers",
                        style: TextStyle(
                            color: activePageIndex == 1
                                ? Colors.white
                                : Color(0xff051094),
                            fontSize: 14),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (activePageIndex != 2) {
                        setState(() {
                          activePageIndex = 2;
                          _controller.jumpToPage(activePageIndex);
                        });
                      }
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 70,
                        height: 25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: activePageIndex == 2
                                ? Color(CommonStyle().lightYellowColor)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Internship",
                          style: TextStyle(
                              color: activePageIndex == 2
                                  ? Colors.white
                                  : Color(0xff051094),
                              fontSize: 14),
                        )),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (activePageIndex != 3) {
                        setState(() {
                          activePageIndex = 3;
                          _controller.jumpToPage(activePageIndex);
                        });
                      }
                    },
                    child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 90,
                        height: 25,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: activePageIndex == 3
                                ? Color(CommonStyle().lightYellowColor)
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          "Tournament",
                          style: TextStyle(
                              color: activePageIndex == 3
                                  ? Colors.white
                                  : Color(0xff051094),
                              fontSize: 14),
                        )),
                  ),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: PageView(
            onPageChanged: (index) {
              activePageIndex = index;
              // debugPrint("Index $index");

              setState(() {});
            },
            controller: _controller,
            children: [
              GigsPageWidget(),
              OffersPageWidget(),
              InternshipPageWidget(),
              TournamentPageWidget(),
            ],
          ),
        )
      ],
    );
  }

  Widget GigsPageWidget() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: GridView.builder(
          itemCount: gigsSnapList.length,
          primary: false,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 2.4 / 3),
          itemBuilder: (context, index) {
            return Container(
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TasksPageDetails(
                        snapshot: gigsSnapList[index],
                        type: "Gigs",
                        subType: "Tasks",
                        isDisabled: false,
                      ),
                    ),
                  );
                },
                child: Card(
                  elevation: 3,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        gigsSnapList[index]["logoUri"]))),
                          ),
                        ),
                        //Task Title is no to be shown
                        // Padding(
                        //   padding: const EdgeInsets.only(
                        //       left: 4, right: 2, top: 2, bottom: 2),
                        //   child: Text(
                        //     gigsSnapList[index]["taskTitle"] ?? "",
                        //     overflow: TextOverflow.clip,
                        //     maxLines: 1,
                        //     style: TextStyle(
                        //         color: Colors.black54,
                        //         fontSize: 20,
                        //         fontWeight: FontWeight.bold),
                        //   ),
                        // ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          height: 50,
                          child: Center(
                            child: Text(
                              gigsSnapList[index]["companyName"] ?? "",
                              style: TextStyle(
                                  // color: Color(CommonStyle().lightYellowColor),
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
    );
  }

  Widget OffersPageWidget() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: GridView.builder(
              itemCount: offersSnapList.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              primary: false,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.4 / 3),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Card(
                      elevation: 3,
                      // color: Colors.transparent,
                      // borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CashbacksPageDetails(
                                        snapshot: offersSnapList[index],
                                        type: "Offers",
                                        subType: "Cashbacks",
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              offersSnapList[index]
                                                  ["logoUri"]))),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, right: 2, top: 2, bottom: 2),
                                child: Text(
                                  offersSnapList[index]["taskTitle"] ?? "",
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                height: 60,
                                child: Text(
                                  offersSnapList[index]["companyName"] ?? "",
                                  style: TextStyle(
                                    //                  color: Color(CommonStyle().lightYellowColor),
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                );
              }),
        ),
        //home Page Offers
        Padding(
          padding: EdgeInsets.all(20),
          child: GridView.builder(
              itemCount: offersSnapList.length,
              primary: false,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.4 / 3),
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Card(
                      elevation: 3,
                      // color: Colors.transparent,
                      // borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CashbacksPageDetails(
                                        snapshot: offersSnapList[index],
                                        type: "Offers",
                                        subType: "OnHomePage",
                                      )));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: NetworkImage(
                                              offersSnapList[index]
                                                  ["logoUri"]))),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 4, right: 2, top: 2, bottom: 2),
                                child: Text(
                                  offersSnapList[index]["taskTitle"] ?? "",
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                height: 60,
                                child: Text(
                                  offersSnapList[index]["companyName"] ?? "",
                                  style: TextStyle(
                                    //                  color: Color(CommonStyle().lightYellowColor),
                                    color: Colors.black,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )),
                );
              }),
        ),
      ],
    );
  }

  Widget InternshipPageWidget() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: GridView.builder(
          itemCount: internshipSnapList.length,
          primary: false,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2 / 3),
          itemBuilder: (context, index) {
            return Container(
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: Card(
                  elevation: 3,
                  // color: Colors.transparent,
                  // borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => InternshipPageDetails(
                                  snapshot: internshipSnapList[index],
                                  type: "Internship",
                                  subType: "Internship")));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      fit: BoxFit.fill,
                                      image: NetworkImage(
                                          internshipSnapList[index]
                                              ["logoUri"]))),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 4, right: 2, top: 2, bottom: 2),
                            child: Text(
                              internshipSnapList[index]["taskTitle"] ?? "",
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: 60,
                            child: Text(
                              internshipSnapList[index]["companyName"] ?? "",
                              style: TextStyle(
                                //                  color: Color(CommonStyle().lightYellowColor),
                                color: Colors.black,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            );
          }),
    );
  }

  Widget TournamentPageWidget() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: GridView.builder(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemCount: tournamentSnapList.length,
        primary: false,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2 / 3),
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Card(
                elevation: 3,
                // color: Colors.transparent,
                // borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TournamentDetailsPage(
                                snapshot: tournamentSnapList[index],
                                type: "Gigs",
                                subType: "Tasks")));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(
                                        tournamentSnapList[index]["logoUri"]))),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 4, right: 2, top: 2, bottom: 2),
                          child: Text(
                            tournamentSnapList[index]["taskTitle"] ?? "",
                            overflow: TextOverflow.clip,
                            maxLines: 1,
                            style: TextStyle(
                                color: Colors.black54,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          height: 60,
                          child: Text(
                            tournamentSnapList[index]["companyName"] ?? "",
                            style: TextStyle(
                              //                  color: Color(CommonStyle().lightYellowColor),
                              color: Colors.black,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          );
        },
      ),
    );
  }
}
