// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/services/authapi.dart';
import 'package:gluco/styles/colors.dart';
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

  // que nome bom
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
                                style: TextStyle(color: azulClaro),
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
                            // style: TextStyle(color: azulClaro),
                            cursorColor: azulClaro,
                            keyboardType: TextInputType.name,
                            autocorrect: false,
                          ),
                          Padding(padding: EdgeInsets.all(8.0)),
                          TextFormField(
                            controller: _email,
                            decoration: InputDecoration(
                              label: Text(
                                'E-mail',
                                style: TextStyle(color: verdeAzulado),
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
                            // style: TextStyle(color: verdeAzulado),
                            cursorColor: verdeAzulado,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          Padding(padding: EdgeInsets.all(8.0)),
                          TextFormField(
                            controller: _password,
                            decoration: InputDecoration(
                              label: Text(
                                'Senha',
                                style: TextStyle(color: verdeClaro),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 2,
                                  color: verdeClaro,
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  width: 3,
                                  color: verdeClaro,
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
                                  color: verdeClaro),
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
                            // style: TextStyle(color: verdeClaro),
                            cursorColor: verdeClaro,
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
                                      backgroundColor:
                                          isValid ? verdeClaro : Colors.grey,
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
                                              if (await AuthAPI.signUp(
                                                  _name.text,
                                                  _email.text,
                                                  _password.text)) {
                                                await Navigator.popAndPushNamed(
                                                    context, '/welcome');
                                              } else {
                                                switch (AuthAPI
                                                    .getResponseMessage()) {
                                                  case 'Invalid Email':
                                                    setState(() {
                                                      _emailAlreadyInUse = true;
                                                    });
                                                    _password.clear();
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
                                        verdeClaro,
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
                                    color: verdeClaro,
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
                                        verdeClaro,
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
                              primary: verdeClaro,
                              backgroundColor: Colors.white,
                              padding: EdgeInsets.all(10.0),
                              minimumSize:
                                  Size(viewportConstraints.maxWidth, 60),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: verdeClaro, width: 2.0),
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

class FirstLoginPage extends StatefulWidget {
  const FirstLoginPage();

  @override
  State<FirstLoginPage> createState() => _FirstLoginPageState();
}

class _FirstLoginPageState extends State<FirstLoginPage> {
  late final TextEditingController _birthdate;
  late final TextEditingController _weight;
  late final TextEditingController _height;

  String? _dropdownValueSex;
  String? _dropdownValueDiabetes;

  @override
  void initState() {
    _birthdate = TextEditingController();
    _weight = TextEditingController();
    _height = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _birthdate.dispose();
    _weight.dispose();
    _height.dispose();
    _validFormVN.dispose();
    super.dispose();
  }

  final Map<String, bool> _isFieldFilled = {
    'birthdate': false,
    'weight': false,
    'height': false,
    'sex': false,
    'diabetes': false
  };

  AutovalidateMode _validationMode = AutovalidateMode.disabled;
  final ValueNotifier<bool> _validFormVN = ValueNotifier<bool>(false);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.1),
          child: Form(
            key: _formKey,
            autovalidateMode: _validationMode,
            onChanged: () async {
              ///// não é a melhor solução, mas enfim, o onchanged do form é
              /// chamado antes do onchanged dos fields, precisava que fosse o contrario
              await Future.delayed(Duration(milliseconds: 1));
              //////
              if (_validationMode == AutovalidateMode.always) {
                _validFormVN.value = _formKey.currentState?.validate() ?? false;
              } else {
                _validFormVN.value =
                    _isFieldFilled.values.every((element) => element);
              }
            },
            child: Column(
              children: [
                Container(
                  // falta o botão da câmera
                  width: MediaQuery.of(context).size.width * 0.25,
                  height: MediaQuery.of(context).size.width * 0.25,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: azulEsverdeado.withOpacity(1.0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person,
                    size: MediaQuery.of(context).size.width * 0.25,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 30.0,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: azulEsverdeado.withOpacity(1.0),
                      ),
                      children: [
                        TextSpan(
                          text: 'Olá, ${AuthAPI.currentUser.name}!\n',
                          style: TextStyle(
                            fontSize: 18.0,
                            height: 4.0,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text:
                              'Para continuar, preencha as informações pessoais de cadastro de perfil.',
                        ),
                      ],
                    ),
                  ),
                ),
                // falta colocar formatter ou datepicker??
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('Data de Nascimento',
                          style:
                              TextStyle(color: verdeAzulado.withOpacity(1.0))),
                    ),
                    TextFormField(
                      controller: _birthdate,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        hintText: 'dd/mm/aaaa',
                        filled: true,
                        fillColor: verdeAzulado,
                      ),
                      onChanged: (text) {
                        _isFieldFilled['birthdate'] = text.isNotEmpty;
                      },
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return '*Campo obrigatório';
                        }
                        if (text.length != 10 ||
                            !text.contains('/') ||
                            DateTime.tryParse(
                                    text.split('/').reversed.join('-')) ==
                                null) {
                          return '*Insira uma data válida';
                        }
                        // precisa testar também se o valor inserido faz sentido => ex. datetime.now-120<text<datetime.now
                        return null;
                      },
                      keyboardType: TextInputType.datetime,
                      autocorrect: false,
                      enableSuggestions: false,
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                            child: Text('Peso',
                                style: TextStyle(
                                    color: verdeAzulado.withOpacity(1.0))),
                          ),
                          TextFormField(
                            controller: _weight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: '70,5',
                              // suffixText: 'kg',
                              filled: true,
                              fillColor: verdeAzulado,
                            ),
                            onChanged: (text) {
                              _isFieldFilled['weight'] = text.isNotEmpty;
                            },
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return '*Campo obrigatório';
                              }
                              if (double.tryParse(text.replaceAll(',', '.')) ==
                                  null) {
                                return '*Insira um número válido';
                              }
                              // precisa testar também se o valor inserido faz sentido => ex. 30.0<text<200.0
                              return null;
                            },
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                            child: Text('Altura',
                                style: TextStyle(
                                    color: verdeAzulado.withOpacity(1.0))),
                          ),
                          TextFormField(
                            controller: _height,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none),
                              hintText: '1,67',
                              // suffixText: 'm',
                              filled: true,
                              fillColor: verdeAzulado,
                            ),
                            onChanged: (text) {
                              _isFieldFilled['height'] = text.isNotEmpty;
                            },
                            validator: (text) {
                              if (text == null || text.isEmpty) {
                                return '*Campo obrigatório';
                              }
                              if (double.tryParse(text.replaceAll(',', '.')) ==
                                  null) {
                                return '*Insira um número válido';
                              }
                              // precisa testar também se o valor inserido faz sentido => ex. 0.5<text<2.5
                              return null;
                            },
                            keyboardType:
                                TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                      child: Text('Sexo',
                          style:
                              TextStyle(color: verdeAzulado.withOpacity(1.0))),
                    ),
                    DropdownButtonFormField(
                      // hint: Text('Selecionar'),
                      value: _dropdownValueSex,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        filled: true,
                        fillColor: verdeAzulado,
                      ),
                      icon: Icon(Icons.keyboard_arrow_down),
                      onChanged: (String? value) {
                        _isFieldFilled['sex'] = value?.isNotEmpty ?? false;
                        setState(() {
                          _dropdownValueSex = value!;
                        });
                      },
                      items: ['Masculino', 'Feminino'].map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 20.0, bottom: 8.0),
                      child: Text('Tipo de Diabetes',
                          style:
                              TextStyle(color: verdeAzulado.withOpacity(1.0))),
                    ),
                    DropdownButtonFormField(
                      // hint: Text('Selecionar'),
                      value: _dropdownValueDiabetes,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                        filled: true,
                        fillColor: verdeAzulado,
                      ),
                      icon: Icon(Icons.keyboard_arrow_down),
                      onChanged: (String? value) {
                        _isFieldFilled['diabetes'] = value?.isNotEmpty ?? false;
                        setState(() {
                          _dropdownValueDiabetes = value!;
                        });
                      },
                      items: ['Tipo 1', 'Tipo 2', 'Não tenho diabetes']
                          .map((String value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(35)),
                ValueListenableBuilder<bool>(
                  valueListenable: _validFormVN,
                  builder: (_, isValid, child) {
                    return Column(
                      children: [
                        TextButton(
                          child: const Text('Concluir'),
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            textStyle: TextStyle(
                              color: Colors.white,
                              // a cor tá errada, aparecendo cinza por algum motivo
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                            backgroundColor: isValid ? verdeClaro : Colors.grey,
                            padding: EdgeInsets.all(10.0),
                            minimumSize: Size.fromHeight(60),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: !isValid
                              ? null
                              : () async {
                                  _validationMode = AutovalidateMode.always;
                                  _validFormVN.value =
                                      _formKey.currentState?.validate() ??
                                          false;
                                  if (_validFormVN.value) {
                                    if (await AuthAPI.updateUserProfile(
                                        _birthdate.text
                                            .split('/')
                                            .reversed
                                            .join('-'),
                                        _weight.text.replaceAll(',', '.'),
                                        _height.text.replaceAll(',', '.'),
                                        _dropdownValueSex!,
                                        _dropdownValueDiabetes!)) {
                                      await Navigator.popAndPushNamed(
                                          context, '/home');
                                    }
                                    //  else {
                                    //   switch (AuthAPI.getResponseMessage()) {
                                    //     case '':
                                    //       break;
                                    //   }
                                    // }
                                  }
                                },
                        ),
                        Visibility(
                          visible: !isValid,
                          child: Container(
                            alignment: Alignment.bottomLeft,
                            padding: EdgeInsets.all(10.0),
                            child: Text(
                              '*Preencha todos os campos',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
