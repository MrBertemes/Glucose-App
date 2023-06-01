// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, prefer_const_constructors

import 'package:async_button_builder/async_button_builder.dart';
import 'package:flutter/material.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/styles/customclippers.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage();

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

enum AccountType { normalUser, doctor }

class _SignUpPageState extends State<SignUpPage> {
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _crm;

  AccountType? _userType = AccountType.normalUser;
  bool _normalUser = true;

  bool _hidePassword = true;
  bool _emailAlreadyInUse = false;

  @override
  void initState() {
    _name = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _crm = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _crm.dispose();
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
      backgroundColor: CustomColors.notwhite,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                            CustomColors.blueGreen.withOpacity(0.40),
                            CustomColors.lightBlue.withOpacity(0.20),
                            CustomColors.greenBlue.withOpacity(0.20),
                            CustomColors.lightGreen.withOpacity(0.20),
                          ],
                        ),
                      ),
                      child: Center(
                        child: Image(
                          image: AssetImage('assets/images/logoblue.png'),
                          width: MediaQuery.of(context).size.width * 0.43,
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
                    padding: EdgeInsets.only(top: 10.0, bottom: 40.0),
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /*
                          // OPCOES USUARIO COMUM E MEDICO
                          RadioListTile<AccountType>(
                            title: Text(
                              'Usuário Comum',
                              style: TextStyle(
                                  color: _normalUser
                                      ? CustomColors.lightBlue
                                      : Colors.blueGrey),
                            ),
                            autofocus: true,
                            activeColor: CustomColors.lightBlue,
                            value: AccountType.normalUser,
                            groupValue: _userType,
                            onChanged: (AccountType? value) {
                              setState(() {
                                _userType = value;
                                _normalUser = true;
                              });
                            },
                          ),
                          RadioListTile<AccountType>(
                            title: Text(
                              'Médico',
                              style: TextStyle(
                                  color: _normalUser
                                      ? Colors.blueGrey
                                      : CustomColors.lightBlue),
                            ),
                            activeColor: CustomColors.lightBlue,
                            value: AccountType.doctor,
                            groupValue: _userType,
                            onChanged: (AccountType? value) {
                              setState(() {
                                _userType = value;
                                _normalUser = false;
                              });
                            },
                          ),
*/
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
                                style: TextStyle(color: CustomColors.blueGreen),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: CustomColors.blueGreen,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: CustomColors.blueGreen,
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

                          //CAMPO CRM
                          Container(
                            child: !_normalUser
                                ? TextFormField(
                                    controller: _crm,
                                    decoration: InputDecoration(
                                      label: Text(
                                        'CRM',
                                        style: TextStyle(
                                            color: CustomColors.blueGreenlight),
                                      ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 2,
                                          color: CustomColors.blueGreenlight,
                                        ),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          width: 3,
                                          color: CustomColors.blueGreenlight,
                                        ),
                                      ),
                                    ),
                                    onChanged: (text) {
                                      _isFieldFilled['crm'] = text.isNotEmpty;
                                    },
                                    validator: (text) {
                                      if (text == null || text.isEmpty) {
                                        return '*Campo obrigatório';
                                      }
                                      //validar CRM aqui
                                      if (text.length != 6) {
                                        return '*O CRM deve conter 6 digitos';
                                      }
                                      return null;
                                    },
                                    // style: TextStyle(color: CustomColors.lightBlue),
                                    cursorColor: CustomColors.blueGreenlight,
                                    keyboardType: TextInputType.number,
                                    autocorrect: false,
                                  )
                                : Padding(padding: EdgeInsets.all(0)),
                          ),
                          Container(
                              child: !_normalUser
                                  ? Padding(padding: EdgeInsets.all(8.0))
                                  : Padding(padding: EdgeInsets.all(0))),
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
                          Padding(padding: EdgeInsets.all(8.0)),
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
                                  AsyncButtonBuilder(
                                    child: Text(
                                      'Concluir Cadastro',
                                      style: TextStyle(
                                        color: CustomColors.notwhite,
                                        // a cor tá errada, aparecendo cinza por algum motivo (por estar desabilitado será?)
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                    loadingWidget: CircularProgressIndicator(
                                      color: CustomColors.notwhite,
                                      strokeWidth: 3.0,
                                    ),
                                    disabled: !isValid,
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
                                                ///////
                                                if (await API.instance.login(
                                                    _email.text
                                                        .trim()
                                                        .toLowerCase(),
                                                    _password.text.trim())) {
                                                  await Navigator
                                                      .popAndPushNamed(
                                                          context, '/welcome');
                                                }
                                                ///////
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
                                                // só pro botão dar a mensagem certa, não sabia outra forma de fazer
                                                throw 'Erro no signup';
                                              }
                                              if (_normalUser) {
                                                _crm.clear();
                                              } else {
                                                _crm.text.trim();
                                              }
                                            } else {
                                              // só pro botão dar a mensagem certa, não sabia outra forma de fazer
                                              throw 'Erro no signup';
                                            }
                                          },
                                    builder: (context, child, callback, _) {
                                      return TextButton(
                                        style: TextButton.styleFrom(
                                          primary: CustomColors.notwhite,
                                          backgroundColor: isValid
                                              ? CustomColors.lightGreen
                                              : Colors.grey,
                                          padding: EdgeInsets.all(10.0),
                                          minimumSize: Size.fromHeight(60),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                        ),
                                        onPressed: callback,
                                        child: child,
                                      );
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
                                        Color.fromARGB(0, 255, 251, 251),
                                        CustomColors.lightGreen,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                  'OU',
                                  style: TextStyle(
                                    color: CustomColors.lightGreen,
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
                                        CustomColors.lightGreen,
                                        Color.fromARGB(0, 255, 250, 250),
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
                              backgroundColor: CustomColors.notwhite,
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
