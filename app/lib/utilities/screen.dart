// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'dart:ui';
const Color primaryColor = Color(0xFFA60959);
const Color secondaryColor = Color(0xFF383838);
const Color backgroundColor = Color(0xFFFFFFFF);
// TODO: GET MAX PERCENT OUT OF CURRENT SCREEN
// max percent is percent out of 1920x1080
// basically max percent is to prevent objects becoming too big, but i don't think i use it
// but DON't REMOVE
double getPercentFromScreen(String type, double percent, BuildContext context, {double maxPercent = double.infinity}){
  double result = 0;
  if(type == "vertical"){
    result = MediaQuery.of(context).size.height * percent / 100;
    // org result is maxPrecent out of 1920x1080
    double orgResult = 1920 * maxPercent / 100;
    return (result > orgResult) ?  orgResult : result;
  }else if(type == "horizontal"){
    result = MediaQuery.of(context).size.width * percent / 100;
    double orgResult = 1080 * maxPercent / 100;
    return (result > orgResult) ? orgResult : result;
  }else{
    throw "Incorrect parameters passed to getPercentFromScreen";
  }
  // if result bigger than maxPercent return maxPercent
  
} 
// every alert shown on the screen will have a sort of Alert ID
// this allows me to update the context it uses and rebuild it
// in case an operation completes in the background and changes the context
class _LoggerClass_GUI_Alert {
  _LoggerClass_GUI_Alert({required this.context, required this.title, required this.children, });
  BuildContext context;
  String title;
  List<Widget> children;
  void updateContext(BuildContext newContext){
    context = newContext;
  }
  void show(){
    showDialog(
      context: context, 
      builder: (funcContext){
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: children
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      }
    );
  }
}
_LoggerClass logger = _LoggerClass();
class _LoggerClass_GUI {
  // returns an AlertID
  // the user is going probably only see like one alert at a time but 
  // you can never be too sure
  List<_LoggerClass_GUI_Alert> alerts = List.empty(growable: true);
  int throwUserError(String title, List<Widget> children, BuildContext context){
    int alertIndex = alerts.length;
    alerts.add(_LoggerClass_GUI_Alert(
      context: context,
      title:  title,
      children: children
    ));
    alerts[alertIndex].show();
    return alertIndex;
  }
  void updateAlertContext(BuildContext newContext, int alertIndex){
    alerts[alertIndex].updateContext(newContext);
  }
  void clearAlerts(){
    alerts.clear();
  }
}
class _LoggerClass {
  _LoggerClass_GUI gui = _LoggerClass_GUI();
  void showError(String title, List<Widget> children, BuildContext context){
    gui.throwUserError(title, children, context);
  }
  void updateAlertContext(BuildContext newContext, int alertIndex){
    gui.updateAlertContext(newContext, alertIndex);
  }
  void clearAlerts(){
    gui.clearAlerts();
  }
}