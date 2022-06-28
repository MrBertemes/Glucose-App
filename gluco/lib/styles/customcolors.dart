import 'package:flutter/material.dart';

/// Classe abstrata pra guardar nossa paleta de cores
abstract class CustomColors {
  /// Tema principal e ícone da glicose
  static Color blueGreen = const Color.fromRGBO(90, 204, 194, 0.53);

  /// Campo senha, botão entrar  e ícone da temperatura
  static Color lightBlue = const Color.fromRGBO(51, 181, 204, 0.53);

  /// Campo e-mail e ícone do BPM
  static Color greenBlue = const Color.fromRGBO(97, 199, 140, 0.54);

  /// Cor do ícone da oxigenação
  static Color lightGreen = const Color.fromRGBO(116, 209, 76, 0.54);

  /// Cor do fundo
  static Color white = const Color.fromRGBO(255, 255, 255, 1.0);

  /// Cor fundo do scaffold
  static Color scaffLightBlue = const Color.fromRGBO(195, 232, 241, 1.0);
  static Color scaffWhite = const Color.fromRGBO(255, 255, 255, 0.7);

  /// Cor fundo ExpansionPanelList do Histórico
  static Color histWhite = const Color.fromRGBO(250, 250, 250, 1.0);
}
