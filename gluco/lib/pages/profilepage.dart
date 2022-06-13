// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/services/authapi.dart';
import 'package:gluco/styles/colors.dart';
import 'package:gluco/styles/defaultappbar.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    User user = AuthAPI.currentUser;
    Profile? userProfile = user.profile;
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
              title: Text(
                  "Nome: ${userProfile != null ? userProfile.name : 'erro'}"),
              onTap: () {},
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              title:
                  Text("Email: ${user.email.isNotEmpty ? user.email : 'erro'}"),
              onTap: () {},
              trailing: Icon(Icons.arrow_forward_ios),
            ),
            ListTile(
              title: Text(
                  "Data Nascimento: ${userProfile != null ? userProfile.birthdate : 'erro'}"),
              onTap: () {},
              trailing: Icon(Icons.arrow_forward_ios),
            ),
          ],
        ),
      ),
    );
  }
}
