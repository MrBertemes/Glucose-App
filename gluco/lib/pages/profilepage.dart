// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors_in_immutables, prefer_const_constructors

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/user.dart';
import 'package:gluco/services/api.dart';
import 'package:gluco/styles/customcolors.dart';
import 'package:gluco/styles/dateformatter.dart';
import 'package:gluco/styles/defaultappbar.dart';

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
  Image? _profile_pic;
  String? _profile_pic_path;

  final String _dropdownValueSex =
      API.instance.currentUser!.profile.sex == 'M' ? 'Masculino' : 'Feminino';
  final String _dropdownValueDiabetes =
      API.instance.currentUser!.profile.diabetes_type == 'T1'
          ? 'Tipo 1'
          : API.instance.currentUser!.profile.diabetes_type == 'T2'
              ? 'Tipo 2'
              : 'Não tenho diabetes';

  @override
  void initState() {
    _birthdate = TextEditingController(
        text: DateFormat.yMd('pt_BR').format(user.profile.birthday));
    _weight = TextEditingController(text: user.profile.weight.toString());
    _height = TextEditingController(text: user.profile.height.toString());
    _profile_pic_path = user.profile.profile_pic;
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

  void _loadProfilePic() {
    File file = File(_profile_pic_path!);
    if (file.existsSync()) {
      _profile_pic = Image.file(file);
    }
    setState(() {});
  }

  final ValueNotifier<bool> _validFormVN = ValueNotifier<bool>(false);
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    double landscapeCorrection =
        MediaQuery.of(context).orientation == Orientation.landscape ? 0.6 : 1.0;
    _loadProfilePic();
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            CustomColors.bluelight,
            CustomColors.blueGreenlight,
            CustomColors.greenlight,
          ],
        ),
      ),
      child: Scaffold(
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
                            child: _profile_pic == null
                                ? Icon(
                                    Icons.person,
                                    size: MediaQuery.of(context).size.width *
                                        0.3 *
                                        landscapeCorrection,
                                    color: Colors.white,
                                  )
                                : CircleAvatar(
                                    backgroundImage: _profile_pic!.image,
                                    radius: MediaQuery.of(context).size.width *
                                        0.15 *
                                        landscapeCorrection,
                                  ),
                          ),
                        ),
                        FloatingActionButton(
                          backgroundColor: Colors.grey[200],
                          child: Icon(
                            Icons.photo_camera_rounded,
                            size: 30.0,
                            color: Colors.grey,
                          ),
                          onPressed: () async {
                            XFile? pickedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);
                            if (pickedImage == null) {
                              return;
                            }
                            CroppedFile? croppedImage =
                                await ImageCropper().cropImage(
                              sourcePath: pickedImage.path,
                              maxWidth: 360,
                              maxHeight: 360,
                              aspectRatio:
                                  CropAspectRatio(ratioX: 1.0, ratioY: 1.0),
                              cropStyle: CropStyle.circle,
                            );
                            if (croppedImage == null) {
                              return;
                            }
                            Directory dir =
                                await getApplicationDocumentsDirectory();
                            File image = await File(
                                    join(dir.path, 'EG_${pickedImage.name}'))
                                .writeAsBytes(await croppedImage.readAsBytes());
                            _profile_pic_path = image.path;
                            // temporário ?
                            user.profile.profile_pic = _profile_pic_path!;
                            await API.instance.updateDBUserProfile();
                            //
                            _loadProfilePic();
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
                            color: CustomColors.lightBlue.withOpacity(1.0),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(15.0),
                      decoration: BoxDecoration(
                        color: CustomColors.scaffWhite.withOpacity(0.5),
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
                              margin: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 10.0,
                                  right: 10),
                              elevation: 2.0,
                              color: CustomColors.notwhite,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(11.0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 10.0, left: 15.0),
                                    child: Text(
                                      'Data de Nascimento',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: CustomColors.lightGreen,
                                      ),
                                    ),
                                  ),
                                  TextFormField(
                                    enabled:
                                        false, // Não pode ser alterado por enquanto
                                    controller: _birthdate,
                                    inputFormatters: [DateFormatter()],
                                    style: TextStyle(color: Colors.black38),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide.none),
                                      hintText: 'dd/mm/aaaa',
                                      isDense: true,
                                      contentPadding: EdgeInsets.only(
                                          top: 15.0, left: 15.0),
                                    ),
                                    validator: (text) {
                                      bool valid = false;
                                      try {
                                        DateFormat.yMd('pt_BR')
                                            .parseStrict(text ?? '');
                                        valid = true;
                                      } catch (e) {}
                                      if (text == null ||
                                          text.length != 10 ||
                                          !text.contains('/') ||
                                          !valid) {
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
                                    margin: EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 10.0,
                                        left: 10.0,
                                        right: 5),
                                    elevation: 2.0,
                                    color: CustomColors.notwhite,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(11.0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 10.0, left: 15.0),
                                          child: Text(
                                            'Peso',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: CustomColors.lightGreen
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
                                            contentPadding: EdgeInsets.only(
                                                top: 15.0,
                                                left: 15.0,
                                                right: 10.0),
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
                                    margin: EdgeInsets.only(
                                        top: 10.0,
                                        bottom: 10.0,
                                        left: 5.0,
                                        right: 10),
                                    elevation: 2.0,
                                    color: CustomColors.notwhite,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(11.0)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(
                                              top: 10.0, left: 15.0),
                                          child: Text(
                                            'Altura',
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              color: CustomColors.lightGreen
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
                                            contentPadding: EdgeInsets.only(
                                                top: 15.0,
                                                left: 15.0,
                                                right: 10.0),
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
                              margin: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 10.0,
                                  right: 10),
                              elevation: 2.0,
                              color: CustomColors.notwhite,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(11.0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 10.0, left: 15.0),
                                    child: Text(
                                      'Sexo',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: CustomColors.lightGreen
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
                                      contentPadding: EdgeInsets.only(
                                          top: 15.0, left: 15.0, right: 10.0),
                                    ),
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    onChanged: null,
                                    // Não pode ser alterado por enquanto
                                    // (String? value) {
                                    //   setState(() {
                                    //     _dropdownValueSex = value!;
                                    //   });
                                    // },
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
                              margin: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 10.0,
                                  right: 10),
                              elevation: 2.0,
                              color: CustomColors.notwhite,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(11.0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding:
                                        EdgeInsets.only(top: 10.0, left: 15.0),
                                    child: Text(
                                      'Tipo de Diabetes',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        color: CustomColors.lightGreen
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
                                      contentPadding: EdgeInsets.only(
                                          top: 15.0, left: 15.0, right: 10.0),
                                    ),
                                    icon: Icon(Icons.keyboard_arrow_down),
                                    onChanged: null,
                                    // Não pode ser alterado por enquanto
                                    // (String? value) {
                                    //   setState(() {
                                    //     _dropdownValueDiabetes = value!;
                                    //   });
                                    // },
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
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 15.0, left: 15.0)),
                            ValueListenableBuilder<bool>(
                              valueListenable: _validFormVN,
                              builder: (_, isValid, child) {
                                return Column(
                                  children: [
                                    TextButton(
                                      child: const Text(
                                          'Salvar'), // nao consegui deixar esse botão do mesmo tamanho dos outros retangulos acima dele
                                      style: TextButton.styleFrom(
                                        primary: Colors.white,
                                        textStyle: TextStyle(
                                          color: Colors.white,
                                          // a cor tá errada, aparecendo cinza por algum motivo
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        backgroundColor: isValid
                                            ? CustomColors.lightGreen
                                            : Colors.grey,
                                        padding: EdgeInsets.all(15.0),
                                        minimumSize: Size.fromHeight(65),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(11.0),
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
                                                        DateFormat.yMd('pt_BR')
                                                            .parseStrict(
                                                                _birthdate
                                                                    .text),
                                                        double.parse(_weight
                                                            .text
                                                            .replaceAll(',',
                                                                '.')),
                                                        double
                                                            .parse(_height.text
                                                                .replaceAll(
                                                                    ',', '.')),
                                                        _dropdownValueSex ==
                                                                'Masculino'
                                                            ? 'M'
                                                            : 'F',
                                                        _dropdownValueDiabetes ==
                                                                'Tipo 1'
                                                            ? 'T1'
                                                            : _dropdownValueDiabetes ==
                                                                    'Tipo 2'
                                                                ? 'T2'
                                                                : 'NP',
                                                        _profile_pic_path ??
                                                            '')) {
                                                  _validFormVN.value = false;
                                                }
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
      ),
    );
  }
}
