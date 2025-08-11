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

   static Future<bool?> getHdmiMode() async {
    return await _channel.invokeMethod<bool>('getHDMIMode');
  }

  static Future<bool> setHdmiMode(bool status) async {
    try {
      final result = await _channel.invokeMethod<bool>('setHdmiMode', {
        'status': status,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to set HDMI mode: ${e.message}');
      return false;
    }
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

  static Future<void> setDisplayOrientation(int angle) async {
    await _channel.invokeMethod('setDisplayOrientation', {'angle': angle});
  }

  static Future<int?> getSystemVoice() async {
    return await _channel.invokeMethod<int>('getSystemVoice');
  }

  static Future<void> setSystemVoice(int voice) async {
    await _channel.invokeMethod('setSystemVoice', {'voice': voice});
  }

  static Future<void> mute() async {
    await _channel.invokeMethod('mute');
  }

  static Future<void> unMute() async {
    await _channel.invokeMethod('unMute');
  }

  static Future<void> reboot() async {
    try {
      await _channel.invokeMethod('reboot');
    } on PlatformException catch (e) {
      print('Failed to reboot: ${e.message}');
      rethrow;
    }
  }

  static Future<bool> setSystemAutoReboot({
    required int status,
    required String time,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('setSystemAutoReboot', {
        'status': status,
        'time': time,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to set auto reboot: ${e.message}');
      return false;
    }
  }
}
