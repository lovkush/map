
// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {


  final Completer<GoogleMapController> _controller = Completer();
   final Permission _permission = Permission.location;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  late Position position;
  final CameraPosition _myLocation = const CameraPosition(target: LatLng(0,0),zoom: 12);
  static const platform = MethodChannel('samples.flutter.dev/location');
  final DatabaseReference ref = FirebaseDatabase.instance.reference();
  late StreamSubscription<Event> _locationEvent;
  List<LatLng> coordinatesList =[];

  late BitmapDescriptor customIcon;



  LatLng currentLatLong = LatLng(0.0, 0.0) ;
  final MarkerId markerId =  MarkerId('markerId');
  final Set<Marker> _markers = {};
  late Marker marker;
  late Polyline polyline;
  @override
  void initState() {
    super.initState();
    // make sure to initialize before map loading
    BitmapDescriptor.fromAssetImage(ImageConfiguration(size: Size(12, 12)),
        'assets/msp.png')
        .then((d) {
      customIcon = d;
      initializeMarker();
    });

    _listenForPermissionStatus();
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
    getLocationFromFirebase();
   init();
  }


  void init() async{
    _determinePosition().whenComplete(() =>     print('location1'));

  }





  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return  Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body:SizedBox(
                    width: width,
                    height: height / 2,
                    child: GoogleMap(
                      mapType: MapType.normal,
                      markers: _markers,
                      polylines: Set<Polyline>.of(_mapPolylines.values),
                      initialCameraPosition: _myLocation,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                  ),
        floatingActionButton: FloatingActionButton(
          onPressed:
          () => {startService()},
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }


  @override
  void dispose() {
    _locationEvent.cancel();

    super.dispose();
  }

  void checkServiceStatus(
      BuildContext context, PermissionWithService permission) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text((await permission.serviceStatus).toString()),
    ));
  }

  void _listenForPermissionStatus() async {
    final status = await _permission.status;
    setState(() => _permissionStatus = status);
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      print(status);
      _permissionStatus = status;
      print(_permissionStatus);
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      requestPermission(_permission);
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        requestPermission(_permission);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    print('location');
    Position location = await Geolocator.getCurrentPosition().whenComplete(() => print('1sdfg'));
    print('2sdfg ${location.latitude}');
    currentLatLong = LatLng(location.latitude,location.longitude);

    CameraUpdate update =CameraUpdate.newCameraPosition(CameraPosition(target: currentLatLong,zoom: 12));

    _markers.remove(marker);
      marker = marker.copyWith(positionParam: currentLatLong);


     setState(() {
       _markers.add(marker);
     });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(update);

  }




  Map<PolylineId, Polyline> _mapPolylines = {};
  final PolylineId polylineId = PolylineId('polyline_id');

  void _add() {
     polyline = polyline.copyWith(pointsParam: coordinatesList);
    setState(() {
      _mapPolylines[polylineId] = polyline;
    });
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

  void initializeMarker() {
    marker = Marker(
      markerId: markerId,
      position: currentLatLong,
    // icon: customIcon
    );

    polyline = Polyline(
      polylineId: polylineId,
      consumeTapEvents: true,
      color: Colors.red,
      width: 5,
      points:  const [LatLng(0.0, 0.0)],
    );

  }

  void getLocationFromFirebase() {
    _locationEvent = FirebaseDatabase.instance.reference().child('driverId').onValue.listen((event) {
      double lat = 0.0;
      double long = 0.0;
      Map<dynamic, dynamic> values = event.snapshot.value;
      print('values : $values');
      lat =  values['lat'];
      long = values['long'];

      currentLatLong = LatLng(lat, long);
      coordinatesList.add(currentLatLong);
      _add();
      _markers.remove(marker);
      marker = marker.copyWith(
        positionParam: currentLatLong
      );
      setState(() {
        _markers.add(marker);
      });
    });
  }
}
