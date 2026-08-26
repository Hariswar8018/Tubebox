
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class Send{

  static void topic(BuildContext context,String str1,String str,{bool b = false}) async{
    await Flushbar(
      titleColor: Colors.white,
      message: "Lorem Ipsum is simply dummy text of the printing and typesetting industry",
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      reverseAnimationCurve: Curves.linear,
      forwardAnimationCurve: Curves.elasticOut,

      boxShadows: [BoxShadow(color: Colors.blue, offset: Offset(0.0, 2.0), blurRadius: 3.0)],
      backgroundGradient: LinearGradient(
        colors: b
            ? [Colors.green, Colors.greenAccent]
            : [Colors.red, Colors.redAccent],
      ),      isDismissible: false,
      duration: Duration(seconds: 3),
      icon: b?Icon(
        Icons.verified_rounded,color: Colors.white,
      ):Icon(
        Icons.warning,
        color: Colors.white,
      ),
      showProgressIndicator: true,
      progressIndicatorBackgroundColor: Colors.white,
      titleText:  Text(
        str1,
        style: TextStyle(fontSize: 18.0, color: Colors.white,fontWeight: FontWeight.w700, fontFamily: "ShadowsIntoLightTwo"),
      ),
      messageText: Text(
        str,
        style: TextStyle(fontSize: 14.0, color: Colors.white, fontFamily: "ShadowsIntoLightTwo"),
      ),
    ).show(context);
  }
}