// ignore_for_file: must_be_immutable, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:gluco/styles/colors.dart';
import 'package:gluco/styles/customclippers.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _hidePassword = true;

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
      backgroundColor: Colors.white,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
                minWidth: viewportConstraints.maxWidth,
              ),
              child: Column(
                children: [
                  ClipPath(
                    // clipper: BezierClipper(),
                    clipper: CubicClipper(),
                    child: Container(
                      // height: viewportConstraints.maxHeight * 0.6,
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            azulClaro,
                            verdeClaro,
                          ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'EGLUCO', // placeholder
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 40,
                            inherit: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 50.0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Column(
                      children: [
                        TextField(
                          controller: _email,
                          decoration: InputDecoration(
                            hintText: 'E-mail',
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
                          style: TextStyle(color: verdeAzulado),
                          cursorColor: verdeAzulado,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Padding(padding: EdgeInsets.all(8.0)),
                        TextField(
                          controller: _password,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            hintText: 'Senha',
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
                                      _hidePassword = !_hidePassword;
                                    },
                                  );
                                },
                                icon: Icon(_hidePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                color: azulClaro),
                          ),
                          style: TextStyle(color: azulClaro),
                          cursorColor: azulClaro,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                        Padding(padding: EdgeInsets.all(2.0)),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text(
                              'Esqueci a senha',
                              style: TextStyle(color: azulClaro),
                            ),
                            onPressed: () {},
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(10.0)),
                        TextButton(
                          child: const Text('Entrar'),
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            primary: Colors.white,
                            backgroundColor: azulClaro,
                            padding: EdgeInsets.all(10.0),
                            minimumSize: Size(viewportConstraints.maxWidth, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            // AuthAPI.login(model);
                            await Navigator.popAndPushNamed(context, '/home');
                          },
                        ),
                        Row(
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
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                "ou",
                                style: TextStyle(
                                  color: azulClaro,
                                  fontSize: 16.0,
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
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          child: const Text('Cadastrar'),
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                              fontSize: 16.0,
                            ),
                            primary: azulClaro,
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            minimumSize: Size(viewportConstraints.maxWidth, 60),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: azulClaro, width: 2.0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            await Navigator.popAndPushNamed(context, '/signup');
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
