// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/collected.dart';
import '../styles/appbartest.dart';
import 'homepage.dart';
import 'signuppage.dart';

class LoginPage extends StatefulWidget {
  final AppBar appBar;
  final Collected dataCollected;
  final FlutterBlue bluetooth;
  const LoginPage(
      {Key? key,
      required this.appBar,
      required this.dataCollected,
      required this.bluetooth})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarTest(title: "E-Gluco Acesso"),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
                final email = _email.text;
                final password = _password.text;
                // await FirebaseAuth.instance.signInWithEmailAndPassword(
                //     email: email, password: password);
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return HomePage(
                      appBar: widget.appBar,
                      dataCollected: widget.dataCollected,
                      bluetooth: widget.bluetooth);
                }));
              },
              child: const Text("Acessar", style: TextStyle(fontSize: 20)),
              style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Colors.green[600],
                  padding: const EdgeInsets.all(30)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return SignUpPage(
                    appBar: widget.appBar,
                    dataCollected: widget.dataCollected,
                    bluetooth: widget.bluetooth,
                  );
                }));
              },
              child: const Text("Não possui conta?"),
            ),
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
