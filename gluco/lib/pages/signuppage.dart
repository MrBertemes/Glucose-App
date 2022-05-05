import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'loginpage.dart';

class SignUpPage extends StatefulWidget {
  final AppBar appBar;

  const SignUpPage({Key? key, required this.appBar}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  User? _user;

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
      appBar: widget.appBar,
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
                await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email, password: password);

                // loga depois de criar conta
                await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: email, password: password);
                _user = FirebaseAuth.instance.currentUser;
                await _user?.sendEmailVerification();

                Navigator.pop(context);
              },
              child: const Text("Criar conta", style: TextStyle(fontSize: 20)),
              style: TextButton.styleFrom(
                  primary: Colors.black,
                  backgroundColor: Color.fromARGB(255, 236, 39, 13),
                  padding: const EdgeInsets.all(30)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return LoginPage(appBar: widget.appBar);
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
