// ignore_for_file: must_be_immutable, prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/styles/customclippers.dart';
import 'package:gluco/views/historyvo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  bool _hidePassword = true;
  bool _invalidEmail = false;
  bool _invalidPassword = false;

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
                    clipper: CubicClipper(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.4,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            CustomColors.lightBlue,
                            CustomColors.lightGreen,
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
                        TextFormField(
                          controller: _email,
                          decoration: InputDecoration(
                            label: Text(
                              'E-mail',
                              style: TextStyle(color: CustomColors.greenBlue),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: CustomColors.greenBlue,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: CustomColors.greenBlue,
                              ),
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (text) {
                            if (_invalidEmail) {
                              return '*Não há conta nesse e-mail';
                            }
                            return null;
                          },
                          cursorColor: CustomColors.greenBlue,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Padding(padding: EdgeInsets.all(8.0)),
                        TextFormField(
                          controller: _password,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            label: Text(
                              'Senha',
                              style: TextStyle(color: CustomColors.lightBlue),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: CustomColors.lightBlue,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: CustomColors.lightBlue,
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
                                color: CustomColors.lightBlue),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (text) {
                            if (_invalidPassword) {
                              return '*Senha inválida';
                            }
                            return null;
                          },
                          cursorColor: CustomColors.lightBlue,
                          enableSuggestions: false,
                          autocorrect: false,
                        ),
                        /////// tirei pq não foi implementado ainda
                        // Padding(padding: EdgeInsets.all(2.0)),
                        // Align(
                        //   alignment: Alignment.centerRight,
                        //   child: TextButton(
                        //     child: Text(
                        //       'Esqueci a senha',
                        //       style: TextStyle(color: CustomColors.lightBlue),
                        //     ),
                        //     onPressed: () {},
                        //   ),
                        // ),
                        // Padding(padding: EdgeInsets.all(10.0)),
                        Padding(padding: EdgeInsets.all(30.0)),
                        TextButton(
                          child: const Text('Entrar'),
                          style: TextButton.styleFrom(
                            textStyle: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            primary: Colors.white,
                            backgroundColor: CustomColors.lightBlue,
                            padding: EdgeInsets.all(10.0),
                            minimumSize: Size(viewportConstraints.maxWidth, 60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () async {
                            if (await API.instance.login(
                              _email.text.trim().toLowerCase(),
                              _password.text.trim(),
                            )) {
                              switch (API.instance.responseMessage) {
                                case 'Success':
                                  await HistoryVO.fetchHistory();
                                  await Navigator.popAndPushNamed(
                                      context, '/home');
                                  break;
                                case 'Empty profile':
                                  await Navigator.popAndPushNamed(
                                      context, '/welcome');
                                  break;
                              }
                            } else {
                              _password.clear();
                              switch (API.instance.responseMessage) {
                                case APIResponseMessages.notRegistered:
                                  setState(
                                    () {
                                      _invalidEmail = true;
                                      _invalidPassword = false;
                                    },
                                  );
                                  break;
                                case APIResponseMessages.wrongPassword:
                                  setState(
                                    () {
                                      _invalidEmail = false;
                                      _invalidPassword = true;
                                    },
                                  );
                                  break;
                              }
                            }
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
                                      CustomColors.lightBlue,
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
                                  color: CustomColors.lightBlue,
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
                                      CustomColors.lightBlue,
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
                            primary: CustomColors.lightBlue,
                            backgroundColor: Colors.white,
                            padding: EdgeInsets.all(10.0),
                            minimumSize: Size(viewportConstraints.maxWidth, 60),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: CustomColors.lightBlue, width: 2.0),
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
