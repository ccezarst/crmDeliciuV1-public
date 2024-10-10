import 'package:flutter/material.dart';
// import the pages header file which will contain
// a refrence to all the pages
// and call it pages for clearer code
import 'package:crmDeliciu/pages.dart' as pages;
void main() {
  runApp(const RootWidget());
}

class RootWidget extends StatelessWidget {
  const RootWidget({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Management app',
      // this app doesn't require multiple navigators so 
      // it's okay to use this simpler solution
      initialRoute: "/homePage",
      routes: {
        "/homePage": (context) => pages.HomePage(pageName: "/warehouse"),
        "/warehouse": (context) => pages.HomePage(pageName: "/warehouse"),
        "/needsBuilding": (context) => pages.HomePage(pageName: "/needsBuilding"),
        "/settings": (context) => pages.HomePage(pageName: "/settings"),
      }
    );
  }
}
