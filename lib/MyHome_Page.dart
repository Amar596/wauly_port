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


              // TextButton(
              //   onPressed: () async {
              //     await PortControl.setBackLight(100);
              //   },
              //   child: const Text('Set Backlight'),
              // ),
              // Padding(
              //   padding: const EdgeInsets.symmetric(vertical: 16.0),
              //   child: Column(
              //     children: [
              //       const Text('Set BackLight'),
              //       Wrap(
              //         spacing: 8.0,
              //         children:
              //             [25, 50, 75, 100].map((value) {
              //               return StatefulBuilder(
              //                 builder: (context, setState) {
              //                   return ElevatedButton(
              //                     onPressed: () async {
              //                       await PortControl.setBackLight(value);
              //                       setState(() {});
              //                       if (mounted) {
              //                         this.setState(() {
              //                           _currentBrightness = value;
              //                         });
              //                       }
              //                     },
              //                     style: ElevatedButton.styleFrom(
              //                       backgroundColor:
              //                           _currentBrightness == value
              //                               ? Theme.of(
              //                                 context,
              //                               ).colorScheme.primary
              //                               : Theme.of(
              //                                 context,
              //                               ).colorScheme.surface,
              //                       foregroundColor:
              //                           _currentBrightness == value
              //                               ? Theme.of(
              //                                 context,
              //                               ).colorScheme.onPrimary
              //                               : Theme.of(
              //                                 context,
              //                               ).colorScheme.onSurface,
              //                     ),
              //                     child: Text('$value%'),
              //                   );
              //                 },
              //               );
              //             }).toList(),
              //       ),
              //     ],
              //   ),
              // ),
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


// import 'package:external_app_launcher/external_app_launcher.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_port_app/Port_Control.dart';
// import 'package:path_provider/path_provider.dart';

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int? _hdmiStatus;
//   int? _currentVolume;
//   bool _hdmiMode = false;
//   int currentAngle = 0;
//   bool _isLoading = false;
//   int _currentBrightness = 50;

//   String? _macAddress;
//   String? _deviceId;
//   String? _serialNumber;
//   String? _clientType;
//   String? _appId;

//   @override
//   void initState() {
//     super.initState();
//     _loadCurrentBrightness();
//   }

//   Future<void> _loadCurrentBrightness() async {}

//   Widget _buildCompactButton(String text, VoidCallback onPressed) {
//     return TextButton(
//       onPressed: onPressed,
//       style: TextButton.styleFrom(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       ),
//       child: Text(text),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         title: Text(widget.title),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(8),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _buildCompactButton('Shutdown System', () async {
//                   await PortControl.shutDown();
//                 }),
//                 _buildCompactButton('Reboot System', () async {
//                   await PortControl.reboot();
//                 }),
//                 _buildCompactButton('Turn Off', () async {
//                   await PortControl.turnOff();
//                 }),
//               ],
//             ),

//             const SizedBox(height: 12),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _buildCompactButton('Open HDMI', () async {
//                   await PortControl.openHdmi(1);
//                   await Future.delayed(const Duration(seconds: 10));
//                   await PortControl.closeHdmi();
//                 }),
//                 _buildCompactButton('Close HDMI', () async {
//                   await PortControl.closeHdmi();
//                 }),
//                 _buildCompactButton('Get HDMI Status', () async {
//                   final status = await PortControl.getHdmiStatus(1);
//                   setState(() => _hdmiStatus = status);
//                 }),
//               ],
//             ),
//             if (_hdmiStatus != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4),
//                 child: Text('HDMI Status: $_hdmiStatus'),
//               ),

//             const SizedBox(height: 12),
//             const Text(
//               'Set BackLight',
//               style: TextStyle(fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 4),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8,
//               runSpacing: 8,
//               children:
//                   [25, 50, 75, 100].map((value) {
//                     return ElevatedButton(
//                       onPressed: () async {
//                         await PortControl.setBackLight(value);
//                         if (mounted) setState(() => _currentBrightness = value);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         backgroundColor:
//                             _currentBrightness == value
//                                 ? Theme.of(context).colorScheme.primary
//                                 : Theme.of(context).colorScheme.surface,
//                         foregroundColor:
//                             _currentBrightness == value
//                                 ? Theme.of(context).colorScheme.onPrimary
//                                 : Theme.of(context).colorScheme.onSurface,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                         side: BorderSide(
//                           color: Theme.of(context).colorScheme.outline,
//                           width: 1,
//                         ),
//                       ),
//                       child: Text('$value%'),
//                     );
//                   }).toList(),
//             ),

//             const SizedBox(height: 12),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _buildCompactButton('Rotate Screen', () async {
//                   const angles = [0, 90, 180, 270];
//                   setState(() {
//                     currentAngle =
//                         angles[(angles.indexOf(currentAngle) + 1) %
//                             angles.length];
//                   });
//                   await PortControl.setDisplayOrientation(currentAngle);
//                 }),
//                 _buildCompactButton('Screen Capture', () async {
//                   final dir = await getExternalStorageDirectory();
//                   final filePath = "${dir!.path}/Pictures/screen_cap_1.jpg";
//                   final result = await PortControl.startScreenCap(filePath);
//                   print("Screen capture result: $result");
//                 }),
//               ],
//             ),

//             const SizedBox(height: 12),
//             Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 _buildCompactButton('Get Volume', () async {
//                   final volume = await PortControl.getSystemVoice();
//                   setState(() => _currentVolume = volume);
//                 }),
//                 if (_currentVolume != null)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 4),
//                     child: Text('Current Volume: $_currentVolume'),
//                   ),
//                 Slider(
//                   value: (_currentVolume ?? 50).toDouble(),
//                   min: 0,
//                   max: 100,
//                   divisions: 10,
//                   onChanged: (value) async {
//                     await PortControl.setSystemVoice(value.toInt());
//                     setState(() => _currentVolume = value.toInt());
//                   },
//                 ),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     _buildCompactButton('Mute', () async {
//                       await PortControl.mute();
//                       setState(() => _currentVolume = 0);
//                     }),
//                     _buildCompactButton('Unmute', () async {
//                       await PortControl.unMute();
//                       final volume = await PortControl.getSystemVoice();
//                       setState(() => _currentVolume = volume);
//                     }),
//                   ],
//                 ),
//               ],
//             ),

//             const SizedBox(height: 12),
//             Wrap(
//               alignment: WrapAlignment.center,
//               spacing: 8,
//               runSpacing: 8,
//               children: [
//                 _buildCompactButton('Get MAC Address', () async {
//                   final mac = await PortControl.getMacAddress();
//                   setState(() => _macAddress = mac);
//                 }),
//                 _buildCompactButton('Get Device ID', () async {
//                   final id = await PortControl.getDeviceId();
//                   setState(() => _deviceId = id);
//                 }),
//                 _buildCompactButton('Get Serial No.', () async {
//                   try {
//                     final sn = await PortControl.getSN();
//                     setState(() => _serialNumber = sn ?? 'Not available');
//                   } catch (e) {
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       SnackBar(content: Text('Error: ${e.toString()}')),
//                     );
//                   }
//                 }),
//                 _buildCompactButton('Get Client Type', () async {
//                   final type = await PortControl.getClientType();
//                   setState(() => _clientType = type);
//                 }),
//                 _buildCompactButton('Get App ID', () async {
//                   final appId = await PortControl.getAppId();
//                   setState(() => _appId = appId);
//                 }),
//                 _buildCompactButton('Open App', () async {
//                   await LaunchApp.openApp(
//                     androidPackageName: "com.example.wauly_app",
//                   );
//                 }),
//               ],
//             ),

//             const SizedBox(height: 8),
//             if (_macAddress != null) Text('MAC: $_macAddress'),
//             if (_deviceId != null) Text('Device ID: $_deviceId'),
//             if (_serialNumber != null)
//               Text(
//                 'SN: $_serialNumber',
//                 style: TextStyle(
//                   color: _serialNumber == 'Not available' ? Colors.red : null,
//                 ),
//               ),
//             if (_clientType != null) Text('Client Type: $_clientType'),
//             if (_appId != null) Text('App ID: $_appId'),
//           ],
//         ),
//       ),
//     );
//   }
// }
