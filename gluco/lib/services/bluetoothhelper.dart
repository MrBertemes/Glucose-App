import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:gluco/models/device.dart';
import 'package:gluco/models/measurement.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BluetoothHelper {
  BluetoothHelper._privateConstructor();

  static final BluetoothHelper instance = BluetoothHelper._privateConstructor();

  final FlutterBlue _bluetooth = FlutterBlue.instance;

  /// Stream com sinais de alteração no estado do Bluetooth ligado/desligado
  Stream<bool> get state => _state.asBroadcastStream();

  /// Stream que encapsula e transmite os sinais de estado do FlutterBlue
  Stream<bool> get _state async* {
    await for (final value in _bluetooth.state) {
      bool available = value == BluetoothState.on ? true : false;
      if (!available) {
        _connectedDevice = null;
        _devices.clear();
      }
      yield available;
    }
  }

  /// Stream com sinais de iniciando/parando escaneamento
  Stream<bool> get scanning => _scanning.asBroadcastStream();

  /// Stream que encapsula e transmite os sinais de escaneamento do FlutterBlue
  Stream<bool> get _scanning async* {
    await for (final value in _bluetooth.isScanning) {
      yield value;
    }
  }

  // Dispositivo atualmente conectado, é o que é efetivamente utilizado na coleta
  BluetoothDevice? _connectedDevice;

  /// Stream com sinais de conectado/desconectado do dispositivo atualmente conectado
  Stream<bool> get connected => _connected.stream;

  final StreamController<bool> _connected = StreamController<bool>.broadcast();

  /// Inicia a transmissão do estado de conexão do dispositivo continuamente
  /// até que seja desconectado
  void _transmit() async {
    try {
      await for (final value in _connectedDevice!.state) {
        bool connected = value == BluetoothDeviceState.connected ? true : false;
        // nao sei se ta certo fazer isso, mas funciona
        Timer.periodic(
          const Duration(milliseconds: 100),
          (timer) {
            _connected.add(connected);
            if (_connectedDevice == null) {
              timer.cancel();
            }
          },
        );
        if (!connected) {
          // talvez tentar reconectar?
          // cuidar pra nao conectar novamente quando quiser desconectar
          _connectedDevice = null;
        }
      }
    } catch (e) {
      _connected.add(false);
    }
  }

  /// Lista de dispositivos encontrados pelo escaneamento
  final List<BluetoothDevice> _devices = [];

  /// Mapeamento dos BluetoothDevices para Devices com inclusão do
  /// dispositivo atualmente conectado
  List<Device> get devices {
    List<Device> dvcs =
        _devices.map((d) => Device(id: d.id.id, name: d.name)).toList();
    if (_connectedDevice != null) {
      try {
        dvcs.firstWhere((d) => d.id == _connectedDevice!.id.id).connected =
            true;
      } on StateError {
        dvcs.insert(
            0,
            Device(
                id: _connectedDevice!.id.id,
                name: _connectedDevice!.name,
                connected: true));
      }
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
            _devices.add(r.device);
            print("--- nome: ${r.device.name} id: ${r.device.id.id}");
          }
        }
      },
    );
    await _bluetooth.stopScan();
  }

  /// Tenta estabelecer conexão com um dispositivo, pode falhar por timeout,
  /// se bem sucedido _connectedDevice é atualizado e a transmissão
  /// da stream de conexão é iniciada
  Future<bool> connect(Device dvc) async {
    bool status = true;
    try {
      BluetoothDevice device = _devices.firstWhere((d) => d.id.id == dvc.id);
      // se deixar true e conectar novamente sozinho depois de setar
      // o _connectedDevice como nulo, ele não vai ser atualizado
      await device
          .connect(autoConnect: false)
          .timeout(const Duration(seconds: 5), onTimeout: () {
        status = false;
        device.disconnect();
      }).whenComplete(() async {
        if (status) {
          await SharedPreferences.getInstance().then((sp) async {
            await sp.setString('egble', device.id.id);
          });
          _connectedDevice = device;
          _transmit();
        }
      });
    } catch (e) {
      status = false;
    }
    print('Status Conexão: $status');
    return status;
  }

  /// Encapsula a função de desconectar do FlutterBlue
  Future<bool> disconnect() async {
    try {
      await _connectedDevice!.disconnect();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Busca por um dispositivo previamente conectado no SharedPreferences
  /// para tentar reconectar ao iniciar o aplicativo
  Future<bool> autoConnect() async {
    String? deviceId;
    Device dvc = Device(id: '', name: '');
    await SharedPreferences.getInstance().then((sp) {
      if (sp.containsKey('egble')) {
        deviceId = sp.getString('egble');
        print('ID no SharedPreferences: $deviceId');
      }
    });
    if (deviceId != null) {
      await scan();
      dvc.id = deviceId!;
    }
    return await connect(dvc);
  }

  /// Faz a leitura dos dados da medição do dispositivo conectado
  // Future<MeasurementCollected> collect() async {
  Future<Map<String, String>> collect() async {
    assert(_connectedDevice != null);
    //
    Map<String, String> measure = {};
    //
    List<BluetoothService> services =
        await _connectedDevice!.discoverServices();
    // Busca pelos descritores das características uma que corresponda
    // com RXD Port e salva o dado lido da característica no mapa
    for (BluetoothService s in services) {
      List<BluetoothCharacteristic> characteristics = s.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        List<BluetoothDescriptor> descriptors = c.descriptors;
        for (BluetoothDescriptor d in descriptors) {
          List<int> hex = await d.read();
          String value = utf8.decode(hex);
          if (value == 'RXD Port') {
            hex = await c.read();
            value = utf8.decode(hex);
            measure[c.uuid.toString()] = value;
          }
        }
      }
    }

    ////////////////////////////////////////////////////////////
    // Random random = Random();
    // List<double> m_4p = <double>[];
    // List<double> f_4p = <double>[];
    // for (int i = 1; i <= 24; i++) {
    //   m_4p.add((random.nextDouble() * 10000).truncateToDouble() / 1000 + 5);
    //   f_4p.add((random.nextDouble() * 10000).truncateToDouble() / 1000 + 5);
    // }
    // MeasurementCollected measure = MeasurementCollected(
    //   id: -1,
    //   apparent_glucose:
    //       (((random.nextInt(110) + 60) + random.nextDouble()) * 100)
    //               .truncateToDouble() /
    //           100,
    //   spo2: random.nextInt(101) + 96,
    //   pr_rpm: random.nextInt(110) + 60,
    //   temperature: (((random.nextInt(38) + 35) + random.nextDouble()) * 100)
    //           .truncateToDouble() /
    //       100,
    //   m_4p: m_4p,
    //   f_4p: f_4p,
    //   date: DateTime.now(),
    // );
    ////////////////////////////////////////////////////////////
    return measure;
  }
}
