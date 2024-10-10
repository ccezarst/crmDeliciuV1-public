import 'package:crmDeliciu/utilities/screen.dart';
import 'package:flutter/material.dart';
import 'package:crmDeliciu/utilities/settingsBuilder.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // TODO: FIX THIS FUCKING PIECE OF SHIT!!
  
  // very important don't delete!!
  // key is used to access state where important functions are located!!
  GlobalKey<SettingsBuilderState> settingsBuilderKey = GlobalKey<SettingsBuilderState>();
  late Widget settingsBuilder;
  bool builderLoaded =  false;
  @override
  void initState() {
    // make sure that settingsBuilder finished it's initState before calling currentState
    settingsBuilder = SettingsBuilder(
      width: 40,
      key: settingsBuilderKey, 
      initStateFinished: (){
        setState(() {
          builderLoaded = true;
        });
      },);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(builderLoaded){
      // clear the tab and tab keys from it to make sure they don't dupe
      settingsBuilderKey.currentState!.clear();
      int test = settingsBuilderKey.currentState!.addTab(null);
      print(test);
      for(int i = 0; i < 1000; i+= 1){}
      settingsBuilderKey.currentState!.addSettingToTab(
        tabIndex: test,
        settingName: "nigga setting",
        settingType: "button",
        updateCallback: (){
          debugPrint("ambutakummm");
        }
      );
      setState(() {
        builderLoaded = false;
      });
    }
    return Padding(
      padding: EdgeInsets.only(left: getPercentFromScreen("horizontal", 30, context)),
      child: settingsBuilder,
    );
  }
}