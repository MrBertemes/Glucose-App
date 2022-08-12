// ignore_for_file: prefer_final_fields, non_constant_identifier_names

import 'package:gluco/db/databasehelper.dart';
import 'package:gluco/models/measurement.dart';
import 'package:gluco/services/api.dart';
import 'package:intl/intl.dart';

/// Classe de visualização das medições.
/// Possui os dados da medição propriamente ditos e o atributo isExpanded
/// para controlar o estado do painel expandido/colapsado na tela de histórico
class MeasurementVO {
  late double glucose;
  late int spo2;
  late int pr_rpm;
  late DateTime date;
  bool isExpanded = false;

  MeasurementVO(
    MeasurementCompleted measurement,
  ) {
    glucose = measurement.glucose;
    spo2 = measurement.spo2;
    pr_rpm = measurement.pr_rpm;
    date = measurement.date;
  }
}

/// Armazena as medições em memória em um mapa de meses para viabilizar a
/// construção da visualização do histórico de medições.
/// As chaves do mapa são strings 'mes, ano' e os valores são mapas de dias,
/// as chaves destes são strings 'diasemana, diames' e os valores são listas
/// de medições ordenadas da mais recente para a mais antiga
abstract class HistoryVO {
  /// Mapa de medições
  static final Map<String, Map<String, List<MeasurementVO>>> measurementsVOMap =
      <String, Map<String, List<MeasurementVO>>>{};

  /// Medição mais recente, utilizada na visualização da home
  /// (eu quis tirar o collected da inicialização na main pra não ter que passar
  /// pra home por parametro, mas não sei se faz sentido ela ficar aqui)
  static final MeasurementCompleted currentMeasurement = MeasurementCompleted(
    id: -1,
    spo2: 0,
    pr_rpm: 0,
    glucose: 0,
    date: DateTime.now(), // talvez não faça sentido
  );

  /// Insere a medição atual no mapa
  static bool updateMeasurementsMap() {
    return _insertMeasurementVO(currentMeasurement);
  }

  /// Mapeia Measurement para uma instância de MeasurementVO
  /// e insere no mapa de visualização
  static bool _insertMeasurementVO(MeasurementCompleted measurement) {
    if (measurement.id != -1) {
      // faz uma copia pq a inclusão é por referência
      MeasurementVO _measurementVO = MeasurementVO(measurement);
      String MMMMy = // 'mes, ano'
          DateFormat('MMMM, y', 'pt_BR').format(_measurementVO.date);
      String EEEEd = // 'diasemana, diames'
          DateFormat('EEEE, d', 'pt_BR').format(_measurementVO.date);
      // Capitalização dos nomes de mês e dia
      MMMMy = MMMMy.replaceRange(0, 1, MMMMy[0].toUpperCase());
      EEEEd = EEEEd.replaceRange(0, 1, EEEEd[0].toUpperCase());
      // Retira os '-feira'
      int index = EEEEd.indexOf('-');
      if (index != -1) {
        EEEEd = EEEEd.replaceRange(index, index + 6, '');
      }
      EEEEd = EEEEd.split('-')[0]; // tá certo isso?
      // Insere a medição no mapa
      if (!measurementsVOMap.containsKey(MMMMy)) {
        measurementsVOMap[MMMMy] = {};
      }
      if (!measurementsVOMap[MMMMy]!.containsKey(EEEEd)) {
        measurementsVOMap[MMMMy]![EEEEd] = [];
      }
      // --- ideia: talvez verificar se não está incluindo duplicado, por consistência
      measurementsVOMap[MMMMy]![EEEEd]!.insert(0, _measurementVO);
      return true;
    }
    return false;
  }

  /// Busca as medições recentes do usuário no banco e mapeia em memória,
  /// utilizada no login
  static Future<bool> fetchHistory() async {
    List<MeasurementCompleted> measurementsList = await DatabaseHelper.instance
        .queryMeasurements(API.instance.currentUser!);

    if (measurementsList.isNotEmpty) {
      // não sei o quanto faz sentido: a querymeasurements retorna uma lista
      // ordenada da mais recente pra mais antiga, só que a _insertMeasurementVO
      // insere no inicio da lista pra updateMeasurementsMap colocar a mais recente
      // no lugar certo, então fiz a measurementsList ser inserida invertida (reversed)
      // pra funcionar, não quis fazer a queryMeasurements retornar uma lista
      // já ordenada da mais antiga pra mais recente pq não faria sentido, ou faria?
      for (MeasurementCompleted measurement in measurementsList.reversed) {
        _insertMeasurementVO(measurement);
      }
      currentMeasurement.id = measurementsList.first.id;
      currentMeasurement.glucose = measurementsList.first.glucose;
      currentMeasurement.spo2 = measurementsList.first.spo2;
      currentMeasurement.pr_rpm = measurementsList.first.pr_rpm;
      currentMeasurement.date = measurementsList.first.date;
      return true;
    }

    return false;
  }

  /// Apaga as medições da memória, utilizado no logout
  static void disposeHistory() {
    measurementsVOMap.clear();
    currentMeasurement.id = -1;
    currentMeasurement.glucose = 0;
    currentMeasurement.spo2 = 0;
    currentMeasurement.pr_rpm = 0;
    currentMeasurement.date = DateTime.now();
  }
}
