import 'dart:convert';

import 'package:http/http.dart' as http;
export 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
String _authToken = "";
Future<String> get localPath async {
  return Directory.current.path;
}
Future<void> createFile(String text, Directory dir) async {
//creates text_file in the provided path.
  final file = File(dir.path);
  await file.writeAsString(text);
}

Future<String?> readFile(Directory dir) async {
  try {
    final file = File(dir.path);
    return (await file.readAsString());
  } catch (e) {
    print(e);
    return null;
  }
}

String _baseUrl = "http://stylr.go.ro:42069/api/";
Future loadConfigs() async {
  try{
    final String appDir = await localPath;
    final Directory configFile = Directory(appDir + "\\configs.json");
    if(await File(configFile.path).exists() == true){
      String? rawData = await readFile(configFile);
      if(rawData != null){
        Map<String, dynamic> procData = await jsonDecode(rawData);
        createFile(rawData, Directory("$appDir\\RESULT.txt"));
        _baseUrl = procData["api"]["ip"] + ":" + procData["api"]["port"] + "/api/";
        _authToken = procData["api"]["token"];
      }else{
        createFile("raw data was NULL", Directory("$appDir\\ERROR.txt"));
      }
      return false;
    }else{
      createFile(
        jsonEncode({  
          "api": {
            "ip": "22.25.28.6",
            "port": "42069",
            "token": "scrie token-ul de securitate pentru API aici"
          }
        }),
        configFile
      );
      return appDir;
    }
  }catch(err){
    final Directory appDir = await getApplicationSupportDirectory();
    createFile(err.toString(), Directory(appDir.path + "\\ERROR2.txt"));
    return false;
  }
}
Future getRequiredProducts({String? novaPanFile}){
  print((novaPanFile == null) ? "" : Uri.encodeComponent(novaPanFile));
  return http.get(
    Uri.parse(_baseUrl.toString() + "products/getRequired"),
    headers: {
      "token": _authToken,
      "novaPanPath": (novaPanFile == null) ? "" : Uri.encodeComponent(novaPanFile),
      //"novaPanPath": "",
    },
    
  );
}
Future getProccessStatus(String proccessID){
  return http.get(
    Uri.parse(_baseUrl + "proccess/getStatus"),
    headers: {
      "token": _authToken,
      "proccessID": proccessID,
    },
  );
}
void getProccessStatusWithCallback(String proccessID, Function callback) async {
  var result = await http.get(
    Uri.parse(_baseUrl + "proccess/getStatus"),
    headers: {
      "token": _authToken,
      "proccessID": proccessID,
    },
  );
  if(result.statusCode == 200){
    callback(result.body, null);
  }else{
    callback(result.body, result.statusCode.toString());
  }
}

Future getAllApiSettings(){
  return http.get(
    Uri.parse(_baseUrl + "settings"),
    headers: {
      "token": _authToken
    },
  );
}
void setApiSetting(String field, String setting, String value) async{
  http.post(
    Uri.parse(_baseUrl + "settings/setOne"),
    headers: {
      "token": _authToken,
      "field": field,
      "setting": setting,
      "value": value,
    },
  );
}