// ignore_for_file: prefer_const_constructors, must_be_immutable
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:crmDeliciu/pages/needsBuilding.dart';
import 'package:crmDeliciu/utilities/backend.dart';
import 'package:crmDeliciu/utilities/screen.dart';
import 'package:crmDeliciu/pages/warehouse/WarehouseResult.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:file_picker/file_picker.dart';
class Warehouse_mainPage extends StatefulWidget {
  const Warehouse_mainPage({super.key});

  @override
  State<Warehouse_mainPage> createState() => _Warehouse_mainPageState();
}

class _Warehouse_mainPageState extends State<Warehouse_mainPage> {
  // ask the user before getting data from the API
  // because it takes like a minute to load it
  // because the NextUp server is really slow
  bool loadValues = false;
  String securityToken = "somethingHere";
  late Future getReqProducts;
  bool doneLoading = false;
  // total steps is absurd amount so that while loop doesn't stop after first iteration
  int loadedSteps = 0;
  int totalSteps = 100;
  late Map<String, dynamic> procResult;
  bool ShownError = false;
  int errorIndex = 0;
  @override
  Widget build(BuildContext context) {
    if(ShownError){
      logger.updateAlertContext(context, errorIndex);
    }
    if(loadValues){
      if(doneLoading){
        logger.clearAlerts();
        return ShowResults(result: procResult);
      }else{
        return Padding(
          padding: EdgeInsets.only(left: getPercentFromScreen("horizontal", 45, context)),
          child: FutureBuilder(
            future: getReqProducts,
            builder: (context, snapshot) {
              if(snapshot.hasData){
                Response data = snapshot.data;
                String proccessID = data.body;
                Future.delayed(Duration(milliseconds: 3000), () {
                  if(!doneLoading){
                    // make sure that result is nullable
                    // because if an error occurs result is going to be null
                    getProccessStatusWithCallback( proccessID, (String result, String? statusCode){
                      // if status is not 200 then function returns the status code
                      if(statusCode == null){
                        // print("Loaded steps:" + loadedSteps.toString()); 
                        // print("All steps:" + loadedSteps.toString()); 
                        Map<String, dynamic> decodedData = jsonDecode(result);
                        setState(() {
                          // if it's null it means that it hasn't yet started working on the request
                          if(decodedData != "" && decodedData["status"] != null && decodedData["info"] != null){
                            if(decodedData["status"] == "working"){
                              List<String> info = decodedData["info"]!.split(",");
                              totalSteps = int.parse(info[1]);
                              loadedSteps = int.parse(info[0]);
                            }else if(decodedData["status"] == "done"){
                              procResult = decodedData["info"];
                              doneLoading = true;
                            }
                          }
                        });
                      }else{
                        logger.showError(
                          "Error",
                          <Widget>[
                            Text('API a raspuns cu codul de status $statusCode'),
                            Text('Raspuns: $result'),
                          ],
                          context
                        );
                        ShownError = true;
                      }
                    });
                  }
                });
              }
              return Stack(
                children: [
                  Positioned(
                    top: getPercentFromScreen("vertical", 2.2, context),
                    left: getPercentFromScreen("horizontal", 1.1, context),
                    child: Text(
                      // convert loadded steps to percentage
                      (loadedSteps * 100 / totalSteps).round().toString() + "%",
                      style: TextStyle(
                        decoration: TextDecoration.none,
                        fontSize: getPercentFromScreen("horizontal", 1.6, context),
                        color: primaryColor,
                      ),
                    )
                  ),
                  LoadingAnimationWidget.threeArchedCircle(
                    color: primaryColor,
                    size: getPercentFromScreen("horizontal", 5, context)
                  )
                ]
              );
            },
          )
        );
      }
    }else{
      return Padding(
        padding: EdgeInsets.only(left: getPercentFromScreen("horizontal", 15, context,), top: getPercentFromScreen("vertical", 45, context,)),
        child: Column(
          children: [
            Text(
              "Avertizare! Trebuie sa tragi informatia inainte sa o poti vizualiza.",
              style: TextStyle(
                decoration: TextDecoration.none,
                color: primaryColor,
                fontSize: getPercentFromScreen("horizontal", 2, context)
              )
            ),
            TextButton(
              onPressed: (){
                setState(() {
                  // set its value here to stop it from loading data before user confirms data loading
                  // stop future builder from sending multiple requests
                  showDialog(
                    context: context, 
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Doresti sa importi comenzile de la NovaPan?"),
                        actions: [
                          TextButton(
                            onPressed: (){
                              Navigator.pop(context);
                              setState(() {
                                getReqProducts = getRequiredProducts();
                                loadValues = true;
                              });
                            }, 
                            child: Text("Nu")
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              // FilePickerResult? outputFile = await FilePicker.platform.pickFiles(
                              //   dialogTitle: 'Terog selecteaza fisierul de comenzi de la NovaPan',
                              // );
                              try {
                                // final file = File(outputFile!.files[0].path!);
                                // // Read the file
                                // final contents = await file.readAsString();
                                setState(() {
                                  getReqProducts = getRequiredProducts(novaPanFile: (kDebugMode) ? "debug" : "release");
                                  loadValues = true;
                                });
                              } catch (e) {
                                // If encountering an error, return
                                print("Error: " + e.toString());
                                return;
                              }
                              // ignore: dead_code
                            }, 
                            child: Text("Da")
                          ),
                        ],
                      );
                    }
                  );
                });
              }, 
              child: Container(
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(7)
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: getPercentFromScreen("horizontal", .7, context)),
                  child: Text(
                    "Vizualizeaza informatia",
                    style: TextStyle(
                      decoration: TextDecoration.none,
                      color: backgroundColor,
                      fontSize: getPercentFromScreen("horizontal", 2, context)
                    )
                  )
                )
              )
            )
          ]
        )
      );
    }
  }
}
