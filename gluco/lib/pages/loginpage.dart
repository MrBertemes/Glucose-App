// ignore_for_file: must_be_immutable, prefer_const_constructors, use_key_in_widget_constructors

import 'package:async_button_builder/async_button_builder.dart';
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
  bool _nonexistentEmail = false;
  bool _invalidPassword = false;
  bool _invalidEmail = false;

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
      backgroundColor: CustomColors.notwhite,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior : ScrollViewKeyboardDismissBehavior.onDrag,
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
                      height: MediaQuery.of(context).size.height * 0.43,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            CustomColors.blueGreen.withOpacity(0.40),
                            CustomColors.lightBlue.withOpacity(0.20),
                            CustomColors.greenBlue.withOpacity(0.20),
                            CustomColors.lightGreen.withOpacity(0.20),
                          ],
                        ),
                      ),
                      child: Center(
                        heightFactor: 1.7,
                        child: Image(
                          image: AssetImage('assets/images/logoblue.png'),
                          width: MediaQuery.of(context).size.width * 0.5,
                        ),
                        // child: Text(
                        //   'EGLUCO', // placeholder
                        //   textAlign: TextAlign.center,
                        //   style: TextStyle(
                        //     color: Colors.black,
                        //     fontSize: 40,
                        //     inherit: false,
                        //   ),
                        // ),
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
                              style: TextStyle(color: CustomColors.lightGreen),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 2,
                                color: CustomColors.lightGreen,
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                width: 3,
                                color: CustomColors.lightGreen,
                              ),
                            ),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (text) {
                            if (_nonexistentEmail) {
                              return '*Não há conta nesse e-mail';
                            }
                            if (_invalidEmail) {
                              return '*E-mail inválido';
                            }
                            return null;
                          },
                          cursorColor: CustomColors.lightGreen,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        Padding(padding: EdgeInsets.all(8.0)),
                        TextFormField(
                          controller: _password,
                          obscureText: _hidePassword,
                          decoration: InputDecoration(
                            label: Text(
                              'Senha',
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
                                color: CustomColors.greenBlue),
                          ),
                          autovalidateMode: AutovalidateMode.always,
                          validator: (text) {
                            if (_invalidPassword) {
                              return '*Senha inválida';
                            }
                            return null;
                          },
                          cursorColor: CustomColors.greenBlue,
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
                        AsyncButtonBuilder(
                          child: Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          loadingWidget: CircularProgressIndicator(
                            color: CustomColors.notwhite,
                            strokeWidth: 3.0,
                          ),
                          onPressed: () async {
                            if (await API.instance.login(
                              _email.text.trim().toLowerCase(),
                              _password.text.trim(),
                            )) {
                              switch (API.instance.responseMessage) {
                                case APIResponseMessages.success:
                                  await HistoryVO.fetchHistory();
                                  await Navigator.popAndPushNamed(
                                      context, '/home');
                                  break;
                                case APIResponseMessages.emptyProfile:
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
                                      _nonexistentEmail = true;
                                      _invalidPassword = false;
                                      _invalidEmail = false;
                                    },
                                  );
                                  break;
                                case APIResponseMessages.wrongPassword:
                                  setState(
                                    () {
                                      _nonexistentEmail = false;
                                      _invalidPassword = true;
                                      _invalidEmail = false;
                                    },
                                  );
                                  break;
                                case APIResponseMessages.invalidFields:
                                  setState(
                                    () {
                                      _nonexistentEmail = false;
                                      _invalidPassword = false;
                                      _invalidEmail = true;
                                    },
                                  );
                                  break;
                                case APIResponseMessages.noConnection:
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Sem conexão'),
                                        content: Text(
                                            'Verifique sua conexão à Internet'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('OK'),
                                          )
                                        ],
                                      );
                                    },
                                  );
                                  break;
                              }
                              // só pro botão dar a mensagem certa, não sabia outra forma de fazer
                              throw 'Erro no login';
                            }
                          },
                          builder: (context, child, callback, _) {
                            return TextButton(
                              style: TextButton.styleFrom(
                                primary: CustomColors.notwhite,
                                backgroundColor: CustomColors.lightBlue,
                                padding: EdgeInsets.all(10.0),
                                minimumSize:
                                    Size(viewportConstraints.maxWidth, 60),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: callback,
                              child: child,
                            );
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
                                      Color.fromARGB(0, 252, 247, 247),
                                      CustomColors.blueGreen,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(15),
                              child: Text(
                                "OU",
                                style: TextStyle(
                                  color: CustomColors.blueGreen,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      CustomColors.blueGreen,
                                      Color.fromARGB(0, 251, 249, 249),
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
                            primary: CustomColors.blueGreen,
                            backgroundColor: CustomColors.notwhite,
                            padding: EdgeInsets.all(10.0),
                            minimumSize: Size(viewportConstraints.maxWidth, 60),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: CustomColors.blueGreen, width: 2.0),
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
