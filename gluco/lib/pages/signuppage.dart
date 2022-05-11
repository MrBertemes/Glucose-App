// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/collected.dart';
import '../styles/appbartest.dart';
import 'homepage.dart';
import 'loginpage.dart';

class SignUpPage extends StatefulWidget {
  final AppBar appBar;
  final Collected dataCollected;
  final FlutterBlue bluetooth;
  const SignUpPage(
      {Key? key,
      required this.appBar,
      required this.dataCollected,
      required this.bluetooth})
      : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _name = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTest(title: "E-Gluco Cadastro"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _name,
              decoration: const InputDecoration(hintText: "Insira seu nome"),
              style: Theme.of(context).textTheme.headline6,
              keyboardType: TextInputType.name,
              autocorrect: false,
              // textAlign: TextAlign.center,
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(hintText: "Insira seu email"),
              style: Theme.of(context).textTheme.headline6,
              keyboardType: TextInputType.emailAddress,
              // textAlign: TextAlign.center,
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(hintText: "Insira sua senha"),
              style: Theme.of(context).textTheme.headline6,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              // textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () async {
                final name = _name.text;
                final email = _email.text;
                final password = _password.text;

                // loga depois de criar conta

                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return HomePage(
                      appBar: widget.appBar,
                      dataCollected: widget.dataCollected,
                      bluetooth: widget.bluetooth);
                }));
              },
              child: const Text("Criar conta", style: TextStyle(fontSize: 20)),
              style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: const Color.fromARGB(255, 236, 39, 13),
                  padding: const EdgeInsets.all(30)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginPage(
                    appBar: widget.appBar,
                    dataCollected: widget.dataCollected,
                    bluetooth: widget.bluetooth,
                  );
                }));
              },
              child: const Text("Já possui conta?"),
            )
          ]
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.fromLTRB(50, 10, 50, 10),
                  child: e,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
