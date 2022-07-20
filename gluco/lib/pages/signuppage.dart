// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/styles/customclippers.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage();

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;

  bool _hidePassword = true;
  bool _emailAlreadyInUse = false;

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
    _validFormVN.dispose();
    super.dispose();
  }

  final Map<String, bool> _isFieldFilled = {
    'name': false,
    'email': false,
    'password': false,
  };

  AutovalidateMode _validationMode = AutovalidateMode.disabled;
  final ValueNotifier<bool> _validFormVN = ValueNotifier<bool>(false);
  final _formKey = GlobalKey<FormState>();

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
                      height: MediaQuery.of(context).size.height * 0.35,
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
                    padding: EdgeInsets.only(top: 10.0, bottom: 50.0),
                    width: MediaQuery.of(context).size.width * 0.9,
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _validationMode,
                      onChanged: () async {
                        await Future.delayed(Duration(milliseconds: 1));
                        if (_validationMode == AutovalidateMode.always) {
                          _validFormVN.value =
                              _formKey.currentState?.validate() ?? false;
                        } else {
                          _validFormVN.value =
                              _isFieldFilled.values.every((element) => element);
                        }
                      },
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _name,
                            decoration: InputDecoration(
                              label: Text(
                                'Nome Completo',
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
                            ),
                            onChanged: (text) {
                              _isFieldFilled['name'] = text.isNotEmpty;
                            },
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return '*Campo obrigatório';
                              }
                              if (!RegExp(r"^[\p{Letter}'\- ]+$", unicode: true)
                                  .hasMatch(text)) {
                                return '*Insira um nome válido';
                              }
                              return null;
                            },
                            // style: TextStyle(color: CustomColors.lightBlue),
                            cursorColor: CustomColors.lightBlue,
                            keyboardType: TextInputType.name,
                            autocorrect: false,
                          ),
                          Padding(padding: EdgeInsets.all(8.0)),
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
                            onChanged: (text) {
                              _isFieldFilled['email'] = text.isNotEmpty;
                              _emailAlreadyInUse = false;
                            },
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return '*Campo obrigatório';
                              }
                              if (_emailAlreadyInUse) {
                                return '*Você já possui uma conta nesse e-mail';
                              }
                              if (!RegExp(
                                      r"^[a-zA-Z0-9\.]+@[a-zA-Z]+(\.[a-zA-Z]+)+$",
                                      unicode: true)
                                  .hasMatch(text)) {
                                return '*Insira um e-mail válido';
                              }
                              return null;
                            },
                            // style: TextStyle(color: CustomColors.greenBlue),
                            cursorColor: CustomColors.greenBlue,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Padding(padding: EdgeInsets.all(8.0)),
                          TextFormField(
                            controller: _password,
                            decoration: InputDecoration(
                              label: Text(
                                'Senha',
                                style:
                                    TextStyle(color: CustomColors.lightGreen),
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
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _hidePassword = !_hidePassword;
                                    });
                                  },
                                  icon: Icon(_hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  color: CustomColors.lightGreen),
                            ),
                            onChanged: (text) {
                              _isFieldFilled['password'] = text.isNotEmpty;
                            },
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return '*Campo obrigatório';
                              }
                              if (text.length < 6) {
                                return '*A senha deve conter no mínimo 6 digitos';
                              }
                              return null;
                            },
                            // style: TextStyle(color: CustomColors.lightGreen),
                            cursorColor: CustomColors.lightGreen,
                            obscureText: _hidePassword,
                            keyboardType: TextInputType.visiblePassword,
                            enableSuggestions: false,
                            autocorrect: false,
                          ),
                          Padding(padding: EdgeInsets.all(30.0)),
                          ValueListenableBuilder<bool>(
                            valueListenable: _validFormVN,
                            builder: (_, isValid, child) {
                              return Column(
                                children: [
                                  Visibility(
                                    visible: !isValid,
                                    child: Container(
                                      alignment: Alignment.bottomRight,
                                      padding: EdgeInsets.all(8.0),
                                      child: Text(
                                        '*Preencha todos os campos',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    child: const Text('Concluir Cadastro'),
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        // a cor tá errada, aparecendo cinza por algum motivo (por estar desabilitado será?)
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      backgroundColor: isValid
                                          ? CustomColors.lightGreen
                                          : Colors.grey,
                                      padding: EdgeInsets.all(10.0),
                                      minimumSize: Size.fromHeight(60),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: !isValid
                                        ? null
                                        : () async {
                                            _validationMode =
                                                AutovalidateMode.always;
                                            _validFormVN.value = _formKey
                                                    .currentState
                                                    ?.validate() ??
                                                false;
                                            if (_validFormVN.value) {
                                              if (await API.instance.signUp(
                                                  _name.text
                                                      .trim()
                                                      .split(RegExp(' +'))
                                                      .map((t) {
                                                    return t[0].toUpperCase() +
                                                        t
                                                            .substring(1)
                                                            .toLowerCase();
                                                  }).join(' '),
                                                  _email.text
                                                      .trim()
                                                      .toLowerCase(),
                                                  _password.text.trim())) {
                                                await Navigator.popAndPushNamed(
                                                    context, '/welcome');
                                              } else {
                                                _password.clear();
                                                switch (API
                                                    .instance.responseMessage) {
                                                  case APIResponseMessages
                                                      .alreadyRegistered:
                                                    setState(() {
                                                      _emailAlreadyInUse = true;
                                                    });
                                                    break;
                                                }
                                              }
                                            }
                                          },
                                  ),
                                ],
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
                                        Colors.transparent,
                                        CustomColors.lightGreen,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  'ou',
                                  style: TextStyle(
                                    color: CustomColors.lightGreen,
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
                                        CustomColors.lightGreen,
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            child: const Text('Eu já tenho uma conta'),
                            style: TextButton.styleFrom(
                              textStyle: TextStyle(
                                fontSize: 16.0,
                              ),
                              primary: CustomColors.lightGreen,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(10.0),
                              minimumSize:
                                  Size(viewportConstraints.maxWidth, 60),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: CustomColors.lightGreen, width: 2.0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () async {
                              await Navigator.popAndPushNamed(
                                  context, '/login');
                            },
                          ),
                        ],
                      ),
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
