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
    this.id = -1,
    required this.spo2,
    required this.pr_rpm,
    required this.date,
  });

  Measurement.fromMap(Map<String, dynamic> json) {
    id = json['idmeasurements'] ?? -1; // id ainda não é passado nas requisições
    spo2 = int.parse('${json['spo2']}');
    pr_rpm = int.parse('${json['pr_rpm']}');
    date = DateTime.tryParse(json['date'] ?? '') ??
        DateTime.now(); // data ainda não é passada nas requisições
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> _data = <String, dynamic>{};
    // _data['idmeasurements'] = id;
    _data['spo2'] = spo2;
    _data['pr_rpm'] = pr_rpm;
    _data['date'] = date.toString(); //
    return _data;
  }
}

class MeasurementCollected extends Measurement {
  double? apparent_glucose;
  late double temperature;
  late double humidity;
  late List<double> maxled;
  late List<double> minled;
  late List<double> m_4p;
  late List<double> f_4p;
  late List<double> m_2p;
  late List<double> f_2p;

  static const _lSize = 4;
  static const _pSize = 32;

  MeasurementCollected({
    required int id,
    required this.apparent_glucose,
    required int spo2,
    required int pr_rpm,
    required this.temperature,
    required this.humidity,
    required this.maxled,
    required this.minled,
    required this.m_4p,
    required this.f_4p,
    required this.m_2p,
    required this.f_2p,
    required DateTime date,
  })  : assert(maxled.length == _lSize),
        assert(minled.length == _lSize),
        assert(m_4p.length == _pSize),
        assert(f_4p.length == _pSize),
        assert(m_2p.length == _pSize),
        assert(f_2p.length == _pSize),
        super(
          id: id,
          spo2: spo2,
          pr_rpm: pr_rpm,
          date: date,
        );

  MeasurementCollected.fromMap(Map<String, dynamic> json)
      : super.fromMap(json) {
    apparent_glucose = double.parse('${json['glucose']}');
    temperature = double.parse('${json['temperature']}');
    humidity = double.parse('${json['humidity']}');
    maxled = <double>[];
    minled = <double>[];
    m_4p = <double>[];
    f_4p = <double>[];
    m_2p = <double>[];
    f_2p = <double>[];
    for (int i = 1; i <= _lSize; i++) {
      maxled.add(double.parse('${json['maxled$i']}'));
      minled.add(double.parse('${json['minled$i']}'));
    }
    for (int i = 1; i <= _pSize; i++) {
      m_4p.add(double.parse('${json['m${i}_4p']}'));
      f_4p.add(double.parse('${json['f${i}_4p']}'));
      m_2p.add(double.parse('${json['m${i}_2p']}'));
      f_2p.add(double.parse('${json['f${i}_2p']}'));
    }
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> _data = <String, dynamic>{};
    _data['glucose'] = apparent_glucose;
    _data['temperature'] = temperature;
    _data['humidity'] = humidity;
    for (int i = 1; i <= _lSize; i++) {
      _data['maxled$i'] = maxled[i - 1];
      _data['minled$i'] = minled[i - 1];
    }
    for (int i = 1; i <= _pSize; i++) {
      _data['m${i}_4p'] = m_4p[i - 1];
      _data['f${i}_4p'] = f_4p[i - 1];
      _data['m${i}_2p'] = m_2p[i - 1];
      _data['f${i}_2p'] = f_2p[i - 1];
    }
    _data.addAll(super.toMap());
    return _data;
  }
}

class MeasurementCompleted extends Measurement {
  late double glucose;

  MeasurementCompleted({
    required int id,
    required int spo2,
    required int pr_rpm,
    required this.glucose,
    required DateTime date,
  }) : super(
          id: id,
          spo2: spo2,
          pr_rpm: pr_rpm,
          date: date,
        );

  MeasurementCompleted.fromMap(Map<String, dynamic> json)
      : super.fromMap(json) {
    glucose = double.parse('${json['glucose']}');
  }

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> _data = <String, dynamic>{};
    _data['glucose'] = glucose;
    _data.addAll(super.toMap());
    return _data;
  }
}
