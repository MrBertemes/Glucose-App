// ignore_for_file: must_be_immutable, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:gluco/styles/colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool hidePassword = true;

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
    // Problema com scrollable, corta quando abre o teclado
    return Stack(
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: fundo,
        ),
        Positioned(
          top: -MediaQuery.of(context).size.width * 0.4,
          left: -MediaQuery.of(context).size.width * 0.1,
          child: ClipOval(
            child: Container(
              width: MediaQuery.of(context).size.width * 1.2,
              height: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [
                    azulClaro, // são essas cores ou as primas?
                    verdeClaro,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.1,
          left: 0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: const Text(
            // placeholder
            "EGluco",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              inherit: false,
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          left: MediaQuery.of(context).size.width * 0.05,
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Scaffold(
            backgroundColor: Color.fromARGB(0, 0, 0, 0),
            body: Column(
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                  child: TextField(
                    controller: _email,
                    decoration: InputDecoration(
                      hintText: "E-mail",
                      hintStyle: TextStyle(
                        color: verdeAzulado,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: verdeAzulado,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: verdeAzulado,
                        ),
                      ),
                    ),
                    cursorColor: verdeAzulado,
                    keyboardType: TextInputType.emailAddress,
                    style: Theme.of(context).textTheme.bodyText2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 25.0),
                  child: TextField(
                    controller: _password,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      hintText: "Senha",
                      hintStyle: TextStyle(
                        color: azulClaro,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 2,
                          color: azulClaro,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          width: 3,
                          color: azulClaro,
                        ),
                      ),
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(
                              () {
                                hidePassword = !hidePassword;
                              },
                            );
                          },
                          icon: Icon(hidePassword
                              ? Icons.visibility_off
                              : Icons.visibility),
                          color: azulClaro),
                    ),
                    cursorColor: azulClaro,
                    style: Theme.of(context).textTheme.bodyText2,
                    enableSuggestions: false,
                    autocorrect: false,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width * 0.865,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: azulClaro,
                  ),
                  child: TextButton(
                    child: const Text("Entrar", style: TextStyle(fontSize: 16)),
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                    ),
                    onPressed: () async {
                      // final email = _email.text;
                      // final password = _password.text;
                      // await FirebaseAuth.instance.signInWithEmailAndPassword(
                      //     email: email, password: password);

                      Navigator.popAndPushNamed(context, '/home');
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                azulClaro,
                                azulClaro,
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "ou",
                          style: TextStyle(
                            color: azulClaro,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                azulClaro,
                                azulClaro,
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width * 0.865,
                  decoration: BoxDecoration(
                    border: Border.all(color: azulClaro),
                    borderRadius: BorderRadius.circular(8),
                    color: fundo,
                  ),
                  child: TextButton(
                    child:
                        const Text("Cadastrar", style: TextStyle(fontSize: 16)),
                    style: TextButton.styleFrom(
                      primary: azulClaro,
                    ),
                    onPressed: () async {
                      Navigator.popAndPushNamed(context, '/home');
                    },
                    // onPressed: () async {
                    //   Navigator.popAndPushNamed(context, '/signup');
                    // },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      "Esqueci a senha",
                      style: TextStyle(
                        color: azulClaro,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
