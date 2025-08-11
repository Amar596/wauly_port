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
              TextButton(
                onPressed: () async {
                  await PortControl.setBackLight(30);
                },
                child: const Text('Set Backlight'),
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
                  // Updated HDMI Mode Controls
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(vertical: 16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.center,
                  //     children: [
                  //       const Text('HDMI Mode: '),
                  //       Switch(
                  //         value: _hdmiMode,
                  //         onChanged:
                  //             _isLoading
                  //                 ? null
                  //                 : (value) async {
                  //                   setState(() => _isLoading = true);
                  //                   try {
                  //                     final success =
                  //                         await PortControl.setHdmiMode(value);
                  //                     if (success) {
                  //                       setState(() => _hdmiMode = value);
                  //                     } else {
                  //                       ScaffoldMessenger.of(
                  //                         context,
                  //                       ).showSnackBar(
                  //                         const SnackBar(
                  //                           content: Text(
                  //                             'Failed to set HDMI mode',
                  //                           ),
                  //                           duration: Duration(seconds: 2),
                  //                         ),
                  //                       );
                  //                     }
                  //                   } finally {
                  //                     if (mounted)
                  //                       setState(() => _isLoading = false);
                  //                   }
                  //                 },
                  //       ),
                  //       Text(_hdmiMode ? 'Enabled' : 'Disabled'),
                  //     ],
                  //   ),
                  // ),
                  // TextButton(
                  //   onPressed:
                  //       _isLoading
                  //           ? null
                  //           : () async {
                  //             setState(() => _isLoading = true);
                  //             try {
                  //               final mode = await PortControl.getHdmiMode();
                  //               if (mode != null && mounted) {
                  //                 setState(() => _hdmiMode = mode);
                  //               }
                  //             } finally {
                  //               if (mounted) setState(() => _isLoading = false);
                  //             }
                  //           },
                  //   child: const Text('Refresh HDMI Mode'),
                  // ),

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
                        //const Text('Auto Reboot Settings'),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     DropdownButton<int>(
                        //       value: 0,
                        //       items: const [
                        //         DropdownMenuItem(
                        //           value: 0,
                        //           child: Text('Disabled'),
                        //         ),
                        //         DropdownMenuItem(
                        //           value: 1,
                        //           child: Text('Enabled'),
                        //         ),
                        //       ],
                        //       onChanged: (value) async {
                        //         final time = '06:00'; // Default time
                        //         if (value != null) {
                        //           await PortControl.setSystemAutoReboot(
                        //             status: value,
                        //             time: time,
                        //           );
                        //         }
                        //       },
                        //     ),
                        //     const SizedBox(width: 16),
                        //     // You could add a time picker here for more precise control
                        //   ],
                        // ),
                      ],
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  } 
}
