import 'dart:async';
import 'dart:convert';
import 'dart:math';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:gluco/models/device.dart';
import 'package:gluco/models/measurement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothHelper {
  BluetoothHelper._privateConstructor();

  static final BluetoothHelper instance = BluetoothHelper._privateConstructor();

  final FlutterBluePlus _bluetooth = FlutterBluePlus.instance;

  // Dispositivo atualmente conectado, é o que é efetivamente utilizado na coleta
  _DeviceInternal? _connectedDevice;

  // Variável que contém o conteúdo enviado ao dispositivo
  late String _flag;

  /// Stream com sinais de alteração no estado do Bluetooth ligado/desligado
  Stream<bool> get state => _state().asBroadcastStream();

  /// Stream que encapsula e transmite os sinais de estado do FlutterBlue
  Stream<bool> _state() async* {
    await for (final value in _bluetooth.state) {
      bool available = value == BluetoothState.on ? true : false;
      if (!available) {
        disconnect();
        _devices.clear();
      }
      yield available;
    }
  }

  /// Stream com sinais de iniciando/parando escaneamento
  Stream<bool> get scanning => _scanning().asBroadcastStream();

  /// Stream que encapsula e transmite os sinais de escaneamento do FlutterBlue
  Stream<bool> _scanning() async* {
    await for (final value in _bluetooth.isScanning) {
      yield value;
    }
  }

  /// Stream com sinais de conectado/desconectado do dispositivo atualmente conectado
  Stream<bool> get connected => _connected.stream;
  final StreamController<bool> _connected = StreamController<bool>.broadcast();

  /// Inicia a alimentação da stream do estado de conexão do dispositivo
  /// continuamente até que seja desconectado, tenta reconectar automaticamente
  /// se a desconexão não foi solicitada de forma manual
  void _yieldConnection() async {
    // envia o primeiro valor, pq o da stream state é perdido
    _connected.add(true);
    String error = 'Connected';
    try {
      await for (final value in _connectedDevice!.device.state) {
        bool conn = value == BluetoothDeviceState.connected ? true : false;
        // tenta reconectar
        if (!conn) {
          if (await connect(Device(id: _connectedDevice!.device.id.id))) {
            conn = true;
            error = 'Reconnected';
          } else {
            disconnect();
            error = 'Disconnected by signal loss';
          }
        }
        _connected.add(conn);
        print('--- YieldConnection :: $conn : $error');
        error = 'Connected';
      }
    } catch (e) {
      // sempre termina por exceção pois na desconexão
      // _connectedDevice é setado com nulo e é usado null check no for
      _connected.add(false);
      // error = 'Exception: $e';
    }
    print('--- YieldConnection :: Terminated : $error');
  }

  /// Lista de dispositivos encontrados pelo escaneamento
  final List<BluetoothDevice> _devices = [];

  /// Mapeamento dos BluetoothDevices para Devices com inclusão do
  /// dispositivo atualmente conectado
  List<Device> get devices {
    List<Device> dvcs =
        _devices.map((d) => Device(id: d.id.id, name: d.name)).toList();
    if (_connectedDevice != null) {
      // encontra o dispositivo conectado e marca como conectado
      dvcs.firstWhere((d) => d.id == _connectedDevice!.device.id.id).connected =
          true;
    }
    return dvcs;
  }

  /// Inicia escaneamento e inclui os resultados em devices
  Future<void> scan() async {
    await _bluetooth.startScan(timeout: const Duration(seconds: 3));
    _bluetooth.scanResults.listen(
      (results) {
        _devices.clear();
        for (ScanResult r in results) {
          if (RegExp(r'MXCHIP.*', dotAll: true).hasMatch(r.device.name)) {
            // if (RegExp(r'.*', dotAll: true).hasMatch(r.device.name)) {
            _devices.add(r.device);
            print("--- Device :: ${r.device.name} - ${r.device.id.id}");
          }
        }
      },
    );
    await _bluetooth.stopScan();
    if (_connectedDevice != null) {
      // dispositivos conectados não são inseridos automaticamente
      // na lista de scan do FlutterBlue
      _devices.insert(0, _connectedDevice!.device);
    }
  }

  /// Tenta estabelecer conexão com um dispositivo, pode falhar por timeout,
  /// se bem sucedido _connectedDevice é atualizado e a transmissão
  /// da stream de conexão é iniciada
  Future<bool> connect(Device dvc) async {
    bool status = true;
    String error = 'Success';
    try {
      BluetoothDevice device = _devices.firstWhere((d) => d.id.id == dvc.id);
      // autoConnect como true tava dando problema no _connectedDevice ser setado com null
      await device
          .connect(autoConnect: false)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        status = false;
        device.disconnect();
        error = 'Timeout';
      }).whenComplete(() async {
        if (status) {
          // Busca pelos descritores das características por correspondência com RX e TX
          BluetoothCharacteristic? rx;
          BluetoothCharacteristic? tx;
          List<BluetoothService> services = await device.discoverServices();
          try {
            List<BluetoothCharacteristic> characteristics = services
                .firstWhere((element) =>
                    element.uuid.toString().toUpperCase().substring(4, 8) ==
                    '8251')
                .characteristics;
            rx = characteristics.firstWhere((element) =>
                element.uuid.toString().toUpperCase().substring(4, 8) ==
                '2D3F');
            tx = characteristics.firstWhere((element) =>
                element.uuid.toString().toUpperCase().substring(4, 8) ==
                'F2A8');
          } catch (e) {
            print('Characteristics not found');
          }
          /*
          for (BluetoothService s in services) {
            for (BluetoothCharacteristic c in s.characteristics) {
              for (BluetoothDescriptor d in c.descriptors) {
                List<int> hex = await d.read();
                String value = utf8.decode(hex, allowMalformed: true);
                if (value == 'RXD Port') {
                  rx = c;
                }
                if (value == 'TXD Port') {
                  tx = c;
                }
              }
            }
          }
          */
          // estabelece novo dispositivo conectado, inicia a stream de conexão,
          // e inicia transmissão do sinal que solicita medição
          if (rx != null && tx != null) {
            _connectedDevice =
                _DeviceInternal(device: device, receiver: rx, transmitter: tx);
            await _saveDevice(device.id.id);
            // ### falta: função para verificar se possui medições nao recebidas
            _yieldConnection();
            _flag = _BluetoothFlags.idle;
            _transmit();
          } else {
            device.disconnect();
            status = false;
            error = 'RX or TX not found';
          }
        }
      });
    } catch (e) {
      status = false;
      error = 'Exception: $e';
    }
    print('--- Connection status :: $status : $error');
    return status;
  }

  /// Encapsula a função de desconectar do FlutterBlue, é a única que seta
  /// _connectedDevice como null
  Future<bool> disconnect() async {
    try {
      BluetoothDevice dvc = _connectedDevice!.device;
      _connectedDevice = null;
      await dvc.disconnect();
      print('--- Disconnected');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Busca por um dispositivo previamente conectado no SharedPreferences
  /// para tentar reconectar ao iniciar o aplicativo
  // ### Como fazer para reconectar
  // ### mesmo após já estar com app aberto e ter perdido conexão ????
  Future<bool> autoConnect() async {
    String? deviceId = await _fetchDevice();
    if (deviceId == null) {
      return false;
    }
    print('--- AutoConnect SP :: $deviceId');
    await scan();
    return await connect(Device(id: deviceId));
  }

  /// Salva o id do dispositivo conectado no SharedPreferences
  Future<bool> _saveDevice(String id) async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return await sp.setString('egble', id);
  }

  /// Recupera o id do último dispositivo conectado do SharedPreferences
  Future<String?> _fetchDevice() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString('egble');
  }

  /// Escreve a flag continuamente no Bluetooth para iniciar uma nova medição
  void _transmit() async {
    Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        if (_connectedDevice == null) {
          timer.cancel();
        }
        if (_flag != _BluetoothFlags.waiting) {
          // precisa esperar receber ?? (withResponse com async e await)
          _connectedDevice!.transmitter.write(utf8.encode(_flag));
          print('--- Transmit: $_flag');
        }
        if (_flag == _BluetoothFlags.requesting) {
          _flag = _BluetoothFlags.waiting;
        }
        if (_flag == _BluetoothFlags.received) {
          _flag = _BluetoothFlags.idle;
        }
      },
    );
  }

  /// Faz a leitura dos dados da medição do dispositivo conectado VERSÃO RANDOM
  Future<MeasurementCollected> collect() async {
    Random random = Random();
    List<double> m_4p = <double>[];
    List<double> f_4p = <double>[];
    for (int i = 1; i <= 24; i++) {
      m_4p.add((random.nextDouble() * 10000).truncateToDouble() / 1000 + 5);
      f_4p.add((random.nextDouble() * 10000).truncateToDouble() / 1000 + 5);
    }
    MeasurementCollected measure = MeasurementCollected(
      id: -1,
      apparent_glucose: null,
      spo2: random.nextInt(5) + 96,
      pr_rpm: random.nextInt(30) + 60,
      temperature: (((random.nextInt(38) + 35) + random.nextDouble()) * 100)
              .truncateToDouble() /
          100,
      m_4p: m_4p,
      f_4p: f_4p,
      date: DateTime.now(),
    );
    await Future.delayed(Duration(seconds: random.nextInt(2) + 3));
    return measure;
  }

  /// Faz a leitura dos dados da medição do dispositivo conectado
  // Future<MeasurementCollected> collect() async {
  Future<Map<String, String>> collect_real() async {
    assert(_connectedDevice != null);

    _flag = _BluetoothFlags.requesting;
    Completer<void> confirm = Completer();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // a flag é trocada dentro do método _transmit
      if (_flag != _BluetoothFlags.requesting) {
        confirm.complete();
        timer.cancel();
      }
    });
    // aguarda confirmação que a flag foi enviada
    await confirm.future.timeout(Duration(seconds: 3));
    //
    Map<String, String> measure = {};
    List<int> hex = await _connectedDevice!.receiver.read();
    measure['Mensagem'] = utf8.decode(hex);
    //
    // ### se der ocorrer um erro precisa enviar que deu erro?
    _flag = _BluetoothFlags.received;

    // split por espaço ???
    // MeasurementCollected measure = MeasurementCollected(
    // id: id, apparent_glucose: apparent_glucose, spo2: spo2,
    // pr_rpm: pr_rpm, temperature: temperature,
    // m_4p: m_4p, f_4p: f_4p, date: date
    // )

    return measure;
  }
}

class _DeviceInternal {
  late final BluetoothDevice device;
  late final BluetoothCharacteristic receiver;
  late final BluetoothCharacteristic transmitter;
  _DeviceInternal({
    required this.device,
    required this.receiver,
    required this.transmitter,
  });
}

abstract class _BluetoothFlags {
  static const String idle = 'TA SUAVE';
  static const String requesting = 'LEIAAAAAA';
  static const String waiting = 'TO ESPERANDO RESPOSTA';
  static const String received = 'RECEBIDOOOO';
}
