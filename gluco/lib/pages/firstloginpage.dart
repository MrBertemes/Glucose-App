// ignore_for_file: must_be_immutable, use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/services/authapi.dart';
import 'package:gluco/styles/colors.dart';

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
    double landscapeCorrection =
        MediaQuery.of(context).orientation == Orientation.landscape ? 0.6 : 1.0;
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
                Padding(padding: EdgeInsets.all(20.0 * landscapeCorrection)),
                Stack(
                  alignment: AlignmentDirectional.bottomEnd,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.4 *
                          landscapeCorrection,
                      padding: EdgeInsets.all(10.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: azulEsverdeado.withOpacity(1.0),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: MediaQuery.of(context).size.width *
                              0.3 *
                              landscapeCorrection,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        Icons.photo_camera_rounded,
                        size: 35.0,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        // precisa incluir aqui o imagepicker
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: 25.0,
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16.0,
                        color: azulEsverdeado.withOpacity(1.0),
                      ),
                      children: [
                        TextSpan(
                          text:
                              'Olá, ${AuthAPI.currentUser.name.split(' ')[0]}!\n',
                          style: TextStyle(
                            fontSize: 22.0,
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
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        hintText: 'dd/mm/aaaa',
                        filled: true,
                        fillColor: verdeAzulado,
                        isDense: true,
                        contentPadding: EdgeInsets.all(12.0),
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
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              hintText: '70,5',
                              // suffixText: 'kg',
                              filled: true,
                              fillColor: verdeAzulado, isDense: true,
                              contentPadding: EdgeInsets.all(12.0),
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
                                borderSide: BorderSide.none,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)),
                              ),
                              hintText: '1,67',
                              // suffixText: 'm',
                              filled: true,
                              fillColor: verdeAzulado, isDense: true,
                              contentPadding: EdgeInsets.all(12.0),
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
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        filled: true,
                        fillColor: verdeAzulado,
                        isDense: true,
                        contentPadding: EdgeInsets.all(12.0),
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
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                        filled: true,
                        fillColor: verdeAzulado,
                        isDense: true,
                        contentPadding: EdgeInsets.all(12.0),
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
                Padding(padding: EdgeInsets.all(30)),
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
