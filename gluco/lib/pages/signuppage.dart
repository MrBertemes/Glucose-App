// ignore_for_file: must_be_immutable, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import '../styles/defaultappbar.dart';

@Deprecated(
    "Por enquanto não há pagina de SignUp, tudo é feito pela página de Login")
class SignUpPage extends StatefulWidget {
  const SignUpPage();

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
      appBar: defaultAppBar(title: "E-Gluco Cadastro"),
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
            ),
            TextField(
              controller: _email,
              decoration: const InputDecoration(hintText: "Insira seu email"),
              style: Theme.of(context).textTheme.headline6,
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(hintText: "Insira sua senha"),
              style: Theme.of(context).textTheme.headline6,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
            ),
            TextButton(
              child: const Text("Criar conta", style: TextStyle(fontSize: 20)),
              style: TextButton.styleFrom(
                primary: Colors.black,
                backgroundColor: const Color.fromARGB(255, 236, 39, 13),
                padding: const EdgeInsets.all(30),
              ),
              onPressed: () async {
                // final name = _name.text;
                // final email = _email.text;
                // final password = _password.text;
                Navigator.popAndPushNamed(context, '/home');
              },
            ),
            TextButton(
              child: const Text("Já possui conta?"),
              onPressed: () async {
                Navigator.popAndPushNamed(context, '/login');
              },
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
