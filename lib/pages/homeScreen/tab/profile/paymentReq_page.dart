import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:markboot/common/commonFunc.dart';
import 'package:markboot/common/common_widgets.dart';
import 'package:markboot/common/style.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

extension RandomOfDigits on Random {
  /// Generates a non-negative random integer with a specified number of digits.
  ///
  /// Supports [digitCount] values between 1 and 9 inclusive.
  int nextIntOfDigits(int digitCount) {
    assert(1 <= digitCount && digitCount <= 9);
    int min = (digitCount == 1 ? 0 : pow(10, digitCount - 1))
        .toInt(); //to int is added
    int max = pow(10, digitCount).toInt();
    return min + nextInt(max - min);
  }
}

class PaymentRequestPage extends StatefulWidget {
  @override
  _PaymentRequestPageState createState() => _PaymentRequestPageState();
}

class _PaymentRequestPageState extends State<PaymentRequestPage> {
  List<String> paymentMethod = ["Paytm", "PhonePay", "Google Pay"];
  late String selectedPayMethod=null as String;
  TextEditingController phoneNoCont = TextEditingController();
  TextEditingController amountCont = TextEditingController();
  TextEditingController email = TextEditingController();

  late String userPhoneNo;
  late SharedPreferences prefs;
  late String name;
  init() async {
    prefs = await SharedPreferences.getInstance();
    userPhoneNo = prefs.getString("userPhoneNo") ?? "";
    name = prefs.getString("userName")!; //! is added
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
        //backgroundColor: Color(CommonStyle().blueColor),
        backgroundColor: Color(0xff051094),
        title: Text(
          "Payment Request",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 30,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 30),
              child: DropdownButton(
                hint: Text(
                  "Select Payment Method",
                  style: TextStyle(color: Colors.black),
                ),
                dropdownColor: Color(0xff051094),
                isExpanded: true,
                onChanged: (value) {
                  selectedPayMethod = value as String; //as String is added
                  setState(() {});
                },
                value: selectedPayMethod,
                items: paymentMethod.map((e) {
                  return DropdownMenuItem(
                    value: e,
                    child: Text(
                      e,
                      style: TextStyle(color: Colors.black),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            CommonWidget().commonTextField(
                controller: phoneNoCont,
                hintText: "Phone number",
                keyboardType: TextInputType.number),
            CommonWidget().commonTextField(
                controller: email,
                hintText: "Email ID",
                keyboardType: TextInputType.text),
            CommonWidget().commonTextField(
                controller: amountCont,
                hintText: "Amount",
                keyboardType: TextInputType.number),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              width: 200,
              padding: EdgeInsets.symmetric(horizontal: 0),
              child: RaisedButton(
                color: Color(CommonStyle().lightYellowColor),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                onPressed: () {
                  requestAmountService();
                },
                child: Text(
                  "Request",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> requestAmountService() async {
    try {
      FocusScope.of(context).unfocus();
      //String user_name = name;

      if (selectedPayMethod == null) {
        Fluttertoast.showToast(
            msg: "Select payment method.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (phoneNoCont.text == null || phoneNoCont.text.length != 10) {
        Fluttertoast.showToast(
            msg: "Enter a valid phone number",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (email.text == null ||
          !email.text.contains(".") ||
          !email.text.contains("@")) {
        Fluttertoast.showToast(
            msg: "Enter valid email address.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      } else if (amountCont.text == null) {
        Fluttertoast.showToast(
            msg: "Enter valid amount.",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        return;
      }
      String amount = amountCont.text;
      String phoneNo = phoneNoCont.text;
      String emailId = email.text;
      CommonFunction().showProgressDialog(isShowDialog: true, context: context);

      // print("print ${name}");
      Random random = new Random();
      // int randomNumber = random.nextIntOfDigits(9);
      // print(random.nextIntOfDigits(9));
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(prefs.get("userPhoneNo") as String) //as String is added
          .get();
      Map<String, dynamic> userData =
          snapshot.data() as Map<String, dynamic>; //cast is added
      //String requestAmount = userData["requestAmount"] ?? "0";
      int approvedAmount = userData["approvedAmount"] ?? 0;
      print(approvedAmount.toString());
      print(phoneNo);
      // if (int.parse(requestAmount) > 0) {
      //   Fluttertoast.showToast(
      //       msg: "Another transaction is in progress",
      //       backgroundColor: Colors.red,
      //       textColor: Colors.white);
      //   CommonFunction()
      //       .showProgressDialog(isShowDialog: false, context: context);
      //   return;
      // }
      // requestAmount = (int.parse(requestAmount) + int.parse(amount)).toString();
      approvedAmount = (approvedAmount - int.parse(amount));
      print(approvedAmount.toString());
      if (approvedAmount < 0) {
        Fluttertoast.showToast(
            msg: "please try again or contact to admin",
            backgroundColor: Colors.red,
            textColor: Colors.white);
        CommonFunction()
            .showProgressDialog(isShowDialog: false, context: context);
        return;
      }
      var req = userData["request"] ?? []; //List();
      req.add({
        "user_name": name,
        "transaction_id": random.nextIntOfDigits(9).toString(),
        "requestAmount": amount,
        "paymentMethod": selectedPayMethod,
        "paymentNo": phoneNo,
        "paymentEmail": emailId,
        "status": "Processing",
      });
      print("req =$req");
      await FirebaseFirestore.instance.collection("Users").doc(userPhoneNo).set(
          {"approvedAmount": approvedAmount, "request": req},
          SetOptions(merge: true));

      Fluttertoast.showToast(
          msg:
              "Added payment request successfully \n Amount will be processed in 48 Hours",
          backgroundColor: Colors.green,
          textColor: Colors.white);
      Navigator.pop(context, true);
    } catch (e) {
      print(e);
      Fluttertoast.showToast(
          msg: "Please try again",
          backgroundColor: Colors.red,
          textColor: Colors.white);
      debugPrint("Exception :(requestAmountService)-> $e");
    }
    CommonFunction().showProgressDialog(isShowDialog: false, context: context);
  }
}
