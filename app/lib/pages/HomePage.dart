// ignore_for_file: prefer_const_constructors, must_be_immutable, use_build_context_synchronously
import 'package:crmDeliciu/pages.dart';
import 'package:crmDeliciu/utilities/screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:crmDeliciu/utilities/backend.dart' as backend;
// so that everything scales in sync
double _horizontalScaleRatio = 1.4;

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.pageName});
  String pageName;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  Widget childPage = needsBuildingPage();
  late Ticker _ticker;
  // basically a custom navigator
  // essentialy everytime you navigate to warehouse or orders or clients screen it's essentialy a HomePage screen with the child
  // widget being the child page
  String? showPath;
  bool update = false;
  void configs(BuildContext context) async {
    dynamic bPath = await backend.loadConfigs();
    if(bPath != false){
      showPath = bPath;
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Fisier config creeat'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Fisierul de config a fost creat la: '),
                  SelectableText(showPath.toString()),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Ok'),
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    // make this null so that HomePage renders normally.
                    showPath = null;
                  });
                },
              ),
            ],
          );
        },
      );
    }
  }
  @override
  void initState() {
    // if this returns something it means that the config file doesn't exist so print a dialogue
    // EDIT THIS TO ADD NEW ROUTES
    // doing this this way cuz why use multiple navigators?
    // to complicated😭
    switch(widget.pageName){
      case "/warehouse":
        childPage = Warehouse_mainPage();
        break;
      case "/settings":
        // fuck you flutter kys
        // currently broken cuz flutter retarded
        // childPage = SettingsPage();
        // break;
        childPage = SettingsPage();
        break;
      case "/needsBuilding":
        childPage = needsBuildingPage();
        break;
    }
    super.initState();
    logger.clearAlerts();
  }
  @override
  Widget build(BuildContext context) {
    configs(context);
    return Center(
      child: Container(
        color: backgroundColor,
        child: Row(
          children: [
            Container(
              //, maxPercent: 4 * _horizontalScaleRatio   CODE DON'T DELETE IT'S FROM THE LINE BELOW
              width: getPercentFromScreen("horizontal", 4, context),
              decoration: BoxDecoration(
                color: secondaryColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, "/warehouse");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(500)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(getPercentFromScreen("horizontal", .35, context)),
                        child: Icon(
                          Icons.warehouse,
                          color: backgroundColor,
                          // , maxPercent: 2 * _horizontalScaleRatio
                          size: getPercentFromScreen("horizontal", 2, context),
                          
                        )
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: getPercentFromScreen("vertical", 2, context)),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, "/needsBuilding");
                        print("orders");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(500)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(getPercentFromScreen("horizontal", .35, context)),
                          child: Icon(
                            Icons.shopping_cart,
                            color: backgroundColor,
                            // maxPercent: 2 * _horizontalScaleRatio
                            size: getPercentFromScreen("horizontal", 2, context,),
                          )
                        )
                      )
                    )
                  ),
                  GestureDetector(
                    onTap: (){
                      Navigator.pushNamed(context, "/needsBuilding");
                      print("clients");
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(500)
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(getPercentFromScreen("horizontal", .35, context)),
                        child: Icon(
                          Icons.account_circle,
                          color: backgroundColor,
                          //, maxPercent: 2 * _horizontalScaleRatio)
                          size: getPercentFromScreen("horizontal", 2, context),
                        )
                      )
                    )
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: getPercentFromScreen("vertical", 2, context)),
                    child: GestureDetector(
                      onTap: (){
                        Navigator.pushNamed(context, "/settings");
                        print("settings");
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(500)
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(getPercentFromScreen("horizontal", .35, context)),
                          child: Icon(
                            Icons.settings,
                            color: backgroundColor,
                            //, maxPercent: 2 * _horizontalScaleRatio
                            size: getPercentFromScreen("horizontal", 2, context),
                          )
                        )
                      )
                    )
                  ),
                ],
              )
            ),
            childPage,
          ],
        )
      )
    );
  }
}