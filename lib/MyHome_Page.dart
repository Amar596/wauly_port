import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_port_app/Port_Control.dart';
import 'package:path_provider/path_provider.dart';

class MyHomePage extends StatefulWidget { 
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int? _hdmiStatus;
  int? _currentVolume;
  bool _hdmiMode = false;
  int currentAngle = 0;
  bool _isLoading = false;
  int _currentBrightness = 50;

  String? _macAddress;
  String? _deviceId;
  String? _serialNumber;
  String? _clientType;
  String? _appId;

  @override
  void initState() {
    super.initState();
    _loadCurrentBrightness();
  }

  Future<void> _loadCurrentBrightness() async {
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  await PortControl.shutDown();
                },
                child: const Text('Shutdown System'),
              ),
              TextButton(
                onPressed: () async {
                  await PortControl.openHdmi(1);
                  await Future.delayed(const Duration(seconds: 10));
                  await PortControl.closeHdmi();
                },
                child: const Text('Open HDMI'),
              ),
              TextButton(
                onPressed: () async {
                  await PortControl.closeHdmi();
                },
                child: const Text('Close HDMI'),
              ),
              TextButton(
                onPressed: () async {
                  final status = await PortControl.getHdmiStatus(1);
                  setState(() {
                    _hdmiStatus = status;
                  });
                },
                child: const Text('Get HDMI Status'),
              ),
              if (_hdmiStatus != null) Text('HDMI Status: $_hdmiStatus'),
              TextButton(
                onPressed: () async {
                  await PortControl.turnOff();
                },
                child: const Text('Turn Off'),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    const Text(
                      'Set BackLight',
                      style: TextStyle(
                        // fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children:
                          [25, 50, 75, 100].map((value) {
                            return ElevatedButton(
                              onPressed: () async {
                                await PortControl.setBackLight(value);
                                if (mounted) {
                                  setState(() {
                                    _currentBrightness = value;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                                side: BorderSide(
                                  color: Theme.of(context).colorScheme.outline,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                '$value%',
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  final dir = await getExternalStorageDirectory();
                  final filePath = "${dir!.path}/Pictures/screen_cap_1.jpg";
                  final result = await PortControl.startScreenCap(filePath);
                  print("Screen capture result: $result");
                },
                child: const Text('Start Screen Capture'),
              ),
              TextButton(
                onPressed: () async {
                  const angles = [0, 90, 180, 270];
                  setState(() {
                    currentAngle =
                        angles[(angles.indexOf(currentAngle) + 1) %
                            angles.length];
                  });
                  await PortControl.setDisplayOrientation(currentAngle);
                },
                child: const Text('Rotate Screen'),
              ),
              Column(
                children: [
                  TextButton(
                    onPressed: () async {
                      final volume = await PortControl.getSystemVoice();
                      setState(() {
                        _currentVolume = volume;
                      });
                    },
                    child: const Text('Get Volume'),
                  ),
                  if (_currentVolume != null)
                    Text('Current Volume: $_currentVolume'),
                  Slider(
                    value: (_currentVolume ?? 50).toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 10,
                    onChanged: (value) async {
                      await PortControl.setSystemVoice(value.toInt());
                      setState(() {
                        _currentVolume = value.toInt();
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () async {
                          await PortControl.mute();
                          setState(() {
                            _currentVolume = 0;
                          });
                        },
                        child: const Text('Mute'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await PortControl.unMute();
                          final volume = await PortControl.getSystemVoice();
                          setState(() {
                            _currentVolume = volume;
                          });
                        },
                        child: const Text('Unmute'),
                      ),
                    ],
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () async {
                            await PortControl.reboot();
                          },
                          child: const Text('Reboot System'),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () async {
                  final mac = await PortControl.getMacAddress();
                  setState(() => _macAddress = mac);
                },
                child: const Text('Get MAC Address'),
              ),
              if (_macAddress != null) Text('MAC: $_macAddress'),

              TextButton(
                onPressed: () async {
                  final id = await PortControl.getDeviceId();
                  setState(() => _deviceId = id);
                },
                child: const Text('Get Device ID'),
              ),
              if (_deviceId != null) Text('Device ID: $_deviceId'),

              TextButton(
                onPressed: () async {
                  try {
                    final sn = await PortControl.getSN();
                    if (sn == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to get serial number'),
                        ),
                      );
                    }
                    setState(() => _serialNumber = sn ?? 'Not available');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                },
                child: const Text('Get Serial Number'),
              ),
              if (_serialNumber != null)
                Text(
                  'SN: $_serialNumber',
                  style: TextStyle(
                    color:
                        _serialNumber == 'Not available'
                            ? Colors.red
                            : Colors.black,
                  ),
                ),

              TextButton(
                onPressed: () async {
                  final type = await PortControl.getClientType();
                  setState(() => _clientType = type);
                },
                child: const Text('Get Client Type'),
              ),
              if (_clientType != null) Text('Client Type: $_clientType'),

              TextButton(
                onPressed: () async {
                  final appId = await PortControl.getAppId();
                  setState(() => _appId = appId);
                },
                child: const Text('Get App ID'),
              ),
              if (_appId != null) Text('App ID: $_appId'),

              TextButton(
                onPressed: () async {
                  // final value = await LaunchApp.isAppInstalled(
                  //   androidPackageName: "com.example.wauly_app",
                  // );
                  await LaunchApp.openApp(
                    androidPackageName: "com.example.wauly_app",
                  );
                  // print(value);
                },
                child: const Text('Open Another App'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}