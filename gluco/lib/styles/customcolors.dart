import 'package:flutter/material.dart';

/// Classe abstrata pra guardar nossa paleta de cores
abstract class CustomColors {
  /// Tema principal e ícone da glicose
  static Color blueGreen = const Color.fromRGBO(90, 204, 194, 1.0);

  /// Campo senha, botão entrar  e ícone da temperatura
  static Color lightBlue = const Color.fromRGBO(51, 181, 204, 1.0);

  /// Campo e-mail e ícone do BPM
  static Color greenBlue = const Color.fromRGBO(97, 199, 140, 1.0);

  /// Cor do ícone da oxigenação
  static Color lightGreen = const Color.fromRGBO(116, 209, 76, 1.0);

  /// Cor do fundo
  static Color white = const Color.fromRGBO(255, 255, 255, 1.0);
  static Color notwhite = const Color.fromRGBO(245, 248, 255, 1.0);

  /// Cor fundo do scaffold
  static Color scaffLightBlue = const Color.fromRGBO(235, 248, 255, 1.0);
  static Color scaffWhite = const Color.fromRGBO(255, 255, 255, 0.7);

  /// Cor fundo ExpansionPanelList do Histórico
  static Color histWhite = const Color.fromRGBO(250, 250, 250, 1.0);

  //fundo das telas :perfil, historico, conexao.
  static Color bluelight = const Color.fromRGBO(195, 228, 228, 1.0);
  static Color blueGreenlight = const Color.fromRGBO(196, 228, 218, 1.0);
  static Color greenlight = const Color.fromRGBO(206, 231, 197, 1.0);

  static Color gray = const Color.fromRGBO(143, 143, 143, 1.0);
}
