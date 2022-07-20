// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/styles/defaultappbar.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage();

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User user = API.instance.currentUser!;
  late final TextEditingController _birthdate;
  late final TextEditingController _weight;
  late final TextEditingController _height;

  String _dropdownValueSex = API.instance.currentUser!.profile!.sex;
  String _dropdownValueDiabetes = API.instance.currentUser!.profile!.diabetes;

  @override
  void initState() {
    _birthdate = TextEditingController(
        text: DateFormat.yMd('pt_BR').format(user.profile!.birthdate));
    _weight = TextEditingController(text: user.profile!.weight.toString());
    _height = TextEditingController(text: user.profile!.height.toString());
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

  final ValueNotifier<bool> _validFormVN = ValueNotifier<bool>(false);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double landscapeCorrection =
        MediaQuery.of(context).orientation == Orientation.landscape ? 0.6 : 1.0;
    return Scaffold(
      appBar: defaultAppBar(title: 'Meu Perfil'),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
                minWidth: viewportConstraints.maxWidth,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
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
                            color: CustomColors.blueGreen.withOpacity(1.0),
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
                        text: user.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28.0,
                          color: CustomColors.blueGreen.withOpacity(1.0),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: CustomColors.scaffWhite,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                    ),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: () {
                        _validFormVN.value =
                            _formKey.currentState?.validate() ?? false;
                      },
                      child: Column(
                        children: [
                          Card(
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.0, left: 10.0),
                                  child: Text(
                                    'Data de Nascimento',
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      color: CustomColors.blueGreen
                                          .withOpacity(1.0),
                                    ),
                                  ),
                                ),
                                TextFormField(
                                  controller: _birthdate,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none),
                                    hintText: 'dd/mm/aaaa',
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(12.0),
                                  ),
                                  validator: (text) {
                                    if (text == null ||
                                        text.length != 10 ||
                                        !text.contains('/') ||
                                        DateTime.tryParse(text
                                                .split('/')
                                                .reversed
                                                .join('-')) ==
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
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Card(
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16.0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 8.0, left: 10.0),
                                        child: Text(
                                          'Peso',
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            color: CustomColors.blueGreen
                                                .withOpacity(1.0),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _weight,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          // hintText: '70,5',
                                          suffixText: 'kg',
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(12.0),
                                        ),
                                        validator: (text) {
                                          if (text == null ||
                                              double.tryParse(text.replaceAll(
                                                      ',', '.')) ==
                                                  null) {
                                            return '*Insira um número válido';
                                          }
                                          // precisa testar também se o valor inserido faz sentido => ex. 30.0<text<200.0
                                          return null;
                                        },
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Card(
                                  elevation: 3.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16.0)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(
                                            top: 8.0, left: 10.0),
                                        child: Text(
                                          'Altura',
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            color: CustomColors.blueGreen
                                                .withOpacity(1.0),
                                          ),
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _height,
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                          ),
                                          // hintText: '1,67',
                                          suffixText: 'm',
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(12.0),
                                        ),
                                        validator: (text) {
                                          if (text == null ||
                                              double.tryParse(text.replaceAll(
                                                      ',', '.')) ==
                                                  null) {
                                            return '*Insira um número válido';
                                          }
                                          // precisa testar também se o valor inserido faz sentido => ex. 0.5<text<2.5
                                          return null;
                                        },
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Card(
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 10.0, left: 8.0),
                                  child: Text(
                                    'Sexo',
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      color: CustomColors.blueGreen
                                          .withOpacity(1.0),
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField(
                                  value: _dropdownValueSex,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(12.0),
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _dropdownValueSex = value!;
                                    });
                                  },
                                  items: ['Masculino', 'Feminino']
                                      .map((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Card(
                            elevation: 3.0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(top: 10.0, left: 8.0),
                                  child: Text(
                                    'Tipo de Diabetes',
                                    style: TextStyle(
                                      fontSize: 22.0,
                                      color: CustomColors.blueGreen
                                          .withOpacity(1.0),
                                    ),
                                  ),
                                ),
                                DropdownButtonFormField(
                                  value: _dropdownValueDiabetes,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                    ),
                                    isDense: true,
                                    contentPadding: EdgeInsets.all(12.0),
                                  ),
                                  icon: Icon(Icons.keyboard_arrow_down),
                                  onChanged: (String? value) {
                                    setState(() {
                                      _dropdownValueDiabetes = value!;
                                    });
                                  },
                                  items: [
                                    'Tipo 1',
                                    'Tipo 2',
                                    'Não tenho diabetes',
                                  ].map((String value) {
                                    return DropdownMenuItem(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                          Padding(padding: EdgeInsets.all(10.0)),
                          ValueListenableBuilder<bool>(
                            valueListenable: _validFormVN,
                            builder: (_, isValid, child) {
                              return Column(
                                children: [
                                  TextButton(
                                    child: const Text('Salvar'),
                                    style: TextButton.styleFrom(
                                      primary: Colors.white,
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        // a cor tá errada, aparecendo cinza por algum motivo
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
                                            _validFormVN.value = _formKey
                                                    .currentState
                                                    ?.validate() ??
                                                false;
                                            if (_validFormVN.value) {
                                              if (await API.instance
                                                  .updateUserProfile(
                                                      _birthdate.text
                                                          .split('/')
                                                          .reversed
                                                          .join('-'),
                                                      _weight.text
                                                          .replaceAll(',', '.'),
                                                      _height.text
                                                          .replaceAll(',', '.'),
                                                      _dropdownValueSex,
                                                      _dropdownValueDiabetes)) {
                                                _validFormVN.value = false;
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
                                ],
                              );
                            },
                          ),
                          Padding(padding: EdgeInsets.all(20.0)),
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
