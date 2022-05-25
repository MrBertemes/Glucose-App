// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import '../styles/colors.dart';
import '../styles/defaultappbar.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(title: "Perfil"),
      body: Container(
        decoration: BoxDecoration(
          color: fundoScaf2,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
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
          ],
        ),
      ),
    );
  }
}
