// ignore_for_file: prefer_final_fields

import 'package:gluco/models/collected.dart';
import 'package:intl/intl.dart';

/// Classe de visualização das medições
/// (lembro da sbs do bocadinho que tinham as entidadesVO, imagino que seja pra ValueObject)
/// fiz pra poder adicionar o atributo isExpanded que controla os paineis
class CollectedVO {
  final Collected dados;
  bool isExpanded;
  CollectedVO({
    required this.dados,
    this.isExpanded = false,
  });
}

/// Armazena as medições em uma lista ordenada da mais recente pra mais antiga
class HistoricoTeste {
  static List<CollectedVO> _collectedList = <CollectedVO>[];

  static void saveCollected(Collected collected) {
    CollectedVO _collectedVO = CollectedVO(
      dados: Collected(
        id: collected.id,
        saturacao: collected.saturacao,
        batimento: collected.batimento,
        glicose: collected.glicose,
        temperatura: collected.temperatura,
        data: collected.data,
      ),
    );
    _collectedList.insert(0, _collectedVO);
  }

  static List<CollectedVO> getCollectedRaw() {
    return _collectedList;
  }

  /// não me peça pra explicar
  /// (eu achei que ia usar mas nem usei, deixei ai, vai que venha a calhar no futuro)
  static List<dynamic> getCollectedAsList() {
    List<dynamic> listameses = <dynamic>[];
    for (var elem in _collectedList) {
      var mes = DateFormat.MMMM('pt_BR').format(elem.dados.data);
      var dia = DateFormat.EEEE('pt_BR').format(elem.dados.data);

      if (!listameses.any((meslistadias) => meslistadias.first == mes)) {
        listameses.add([mes, []]);
      }
      var mesldias =
          listameses.firstWhere((meslistadias) => meslistadias.first == mes);
      if (!mesldias[1].any((dialistamed) => dialistamed.first == dia)) {
        mesldias[1].add([dia, []]);
      }
      var diaslmed =
          mesldias[1].firstWhere((diaslistamed) => diaslistamed.first == dia);
      diaslmed[1].add(elem);
    }
    return listameses;
  }

  /// Mapeia as medições (CollectedVO) para um Map que possa ser utilizado
  /// no ListViewBuilder da página de histórico
  /// exemplos no final
  /// Chaves de Maps são ordenadas _b
  static Map<String, Map<String, List<CollectedVO>>> getCollectedAsMap() {
    Map<String, Map<String, List<CollectedVO>>> mapa =
        <String, Map<String, List<CollectedVO>>>{};
    for (var elem in _collectedList) {
      // Precisa corrigir a inicial maiuscula e tirar os -feiras
      var mes = DateFormat.MMMM('pt_BR').format(elem.dados.data);
      var dia =
          '${DateFormat.EEEE('pt_BR').format(elem.dados.data)}, ${DateFormat.d('pt_BR').format(elem.dados.data)}';
      if (!mapa.containsKey(mes)) {
        mapa[mes] = {};
      }
      if (!mapa[mes]!.containsKey(dia)) {
        mapa[mes]![dia] = [];
      }
      mapa[mes]![dia]!.add(elem);
    }
    return mapa;
  }

  static Collected getLastCollected() {
    if (_collectedList.isEmpty) {
      return Collected(
        id: 0,
        saturacao: 0,
        batimento: 0,
        glicose: 0,
        temperatura: 0,
        data: DateTime.now(),
      );
    }
    CollectedVO collected = _collectedList.first;
    return Collected(
      id: collected.dados.id,
      saturacao: collected.dados.saturacao,
      batimento: collected.dados.batimento,
      glicose: collected.dados.glicose,
      temperatura: collected.dados.temperatura,
      data: collected.dados.data,
    );
  }

  static bool initHistoricoTeste() {
    if (_collectedList.isNotEmpty) {
      return false;
    }
    List<Collected> medidas = [
      Collected(
        id: 3,
        saturacao: 99,
        batimento: 87,
        glicose: 111.69,
        temperatura: 37.1,
        data: DateTime.parse("2022-05-24 19:22:49"),
      ),
      Collected(
        id: 2,
        saturacao: 100,
        batimento: 90,
        glicose: 45.00,
        temperatura: 36.6,
        data: DateTime.parse("2022-05-24 12:27:38"),
      ),
      Collected(
        id: 1,
        saturacao: 97,
        batimento: 60,
        glicose: 47.00,
        temperatura: 36.8,
        data: DateTime.parse("2022-04-23 07:45:00"),
      ),
      Collected(
        id: 0,
        saturacao: 92,
        batimento: 119,
        glicose: 65.03,
        temperatura: 37.2,
        data: DateTime.parse("2022-04-22 18:53:18"),
      ),
    ];

    for (var collected in medidas) {
      _collectedList.add(CollectedVO(dados: collected));
    }

    return true;
  }
}



// [
//   [maio, [
//     [terça-feira, [
//       Instance of 'CollectedVO', 
//       Instance of 'CollectedVO']
//     ]
//     ]
//   ],
//   [abril, [
//     [sábado, [
//       Instance of 'CollectedVO']
//     ],
//     [sexta-feira, [
//       Instance of 'CollectedVO']
//     ]
//   ]
//   ]
// ]

// [
//   ['maio', [
//     ['terça-feira', [
//       [3, 87, 87, 111.69, 37.1, 2022-05-24 19:22:49.000],
//       [2, 90, 90, 45, 36.6, 2022-05-24 12:27:38.000]
//       ]
//     ]
//     ]
//   ],
//   ['abril', [
//     ['sábado', [
//       [1, 60, 60, 47, 36.8, 2022-04-23 07:45:00.000]
//       ]
//     ],
//     ['sexta-feira', [
//       [0, 119, 119, 65.03, 37.2, 2022-04-22 18:53:18.000]
//       ]
//     ]
//     ]
//   ]
// ]


// {
// maio:
//   {terça-feira:
//     [Instance of 'CollectedVO',
//     Instance of 'CollectedVO']
//   },
// abril:
//   {sábado:
//     [Instance of 'CollectedVO'],
//   sexta-feira: 
//     [Instance of 'CollectedVO']
//   }
// }

// {maio: {terça-feira:
//         [[2, 90, 90, 45, 36.6, 2022-05-24 12:27:38.000]]}, 
// abril: {sexta-feira:
//       [[0, 119, 119, 65.03, 37.2, 2022-04-22 18:53:18.000]]}}

// {maio: {
//       terça-feira: [[3, 87, 87, 111.69, 37.1, 2022-05-24 19:22:49.000],
//                    [2, 90, 90, 45, 36.6, 2022-05-24 12:27:38.000]]},
// abril: {
//       sábado: [[1, 60, 60, 47, 36.8, 2022-04-23 07:45:00.000]],
//       sexta-feira: [[0, 119, 119, 65.03, 37.2, 2022-04-22 18:53:18.000]]}}

