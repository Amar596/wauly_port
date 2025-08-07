import 'package:flutter/services.dart';

class PortControl {
  static const MethodChannel _channel = MethodChannel('port_control');

  static Future<void> openHdmi(int index) async {
    await _channel.invokeMethod('openHDMI', {'index': index});
  }

  static Future<void> closeHdmi() async {
    await _channel.invokeMethod('closeHDMI');
  }

  static Future<int?> getHdmiStatus(int index) async {
    final result = await _channel.invokeMethod<int>('getHDMIStatus', {
      'index': index,
    });
    return result;
  }

  static Future<void> shutDown() async {
    await _channel.invokeMethod('shutdownSystem');
  }

  static Future<void> setDelayPowerOn(int mins) async =>
      _channel.invokeMethod('setDelayPowerOn', {'mins': mins});

  static Future<void> turnOff() async => _channel.invokeMethod('turnOff');

  static Future<bool?> isInteractive() async =>
      _channel.invokeMethod<bool>('isInteractive');

  static Future<void> setPowerControlSleep() async =>
      _channel.invokeMethod('setPowerControlSleep');

  static Future<void> setBackLight(int value) async {
    await _channel.invokeMethod('setBackLight', {'value': value});
  }

  static Future<int?> startScreenCap(String fileName) async {
    final result = await _channel.invokeMethod<int>('startScreenCap', {
      'fileName': fileName,
    });
    return result;
  }
}
