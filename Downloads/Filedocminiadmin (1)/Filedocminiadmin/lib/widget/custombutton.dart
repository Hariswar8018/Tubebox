import 'package:file_dock/constant/colors.dart';
import 'package:flutter/material.dart';

class Custombutton extends StatelessWidget {
  final String text;
  Custombutton({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 249,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),

        color: kblueaccent,
      ),
      child: Padding(
        padding: EdgeInsetsGeometry.only(
          top: 8,
          right: 10,
          bottom: 8,
          left: 10,
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
