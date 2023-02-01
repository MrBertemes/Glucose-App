// ignore_for_file: prefer_const_constructors_in_immutables, use_key_in_widget_constructors, prefer_const_constructors

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gluco/db/databasehelper.dart';

// classe com campo de texto para execucao sql no banco local, uso pra debug
class DBTest extends StatefulWidget {
  DBTest();

  @override
  State<DBTest> createState() => _DBTestState();
}

class _DBTestState extends State<DBTest> {
  TextEditingController controller = TextEditingController();
  List<Map<String, Object?>> query = [];
  StreamController stream = StreamController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('DB teste'),
        actions: const [
          Icon(Icons.filter_drama_sharp),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                  ),
                ),
                IconButton(
                    onPressed: () async {
                      query.clear();
                      var db = await DatabaseHelper.instance.database;
                      query.addAll(await db.rawQuery(controller.text));
                      stream.add(true);
                    },
                    icon: Icon(Icons.search))
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: stream.stream,
              builder: (context, snapshot) {
                return ListView.builder(
                  itemCount: query.length,
                  itemBuilder: (c, index) {
                    return ListTile(
                        title: Text(query[index].toString()),
                        style: ListTileStyle.list,
                        selectedColor: Colors.grey[350]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
