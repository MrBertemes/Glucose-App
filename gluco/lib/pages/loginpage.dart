// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../models/collected.dart';
import 'homepage.dart';

class LoginPage extends StatefulWidget {
  final AppBar appBar;
  final Collected dataCollected;
  final FlutterBlue bluetooth;
  const LoginPage(
      {Key? key,
      required this.appBar,
      required this.dataCollected,
      required this.bluetooth})
      : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final TextEditingController _email;
  late final TextEditingController _password;

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
    return Stack(children: [
      Positioned(
          top: -MediaQuery.of(context).size.width / 2,
          left: -MediaQuery.of(context).size.width * 0.1,
          child: ClipOval(
              child: Container(
                  width: MediaQuery.of(context).size.width * 1.2,
                  height: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                      gradient: LinearGradient(
                    begin: Alignment.center,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color.fromARGB(150, 168, 222, 234),
                      Color.fromARGB(150, 142, 196, 121)
                    ],
                  ))))),
      Positioned(
          top: MediaQuery.of(context).size.height / 10,
          left: 0,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: const Text(
            "EGluco",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 40,
              inherit: false,
            ),
          )),
      Positioned(
          top: MediaQuery.of(context).size.height / 2.2,
          left: MediaQuery.of(context).size.width * 0.05,
          height: MediaQuery.of(context).size.height / 2,
          width: MediaQuery.of(context).size.width * 0.9,
          child: Scaffold(
              backgroundColor: Colors.white,
              body: Column(children: [
                Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 10.0),
                    child: TextField(
                      controller: _email,
                      decoration: const InputDecoration(
                        hintText: "E-mail",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 142, 196, 121),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 2,
                              color: Color.fromARGB(255, 142, 196, 121)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 3,
                              color: Color.fromARGB(255, 142, 196, 121)),
                        ),
                      ),
                      cursorColor: Color.fromARGB(255, 142, 196, 121),
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context).textTheme.bodyText2,
                    )),
                Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 25.0),
                    child: TextField(
                      controller: _password,
                      decoration: const InputDecoration(
                        hintText: "Senha",
                        hintStyle: TextStyle(
                          color: Color.fromARGB(255, 130, 180, 153),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 2,
                              color: Color.fromARGB(255, 130, 180, 153)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              width: 3,
                              color: Color.fromARGB(255, 130, 180, 153)),
                        ),
                      ),
                      cursorColor: Color.fromARGB(255, 130, 180, 153),
                      style: Theme.of(context).textTheme.bodyText2,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      // textAlign: TextAlign.center,
                    )),
                Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: MediaQuery.of(context).size.width * 0.865,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Color.fromARGB(255, 51, 181, 203),
                    ),
                    child: TextButton(
                        onPressed: () async {
                          final email = _email.text;
                          final password = _password.text;
                          // await FirebaseAuth.instance.signInWithEmailAndPassword(
                          //     email: email, password: password);
                          Navigator.pop(context);
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return HomePage(
                                appBar: widget.appBar,
                                dataCollected: widget.dataCollected,
                                bluetooth: widget.bluetooth);
                          }));
                        },
                        child: const Text("Entrar",
                            style: TextStyle(fontSize: 16)),
                        style: TextButton.styleFrom(
                          primary: Colors.white,
                        ))),
                Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Expanded(
                            child: Divider(
                                thickness: 2,
                                color: Color.fromARGB(255, 51, 181, 203)),
                          ),
                          Text(
                            "  ou  ",
                            style: TextStyle(
                              color: Color.fromARGB(255, 51, 181, 203),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                                thickness: 2,
                                color: Color.fromARGB(255, 51, 181, 203)),
                          ),
                        ])),
                Container(
                    padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                    width: MediaQuery.of(context).size.width * 0.865,
                    decoration: BoxDecoration(
                      border:
                          Border.all(color: Color.fromARGB(255, 51, 181, 203)),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.white,
                    ),
                    child: TextButton(
                        // onPressed: () async {
                        //   Navigator.pop(context);
                        //   await Navigator.push(context,
                        //       MaterialPageRoute(builder: (context) {
                        //     return SignUpPage(
                        //       appBar: widget.appBar,
                        //       dataCollected: widget.dataCollected,
                        //       bluetooth: widget.bluetooth,
                        //     );
                        //   }));
                        // },
                        onPressed: () async {
                          Navigator.pop(context);
                          await Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return HomePage(
                                appBar: widget.appBar,
                                dataCollected: widget.dataCollected,
                                bluetooth: widget.bluetooth);
                          }));
                        },
                        child: const Text("Cadastrar",
                            style: TextStyle(fontSize: 16)),
                        style: TextButton.styleFrom(
                          primary: const Color.fromARGB(255, 51, 181, 203),
                        ))),
                Container(
                    padding: const EdgeInsets.only(top: 20),
                    child: TextButton(
                        onPressed: () {},
                        child: Text("Esqueci a senha",
                            style: TextStyle(
                                color: Color.fromARGB(255, 51, 181, 203))))),
              ])))
    ]);
  }
}
