// ignore_for_file: prefer_const_constructors, must_be_immutable
import 'dart:convert';
import 'package:crmDeliciu/pages/needsBuilding.dart';
import 'package:crmDeliciu/utilities/backend.dart';
import 'package:crmDeliciu/utilities/screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:flutter/scheduler.dart';
import 'package:file_picker/file_picker.dart';
// _SHOW_PRODUCT = show more info about the product
// _HIDE_PRODUCT = stop showing more info about the product
const _SHOW_PRODUCT = "activate";
const _HIDE_PRODUCT = "deactivate";
const _PRODUCT_CLICKED = "attempted";

void writeOutput(String textOutput, BuildContext context) async {
  TextEditingController controller = new TextEditingController();
  // set up the button
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () async { 
      createFile(textOutput, Directory(controller.text));
      Navigator.pop(context);
      showDialog(
        context: context, 
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Fisierul a fost salvat"),
            content: Text("Fisierul a fost salvat cu succes."),
            actions: [
              TextButton(
                onPressed: (){
                  Navigator.pop(context);
                }, 
                child: Text("Ok")
              )
            ],
          );
        },
      );
    },
  );
  // set up the AlertDialog
  controller.text = "C:\\comenziApi.csv";
  AlertDialog alert = AlertDialog(
    title: Text("Unde sa fie salvat fisierul csv?"),
    content: Row(
      children: [
        SizedBox(
          width: getPercentFromScreen("horizontal", 15, context),
          child: TextField(controller: controller,)
        ),
        TextButton(
          onPressed: () async {
            String? outputFile = await FilePicker.platform.saveFile(
              dialogTitle: 'Terog selecteaza unde sa fie salvat fisierul',
              fileName: 'comenziApi.csv',
            );
            if (outputFile != null) {
              controller.text = outputFile;
            }
          }, 
          child: Icon(
            Icons.folder
          )
        )
      ]
    ),
    actions: [
      okButton,
    ],
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
  
}

class ShowResults extends StatefulWidget {
  ShowResults({super.key, required this.result});
  Map<String, dynamic> result;
  @override
  State<ShowResults> createState() => _ShowResultsState();
}
class _ShowResultsState extends State<ShowResults> with SingleTickerProviderStateMixin{
  late Ticker _ticker;
  bool show = false;
  ScrollController _scrollController = new ScrollController();
  late List<String> resultKeys;
  // shitty solution but it works
  GlobalKey<__ProductState> defaultKey = GlobalKey();
  late GlobalKey<__ProductState> currentSelectedKey;
  String globalManager(String action, GlobalKey<__ProductState> sender){
    if(action == _PRODUCT_CLICKED){
      if(sender == currentSelectedKey){
        // so that this product can be selected again
        currentSelectedKey = defaultKey;
        return _HIDE_PRODUCT;
      }else{
        if(currentSelectedKey != defaultKey && currentSelectedKey.currentState != null){
          currentSelectedKey.currentState!.hide();
        }
        currentSelectedKey = sender;
        return _SHOW_PRODUCT;
      }
    }
    return "";
  }
  @override
  void initState() {
    super.initState();
    currentSelectedKey = defaultKey;
    _ticker = createTicker((elapsed) {
      if(show){
        resultKeys = widget.result.keys.toList();
        currentSelectedKey = defaultKey;
        show = false;
      } 
    });
    _ticker.start();
  }
  bool focusedToolBar = false;
  Widget focusedRow = Container();
  String lastFocus = "";
  void updateFocus(String newFocus){
    switch (newFocus){
      // when the options buttons is pressed
      case "options": {
        print("selected options");
        focusedRow = 
        Padding(
          padding: EdgeInsets.symmetric(horizontal: getPercentFromScreen("horizontal", 2, context)),
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: backgroundColor,
                width: 1.7
              )
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: getPercentFromScreen("vertical", 1.2, context)),
              child: Row(
                children: [
                  TextButton(
                    onPressed: (){}, 
                    child: TextButton(
                      onPressed: (){
                        List<List<dynamic>> resultList = List.empty(growable: true);
                        resultList.add(["Cod de produs", "Denumire produs",  "De comandat", "Comenzi Clienti", "Stock NextUp", "Comenzi la Furnizori", "Furnizor", "Tip Produs"]);
                        for(String procSku in resultKeys){
                          resultList.add([
                            procSku,
                            widget.result[procSku]["name"],
                            widget.result[procSku]["stockAfterPackaging"],
                            widget.result[procSku]["productsOrdered"],
                            widget.result[procSku]["nextUpStock"],
                            (widget.result[procSku]["orderedNovaPan"] == null) ? 0 : widget.result[procSku]["orderedNovaPan"],
                            widget.result[procSku]["productProvider"],
                            widget.result[procSku]["consumable"],
                          ]);
                        }
                        String textOutput = ListToCsvConverter().convert(resultList);
                        writeOutput(textOutput, context);
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: primaryColor
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: getPercentFromScreen("horizontal", .6, context)),
                        child: Text(
                          "Export ca CSV",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      )
                    )
                  )
                ],
              )
            )
          )
        );
        break;
      }
      case "filters": {
        focusedRow = Container();
        print("selected filters");
        break;
      }
    }
    // call setState after the logic is done so that it updates faster
    setState(() {
      if(newFocus == lastFocus){
        focusedRow = Container();
        focusedToolBar = false;
        lastFocus = "";
      }else{
        focusedToolBar = true;
        lastFocus = newFocus;
      }
    });
  }

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    // this is a list of all the keys so that i can index it
    // because ListView.builder returns me an index
    // and i just have to use that index in the keys list
    resultKeys = widget.result.keys.toList();
    return SizedBox(
      // to avoid unbounded width
      // is 96 percent of screen because navigation bar is 3 percent of screen
      width: getPercentFromScreen("horizontal", 96, context),
      height: getPercentFromScreen("vertical", 100, context) ,
      // REMEBER TO USE LISTVIEW.BUILDER BECAUSE IT'S MUCH BETTER THAN WHAT YOU DID BEFORE DUMBASS💀💀
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(5),bottomRight: Radius.circular(5),),
              color: secondaryColor
            ),
            height: focusedToolBar ? getPercentFromScreen('vertical', 14, context) : getPercentFromScreen('vertical', 7, context),
            clipBehavior: Clip.hardEdge,
            child: Column(
              children: [
                SizedBox(
                  height: getPercentFromScreen("vertical", 7, context),
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: getPercentFromScreen("horizontal", 2, context)),
                        child: TextButton(
                          onPressed: (){
                            updateFocus("options");
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: primaryColor
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: getPercentFromScreen("horizontal", .6, context)),
                            child: Text(
                              "Optiuni",
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          )
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: getPercentFromScreen("horizontal", 2, context)),
                        child: TextButton(
                          onPressed: (){
                            setState(() {
                              updateFocus("filters");
                            });
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: primaryColor
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: getPercentFromScreen("horizontal", .6, context)),
                            child: Text(
                              "Filtre",
                              style: TextStyle(
                                color: Colors.white
                              ),
                            ),
                          )
                        )
                      ),
                    ],
                  )
                ),
                focusedRow
              ]
            ),
          ),
          Positioned(
            top: focusedToolBar ? getPercentFromScreen('vertical', 14.5, context) : getPercentFromScreen('vertical', 7.5, context),
            child: Scrollbar(
              thumbVisibility: true,
              trackVisibility: true,
              controller: _scrollController,
              child: SizedBox(
                height: focusedToolBar ? getPercentFromScreen("vertical", 86, context) : getPercentFromScreen("vertical", 93, context),
                width: getPercentFromScreen("horizontal", 96, context),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: resultKeys.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: getPercentFromScreen("vertical", 1, context),
                        left: getPercentFromScreen("horizontal", 1, context),
                        right: getPercentFromScreen("horizontal", 1, context),
                      ),
                      // child: Stack(
                        // children: [
                        //   Text(
                        //     index.toString() + ".",
                        //     style: TextStyle(
                        //       color: Colors.black,
                        //       fontWeight: FontWeight.w600,
                        //       decoration: TextDecoration.none,
                        //       fontSize: getPercentFromScreen("horizontal", 1, context)
                        //     )
                        // ),
                          // Positioned(
                          //   left: getPercentFromScreen("horizontal", 2, context),
                            child:  _Product(
                                key: GlobalKey<__ProductState>(),
                                beGray: (index % 2 == 0),
                                sku: resultKeys[index],
                                // i think i wrote specs in the API
                                // if not i'l probably have the postman env saved
                                productName: widget.result[resultKeys[index]]["name"],
                                nextUpStock: widget.result[resultKeys[index]]["nextUpStock"],
                                stockAfterPackaging: widget.result[resultKeys[index]]["stockAfterPackaging"],
                                quantityOrdered: widget.result[resultKeys[index]]["productsOrdered"],
                                provider: widget.result[resultKeys[index]]["productProvider"],
                                orderedProvider: (widget.result[resultKeys[index]]["orderedNovaPan"] == null) ? 0 : int.parse(widget.result[resultKeys[index]]["orderedNovaPan"]),
                                // the global manager manages the communication between products
                                // so that if the user clicks on another product the already selected one
                                // deselects automatically
                                globalManager: globalManager,
                              )
                          // )
                        // ]
                      // )
                    );
                  },
                )
              )
            )
          )
        ]
      )
    );
  }
}

class _Product extends StatefulWidget {
  _Product({super.key, required this.orderedProvider, required this.provider, required this.sku, required this.beGray, required this.productName, required this.quantityOrdered, required this.nextUpStock, required this.stockAfterPackaging, required this.globalManager});
  String sku;
  String productName;
  String provider;
  int quantityOrdered;
  int nextUpStock;
  int stockAfterPackaging;
  int orderedProvider;
  Function globalManager;
  bool beGray;
  @override
  State<_Product> createState() => __ProductState();
}

class __ProductState extends State<_Product> {
  bool isSelected = false;
  void show(){
    setState(() {
      isSelected = true;
    });
  }
  void hide(){
    setState(() {
      isSelected = false;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(isSelected){
      return GestureDetector(
        onTap: (){
          // pass the action then the key so that the global manager knows who 
          // sent the action
          String action = widget.globalManager(_PRODUCT_CLICKED, super.widget.key);
          if(action == _SHOW_PRODUCT){
            show();
          }else if(action == _HIDE_PRODUCT){
            hide();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black,
              width: getPercentFromScreen("horizontal", 1.8, context) / getPercentFromScreen("vertical", 1.5, context)
            )
          ),
          height: getPercentFromScreen("vertical", 13, context),
          child: Stack(
            children: [
              Positioned(
                top: getPercentFromScreen("vertical", 5, context), 
                left: getPercentFromScreen("horizontal", 4.9, context),
                child: Text(
                  "Cod de produs: " + widget.sku,
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: getPercentFromScreen("horizontal", 1, context),
                    decoration: TextDecoration.none
                  )
                )
              ),
              Positioned(
                top: getPercentFromScreen("vertical", 7.3, context), 
                left: getPercentFromScreen("horizontal", 4.9, context),
                child: Text(
                  "Stock NextUp: " + widget.nextUpStock.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: getPercentFromScreen("horizontal", 1, context),
                    decoration: TextDecoration.none
                  )
                )
              ),
              Positioned(
                top: getPercentFromScreen("vertical", 9.5, context), 
                left: getPercentFromScreen("horizontal", 4.9, context),
                child: Text(
                  "Totalul de produse comandate: " + widget.quantityOrdered.toString(),
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: getPercentFromScreen("horizontal", 1, context),
                    decoration: TextDecoration.none
                  )
                )
              ),
              SizedBox(
                height: getPercentFromScreen("vertical", 3.7, context),
                child: Row(
                  children: [
                    Padding(
                      //padding: EdgeInsets.symmetric(horizontal: getPercentFromScreen("horizontal", 1, context)),\
                      padding: EdgeInsets.only(left: getPercentFromScreen("horizontal", .5, context)),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            // color: (widget.stockAfterPackaging <= 0) ? Colors.red : Colors.green,
                            color: Colors.transparent,
                            width: getPercentFromScreen("horizontal", 2.8, context) / getPercentFromScreen("vertical", 2, context)
                          )
                        ),
                        //width: getPercentFromScreen("horizontal", 1.4, context),
                        width: getPercentFromScreen("horizontal", 4.5, context),
                        // height: getPercentFromScreen("horizontal", 1.4, context),
                        child: Center(
                          child: SelectableText(
                            (widget.stockAfterPackaging.toString().contains("-")) ? widget.stockAfterPackaging.toString() + " " : widget.stockAfterPackaging.toString(),
                            style: TextStyle(
                              color: (widget.stockAfterPackaging <= 0) ? Colors.red : Colors.green,
                              // // if one char make it big
                              // // if two char's make it medium
                              // // if three char's make it small
                              // // basically autosizing text
                              // // but yk worse
                              // // TODO: ADD AUTO-SIZE TEXT
                              // fontSize: (widget.stockAfterPackaging.toString().length >= 3) ? 
                              //   getPercentFromScreen("horizontal", .55, context) : 
                              //   (widget.stockAfterPackaging.toString().length >= 2) ? 
                              //       getPercentFromScreen("horizontal", .65, context) : 
                              //       getPercentFromScreen("horizontal", .8, context),
                              fontSize: getPercentFromScreen("horizontal", 1, context),
                              decoration: TextDecoration.none
                            ),
                          )
                        )
                      )
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: getPercentFromScreen("horizontal", 15, context)),
                      child: Stack(
                        // this is because the stack is as big as the title
                        // so if the title is too small then the icon doesn't show
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          SelectableText(
                            widget.productName,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: getPercentFromScreen("vertical", 1.7, context),
                              decoration: TextDecoration.none
                            ),
                          ),
                          Positioned(
                            left: getPercentFromScreen("horizontal", 50, context),
                            child: SelectableText(
                              widget.sku,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: getPercentFromScreen("vertical", 1.7, context),
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                          Positioned(
                            left: getPercentFromScreen("horizontal", 60, context),
                            child: SelectableText(
                              widget.provider,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                                fontSize: getPercentFromScreen("vertical", 1.7, context),
                                decoration: TextDecoration.none
                              )
                            )
                          ),
                        ]
                      )
                    ),
                  ]
                )
              )
            ]
          )
        )
      );
    }else{
      return GestureDetector(
        onTap: (){
          // pass the action then the key so that the global manager knows who 
          // sent the action
          String action = widget.globalManager(_PRODUCT_CLICKED, super.widget.key);
          if(action == _SHOW_PRODUCT){
            show();
          }else if(action == _HIDE_PRODUCT){
            hide();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.black,
              width: getPercentFromScreen("horizontal", 1.8, context) / getPercentFromScreen("vertical", 1.5, context)
            )
          ),
          height: getPercentFromScreen("vertical", 3.7, context),
          child: Row(
            children: [
              Padding(
                //padding: EdgeInsets.symmetric(horizontal: getPercentFromScreen("horizontal", 1, context)),\
                padding: EdgeInsets.only(left: getPercentFromScreen("horizontal", .5, context)),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      // color: (widget.stockAfterPackaging <= 0) ? Colors.red : Colors.green,
                      color: Colors.transparent,
                      width: getPercentFromScreen("horizontal", 2.8, context) / getPercentFromScreen("vertical", 2, context)
                    )
                  ),
                  //width: getPercentFromScreen("horizontal", 1.4, context),
                  width: getPercentFromScreen("horizontal", 4.5, context),
                  // height: getPercentFromScreen("horizontal", 1.4, context),
                  child: Center(
                    child: SelectableText(
                      (widget.stockAfterPackaging.toString().contains("-")) ? widget.stockAfterPackaging.toString() + " " : widget.stockAfterPackaging.toString(),
                      style: TextStyle(
                        color: (widget.stockAfterPackaging <= 0) ? Colors.red : Colors.green,
                        // // if one char make it big
                        // // if two char's make it medium
                        // // if three char's make it small
                        // // basically autosizing text
                        // // but yk worse
                        // // TODO: ADD AUTO-SIZE TEXT
                        // fontSize: (widget.stockAfterPackaging.toString().length >= 3) ? 
                        //   getPercentFromScreen("horizontal", .55, context) : 
                        //   (widget.stockAfterPackaging.toString().length >= 2) ? 
                        //       getPercentFromScreen("horizontal", .65, context) : 
                        //       getPercentFromScreen("horizontal", .8, context),
                        fontSize: getPercentFromScreen("horizontal", 1, context),
                        decoration: TextDecoration.none
                      ),
                    )
                  )
                )
              ),
              Padding(
                padding: EdgeInsets.only(right: getPercentFromScreen("horizontal", 15, context)),
                child: Stack(
                  // this is because the stack is as big as the title
                  // so if the title is too small then the icon doesn't show
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    SelectableText(
                      widget.productName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontSize: getPercentFromScreen("vertical", 1.7, context),
                        decoration: TextDecoration.none
                      ),
                    ),
                    Positioned(
                      left: getPercentFromScreen("horizontal", 50, context),
                      child: SelectableText(
                        widget.sku,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: getPercentFromScreen("vertical", 1.7, context),
                          decoration: TextDecoration.none
                        )
                      )
                    ),
                    Positioned(
                      left: getPercentFromScreen("horizontal", 60, context),
                      child: SelectableText(
                        widget.provider,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                          fontSize: getPercentFromScreen("vertical", 1.7, context),
                          decoration: TextDecoration.none
                        )
                      )
                    ),
                  ]
                )
              ),
            ]
          )
        )
      );
    }

  }
}