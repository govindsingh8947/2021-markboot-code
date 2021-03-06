import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/common_widgets.dart';
import 'package:markboot/common/style.dart';

class InternshipPageTab extends StatefulWidget {
  @override
  _InternshipPageTabState createState() => _InternshipPageTabState();
}

class _InternshipPageTabState extends State<InternshipPageTab> {
  List<DocumentSnapshot> documentList = [];
  int iscomplete = 1;

  Future<void> _onRefresh() async {
    documentList =
        await CommonFunction().getPost("Posts/Internship/Internship");
    debugPrint("REFRESHSNAP $documentList");
    return;
  }

  init() async {
    try {
      documentList =
          await CommonFunction().getPost("Posts/Internship/Internship");
      debugPrint("DocumentSNAP $documentList");
      setState(() {});
    } catch (e) {
      print(33);
      debugPrint("Exception : (init)-> $e");
    }
    setState(() {
      iscomplete = 0;
    });
  }

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(CommonStyle().new_theme), //Color(0xff051094),
        //backgroundColor: Color(CommonStyle().blueColor),
        title: Text(
          "Internship",
        ),
      ),
      body: iscomplete == 1
          ? Center(
              child: LoadingFlipping.circle(
                borderColor: Colors.blue,
                size: 50,
                borderSize: 5,
              ),
            )
          : CustomScrollView(
              primary: false,
              slivers: <Widget>[
                documentList.length > 0
                    ? SliverPadding(
                        padding: const EdgeInsets.all(10),
                        sliver: SliverGrid.count(
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          crossAxisCount: 1,
                          childAspectRatio: 3,
                          children: documentList.map((item) {
                            return CommonWidget().commonCard(
                                item, context, "Internship",
                                subtype: "Internship");
                          }).toList(),
                        ),
                      )
                    : (documentList == null
                        ? SliverToBoxAdapter(
                            child: Container(
                            margin: EdgeInsets.only(top: 50),
                            child: Center(
                              child: Container(
                                  child: LoadingFlipping.circle(
                                borderColor: Colors.blue,
                                size: 50,
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
    );
  }
}
