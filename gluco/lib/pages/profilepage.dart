// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import '../styles/appbartest.dart';

class ProfilePage extends StatefulWidget {
  final AppBar appBarProfile = appBarTest(title: "Perfil");
  ProfilePage();

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget.appBarProfile,
        body: Column(children: [
          ListTile(
            title: Text("Idade"),
            onTap: () {},
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: Text("Peso"),
            onTap: () {},
            trailing: Icon(Icons.arrow_forward_ios),
          ),
          ListTile(
            title: Text("Altura"),
            onTap: () {},
            trailing: Icon(Icons.arrow_forward_ios),
          )
        ]));
  }
}
