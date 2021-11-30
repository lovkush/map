
import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  final Set<Marker> _markers = {};

  Completer<GoogleMapController> _controller = Completer();
   final Permission _permission = Permission.location;
  PermissionStatus _permissionStatus = PermissionStatus.denied;
  late Position position;
  CameraPosition _myLocation =
  CameraPosition(target: LatLng(0,0),zoom: 12);

  @override
  void initState() {
    super.initState();
    _listenForPermissionStatus();
    if (defaultTargetPlatform == TargetPlatform.android) {
      AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    }
   init();
  }
  LatLng currentLatlant = LatLng(0.0, 0.0) ;
  void init() async{
    _determinePosition().whenComplete(() =>     print('location1'));

  }





  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body:SizedBox(
                width: width,
                height: height/2,
                child: GoogleMap(
                  mapType: MapType.normal,
                  markers: _markers,
                  initialCameraPosition: _myLocation,
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed:
        () => {checkServiceStatus(
            context, _permission as PermissionWithService)},
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
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
    currentLatlant = LatLng(location.latitude,location.longitude);

    CameraUpdate update =CameraUpdate.newCameraPosition(CameraPosition(target: currentLatlant,zoom: 12));

     Marker markers = Marker(
      markerId: MarkerId('marker_id_1'),
      position: currentLatlant,

      infoWindow: InfoWindow(title: 'marker_id_1', snippet: '*'),
      onTap: () {
        //_onMarkerTapped(markerId);
        print('Marker Tapped');
      },
      onDragEnd: (LatLng position) {
        print('Drag Ended');
      },  );


     setState(() {
       _markers.add(markers);
     });

    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(update);

  }
}
