class Measurement {
  int id;
  int sats;
  int bpm;
  double glucose;
  double temperature;
  DateTime date;

  Measurement({
    required this.id,
    required this.sats,
    required this.bpm,
    required this.glucose,
    required this.temperature,
    required this.date,
  });

  factory Measurement.fromMap(Map<String, dynamic> json) => Measurement(
        id: json['idmeasurements'],
        sats: json['sats'],
        bpm: json['bpm'],
        glucose: json['glucose'],
        temperature: json['temperature'],
        date: DateTime.parse(json['date']),
      );

  Map<String, dynamic> toMap() {
    return {
      'idmeasurements': id,
      'glucose': glucose,
      'sats': sats,
      'bpm': bpm,
      'temperature': temperature,
      'date': date.toString(),
    };
  }
}
