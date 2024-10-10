import 'package:crmDeliciu/utilities/screen.dart';
import 'package:flutter/material.dart';

class SettingsBuilder extends StatefulWidget {
  SettingsBuilder({super.key, required this.width, required this.initStateFinished});
  Function initStateFinished;
  double width;
  @override
  State<SettingsBuilder> createState() => SettingsBuilderState();
}

class SettingsBuilderState extends State<SettingsBuilder> {
  List<Widget> settingTabs = List.empty(growable: true);
  List<GlobalKey<__SettingTabState>> settingTabKeys = List.empty(growable: true);
  void clear(){
    settingTabKeys.clear();
    settingTabs.clear();
  }
  @override
  void initState() {
    super.initState();
    widget.initStateFinished();
  }
  // tabs for grouping settings toghether,
  // each setting gets passed a callback function that returns a value
  // based on it's type
  // this makes development much easier
  int addTab(String? title){
    if(title != null){
      setState(() {
        // the widget and the keys are going to have the same index if everything goes
        // acordingly to the plan
        // if not then shit's going to hit the fan
        // and il be fucked and have to debug this for hours
        // i mean i could use a map and probably i'l regret not using a map
        // but i'm lazy
        debugPrint("a");
        GlobalKey<__SettingTabState> gKey = GlobalKey<__SettingTabState>();
        settingTabKeys.add(gKey);
        settingTabs.add(_SettingTab(key: gKey));
      });
      // this might be confusing so i'l walk you through
      // so basically this function returns the index of the tab in the settignsTab list
      // and because i just added a new element to this list, it's length is going to
      // be +1
      // and counts from 1(one element = length 1)
      // while dart indexes lists from 0(first elemnent = index 0)
      // so by subrtacting one from the length i get the element's index
      return settingTabs.length - 1;
    }else{
      setState(() {
        // the widget and the keys are going to have the same index if everything goes
        // acordingly to the plan
        // if not then shit's going to hit the fan
        // and il be fucked and have to debug this for hours
        // i mean i could use a map and probably i'l regret not using a map
        // but i'm lazy
        debugPrint("c");
        GlobalKey<__SettingTabState> gKey = GlobalKey<__SettingTabState>();
        settingTabKeys.add(gKey);
        settingTabs.add(_SettingTab(key: gKey));
      });
      // this might be confusing so i'l walk you through
      // so basically this function returns the index of the tab in the settignsTab list
      // and because i just added a new element to this list, it's length is going to
      // be +1
      // and counts from 1(one element = length 1)
      // while dart indexes lists from 0(first elemnent = index 0)
      // so by subrtacting one from the length i get the element's index
      return settingTabs.length - 1;
    }
  }
  // tabIndex = the index of the tab in settingTabs
  // settingName = the actualy title of the setting, for example push notifications
  // settingType = the type of setting, for example radio or switch button etc..
  // updateCallback = when the value of the setting is updated, call said callback
  // (optional) nameStyle = the style to be applied to the title's Text widget
  void addSettingToTab({required int tabIndex, required String settingName, required String settingType, required Function updateCallback, TextStyle? nameStyle}){
    try{
        debugPrint("b");
        print(settingTabKeys[tabIndex]);  
        settingTabKeys[0].currentState!.addSetting(tabIndex: tabIndex, settingName: settingName, settingType: settingType, updateCallback: updateCallback, nameStyle: nameStyle);
        setState(() {
          // hehe it autofilled the params cuz it's the same names :)))
        });
    }catch(err){
      debugPrint("Fucking retard");
      debugPrint("You got an error trying to add a setting to a tab💀💀");
      debugPrint(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // constrain width so no errors occur :)
      width: getPercentFromScreen("horizontal", widget.width, context),
        child: ListView(
          children: settingTabs,
      )
    );
  }
}

class _SettingTab extends StatefulWidget {
  const _SettingTab({super.key});

  @override
  State<_SettingTab> createState() => __SettingTabState();
}

class __SettingTabState extends State<_SettingTab> {
  List<Widget> childSettings = List.empty(growable: true);
  void addSetting({required int tabIndex, required String settingName, required String settingType, required Function updateCallback, TextStyle? nameStyle}){
    setState(() {
      childSettings.add(_SettingWidget());
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: BorderRadius.circular(12)
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: getPercentFromScreen("vertical", 1, context)),
        child: Column(
          children: childSettings
        )
      )
    );
  }
}



class _SettingWidget extends StatefulWidget {
  const _SettingWidget({super.key});

  @override
  State<_SettingWidget> createState() => __SettingWidgetState();
}

class __SettingWidgetState extends State<_SettingWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      height: 20,
    );
  }
}