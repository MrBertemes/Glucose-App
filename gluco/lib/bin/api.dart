// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:http/http.dart' as http; 

Future<Map> fetch() async{
  var url = Uri.parse('https://jsonplaceholder.typicode.com/todos/1');
  var reponse  = await http.get(url);
  var json = jsonDecode(reponse.body);
  return json;
}

Future<int> postTable() async{
  int success=0;

  return success;
}