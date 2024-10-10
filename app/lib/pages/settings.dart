import 'package:crmDeliciu/utilities/backend.dart';
import 'dart:convert';
import 'package:crmDeliciu/utilities/screen.dart';
import 'package:flutter/material.dart';
import 'package:crmDeliciu/utilities/settingsBuilder.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<TextEditingController> settingControllers = List.empty(growable: true);
  late Map<String, dynamic> orgSettings;
  late List<String> orgSettingKeys;
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getAllApiSettings(),
      builder: (context, snapshot) {
        if(snapshot.hasData){
          orgSettings = jsonDecode(snapshot.data.body);
          orgSettingKeys = List.empty(growable: true);
          for(String key in orgSettings.keys){
            orgSettingKeys.add(key);
          }
          return SizedBox(
            width: getPercentFromScreen("horizontal", 96, context),
            child: ListView.builder(
              itemCount: orgSettings.keys.length,
              itemBuilder:(context, index) {
                String fieldName = orgSettingKeys[index];
                Map<String, dynamic> settings = orgSettings[fieldName]!;
                List<Widget> resultingWidget = List.empty(growable: true);
                void textUpdated(newText, settingName){
                  print("$settingName: $newText"); 
                  print("$orgSettings");
                  String fieldName = "didn't find :(";
                  orgSettings.forEach((key, value) { 
                    if(value.containsKey(settingName)){
                      fieldName = key;
                    };
                  });
                  print(fieldName);
                  print(settingName);
                  print(newText);
                  setApiSetting(fieldName, settingName, newText); 
                }
                for(dynamic settingName in settings.keys){
                  settingControllers.add(new TextEditingController());
                  settingControllers.last.text = settings[settingName].toString();
                  resultingWidget.add(
                    SizedBox(
                      height: getPercentFromScreen("vertical", 5, context),
                      width: getPercentFromScreen("horizontal", 96, context),
                      child: Material(child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Text(
                            settingName + ": ",
                            style: TextStyle(
                              decoration: TextDecoration.none,
                              color: secondaryColor,
                              fontSize: getPercentFromScreen("horizontal", 1.5, context)
                            )
                          ),
                          Positioned(
                            right: 0,
                            child: SizedBox(
                              width: getPercentFromScreen("horizontal", 25, context),
                              height: getPercentFromScreen("vertical", 4, context),
                              child: TextField(
                                clipBehavior: Clip.none,
                                onChanged:(value) {
                                  String thisSetting = settingName.toString();
                                  textUpdated(value ,thisSetting);
                                },
                                controller: settingControllers.last,
                                cursorColor: primaryColor,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: secondaryColor,
                                      width: 1.25
                                    )
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: primaryColor,
                                      width: 3
                                    )
                                  )
                                ),
                              )
                            )
                          )
                        ]
                      )
                    ))
                  );
                }
                return SizedBox(
                  height: settings.keys.length * getPercentFromScreen("vertical", 5, context),
                  child: Column(children: resultingWidget)
                );
              },
            )
          );
        }else{
          return Container();
        }
      },
    );
  }
}