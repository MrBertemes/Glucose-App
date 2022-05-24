// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_final_fields, unused_element, prefer_const_constructors_in_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gluco/pages/devicepage.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/collected.dart';
import '../pages/historypage.dart';
import '../pages/loginpage.dart';
import '../pages/profilepage.dart';

class SideBar extends StatefulWidget {
  final AppBar appBar;
  final FlutterBlue blue;
  final Collected dataCollected;
  SideBar(
      {required this.appBar, required this.dataCollected, required this.blue});

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final String _url = 'http://egluco.bio.br/';

  void _launchURL() async {
    if (!await launch(_url,forceWebView: false)) throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    // User? _user = FirebaseAuth.instance.currentUser;

    return Drawer(
      // width: MediaQuery.of(context).size.width * 0.8,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 83, 100, 232),
            ),
            child: Text(
              'E-Gluco',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          Visibility(
            child: ListTile(
              title: Text(
                // "Olá, ${_user?.displayName}",
                "Olá",
                style: Theme.of(context).textTheme.headline6,
              ),
              onTap: () {},
              enabled: false,
            ),
            // nem faz mais sentido isso aqui, ou faz?
            // visible: _user != null,
            visible: false,
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Perfil',
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return ProfilePage();
              }));
            },
          ),
          ListTile(
            // leading: Icon(Icons.grading_sharp),
            leading: Icon(Icons.calendar_month_outlined),
            title: Text(
              'Histórico',
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return HistoryPage(
                  appBar: widget.appBar,
                );
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.watch_outlined),
            title: Text(
              'Dispositivo',
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () async {
              Navigator.pop(context);
              await Navigator.push(context,
                  MaterialPageRoute(builder: (context) {
                return DevicePage(
                  appBar: widget.appBar,
                  blue: widget.blue,
                );
              }));
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              'Sobre nós',
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () {
              // Update the state of the app
              // ...
              // Then close the drawer
              _launchURL();
              Navigator.pop(context);
            },
          ),
          Visibility(
            child: ListTile(
              title: Text(
                "Sair",
                style: Theme.of(context).textTheme.headline6,
              ),
              onTap: () async {
                // FirebaseAuth.instance.signOut();
                Navigator.pop(context); // appbar
                Navigator.pop(context); // homepage
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginPage(
                    appBar: widget.appBar,
                    dataCollected: widget.dataCollected,
                    bluetooth: widget.blue,
                  );
                }));
              },
            ),
            // visible: _user != null,
            visible: false,
          ),
        ],
      ),
    );
  }
}
