import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _counter = 0;
  String _logText = '';

  //bluetooth with the flutter_blue package

  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _txCharacteristic;

  @override
  void initState() {
    super.initState();
    _scanForDevices();
  }

  void _scanForDevices() {
    FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
    FlutterBlue.instance.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.name.contains('ESP32-S3')) { // Replace with your ESP32 name
          await FlutterBlue.instance.stopScan();
          await _connectToDevice(r.device);
        }
      }
    });
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    await device.connect();
    _connectedDevice = device;
    List<BluetoothService> services = await device.discoverServices();
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.uuid.toString() == 'YOUR_ESP32_TX_UUID') { // Replace with actual UUID
          _txCharacteristic = characteristic;
          characteristic.value.listen((value) {
            setState(() {
              _logText += String.fromCharCodes(value) + '\n';
            });
          });
        }
      }
    }
  }

void _incrementCounter() {
  setState((){
    _counter++;
  });
}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: _incrementCounter,
              child: Text('$_counter'),
            ),
          ),
        ),
      );
  }
}
