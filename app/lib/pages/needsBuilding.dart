// ignore_for_file: prefer_const_constructors, must_be_immutable
import 'package:crmDeliciu/utilities/screen.dart';
import 'package:flutter/material.dart';

class needsBuildingPage extends StatelessWidget {
  const needsBuildingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: getPercentFromScreen("horizontal", 15, context),
              right: getPercentFromScreen("horizontal", 1, context)
            ),
            child: Icon(
              Icons.handyman,
              size: getPercentFromScreen("horizontal", 3, context),
              color: primaryColor
            )
          ),
          Text(
            "Aceasta pagina trebuie sa fie construita",
            style: TextStyle(
              fontSize: getPercentFromScreen("horizontal", 3, context),
              color: primaryColor,
              decoration: TextDecoration.none
            )
          )
        ],
      )
    );
  }
}