// Troquei a classe measurement pro padrão de estado, a professora rebeca
// que deu a ideia e eu achei que ficou interessante, a medição pode estar em
// andamento ou concluida, como tem dados que vem do bluetooth e serão usados
// no calculo na nuvem mas não importam pro usuario faz sentido deixar separado
// pra não armazenar informação desnecessária e facilitar no envio e recebimento
// das requisições
abstract class Measurement {
  late int id;
  late int spo2;
  late int pr_rpm;
  late DateTime date;

  Measurement({
    required this.id,
    required this.spo2,
    required this.pr_rpm,
    required this.date,
  });

  Measurement.fromMap(Map<String, dynamic> json) {
    id = json['idmeasurements'] ?? -1; // id ainda não é passado nas requisições
    spo2 = json['spo2'];
    pr_rpm = json['pr_rpm'];
    date = DateTime.tryParse(json['date']) ??
        DateTime.now(); // data ainda não é passada nas requisições
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> _data = <String, dynamic>{};
    _data['idmeasurements'] = id;
    _data['spo2'] = spo2;
    _data['pr_rpm'] = pr_rpm;
    _data['date'] = date.toString();
    return _data;
  }
}

class MeasurementCollected extends Measurement {
  late double apparent_glucose;
  late double temperature;
  late List<double> m_4p;
  late List<double> f_4p;

  MeasurementCollected({
    required id,
    required this.apparent_glucose,
    required spo2,
    required pr_rpm,
    required this.temperature,
    required this.m_4p,
    required this.f_4p,
    required date,
  })  : assert(m_4p.length == 24),
        assert(f_4p.length == 24),
        super(
          id: id,
          spo2: spo2,
          pr_rpm: pr_rpm,
          date: date,
        );

  MeasurementCollected.fromMap(Map<String, dynamic> json)
      : super.fromMap(json) {
    apparent_glucose = json['glucose'];
    temperature = json['temperature'];
    m_4p = <double>[];
    f_4p = <double>[];
    for (int i = 1; i <= 24; i++) {
      m_4p.add(json['m${i}_4p']);
      f_4p.add(json['f${i}_4p']);
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> _data = <String, dynamic>{};
    _data['glucose'] = apparent_glucose;
    _data['temperature'] = temperature;
    for (int i = 1; i <= 24; i++) {
      _data['m${i}_4p'] = m_4p[i - 1];
      _data['f${i}_4p'] = f_4p[i - 1];
    }
    _data.addAll(super.toMap());
    return _data;
  }
}

class MeasurementCompleted extends Measurement {
  late double glucose;

  MeasurementCompleted({
    required id,
    required spo2,
    required pr_rpm,
    required this.glucose,
    required date,
  }) : super(
          id: id,
          spo2: spo2,
          pr_rpm: pr_rpm,
          date: date,
        );

  MeasurementCompleted.fromMap(Map<String, dynamic> json)
      : super.fromMap(json) {
    glucose = json['glucose'];
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> _data = <String, dynamic>{};
    _data['glucose'] = glucose;
    _data.addAll(super.toMap());
    return _data;
  }
}
