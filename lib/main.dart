import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'maps.dart';




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //runApp(MyApp());
  runApp(MaterialApp( home : const MyHomePage(title: 'location',)));
}
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';
  static const platform = MethodChannel('samples.flutter.dev/location');

  @override
  void initState() {
    super.initState();
    //BackgroundLocation.setAndroidConfiguration(1000);
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Location Service'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              locationData('Latitude: ' + latitude),
              locationData('Longitude: ' + longitude),
              locationData('Altitude: ' + altitude),
              locationData('Accuracy: ' + accuracy),
              locationData('Bearing: ' + bearing),
              locationData('Speed: ' + speed),
              locationData('Time: ' + time),
              ElevatedButton(
                  onPressed: () async {},
                  child: Text('Start Location Service')),
              ElevatedButton(
                  onPressed: () {
                  },
                  child: Text('Stop Location Service')),
              ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  child: Text('Get Current Location')),
              ElevatedButton(
                  onPressed: () {
                    startService();
                  },
                  child: Text('Start Location service')),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  void getCurrentLocation() {
    // BackgroundLocation().getCurrentLocation().then((location) {
    //   print('This is current Location ' + location.toMap().toString());
    // });
  }

  @override
  void dispose() {
    // BackgroundLocation.stopLocationService();
    super.dispose();
  }

  Future<void> startService() async {
    String location;
    try {
      final int result = await platform.invokeMethod('startLocation',{'path':'driverId'});
      location = 'location at $result % .';
    } on PlatformException catch (e) {
      location = "Failed to get location: '${e.message}'.";
    }
    print(location);

  }
}