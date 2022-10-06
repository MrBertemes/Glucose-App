// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, use_key_in_widget_constructors, must_be_immutable, prefer_const_literals_to_create_immutables, sized_box_for_whitespace, prefer_final_fields, unused_element, prefer_const_constructors_in_immutables, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/views/historyvo.dart';
import 'package:url_launcher/url_launcher.dart';

class SideBar extends StatefulWidget {
  SideBar();

  @override
  State<SideBar> createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  final String _url = 'http://egluco.bio.br/';

  void _launchURL() async {
    if (!await launch(_url, forceWebView: false)) {
      throw 'Could not launch $_url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            // decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            decoration: BoxDecoration(
              color: CustomColors.blueGreen.withOpacity(0.40),
            ),
            child: Image(
              image: AssetImage('assets/images/logoblue.png'),
            ),
            // child: Text(
            //   'E-Gluco',
            //   style: Theme.of(context).textTheme.headline6,
            // ),
          ),
          /*// perfil ainda não funciona pois não tem os endpoints
          ListTile(
            leading: Icon(Icons.person),
            title: Text(
              'Meu Perfil',
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () async {
              Navigator.popAndPushNamed(context, '/profile');
            },
          ),
          */
          ListTile(
            leading: Icon(Icons.watch_outlined),
            title: Text(
              'Dispositivos',
              style: Theme.of(context).textTheme.headline6,
            ),
            onTap: () async {
              Navigator.popAndPushNamed(context, '/devices');
            },
          ),
          ListTile(
            leading: Icon(Icons.info_outline),
            title: Text(
              'Sobre nós',
              style: Theme.of(context).textTheme.headline6,
            ),
            trailing: Icon(Icons.open_in_new),
            onTap: () {
              _launchURL();
              Navigator.pop(context);
            },
          ),
          Visibility(
            child: ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                "Sair",
                style: Theme.of(context).textTheme.headline6,
              ),
              onTap: () async {
                HistoryVO.disposeHistory();
                await API.instance.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              },
            ),
            visible: true,
          ),
        ],
      ),
    );
  }
}
