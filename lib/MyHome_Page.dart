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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
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
                await PortControl.openHdmi(1); // HDMI1 = 0
                await Future.delayed(Duration(seconds: 10));
                await PortControl.closeHdmi();
              },
              child: const Text('Open HDMI'),
            ),
            TextButton(onPressed: () async {}, child: const Text('Close HDMI')),
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

            // TextButton(
            //   onPressed: () async {
            //     await PortControl.setDelayPowerOn(1);
            //   },
            //   child: const Text('Set Delay Power On (10s)'),
            // ),
            TextButton(
              onPressed: () async {
                await PortControl.turnOff();
              },
              child: const Text('Turn Off'),
            ),
            // TextButton(
            //   onPressed: () async {
            //     final interactive = await PortControl.isInteractive();
            //     print('Is Interactive: $interactive');
            //   },
            //   child: const Text('Check Interactive'),
            // ),
            // TextButton(
            //   onPressed: () async {
            //     await PortControl.setPowerControlSleep();
            //   },
            //   child: const Text('Set Power Control Sleep'),
            // ),
            TextButton(
              onPressed: () async {
                await PortControl.setBackLight(30);
              },
              child: const Text('Set Backlight'),
            ),
            TextButton(
              onPressed: () async {
                final dir = await getExternalStorageDirectory();
                final filePath =
                    "${dir!.path}/Pictures/screen_cap_1.jpg"; // You can create subfolder like /Pictures
                final result = await PortControl.startScreenCap(filePath);
                print("Screen capture result: $result");
              },
              child: const Text('Start Screen Capture'),
            ),
            // TextButton(
            //   onPressed: () async {
            //     final filePath =
            //         "/storage/emulated/0/Android/data/com.example.flutter_port_app/files/Pictures/screen_cap.jpg";
            //     final result = await PortControl.startScreenCap(filePath);
            //     print("Screen capture result: $result");
            //   },
            //   child: const Text('Start Screen Capture'),
            // ),
          ],
        ),
      ),
    );
  }
}
