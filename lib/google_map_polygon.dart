import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class GoogleMapPolygon extends StatefulWidget {
  const GoogleMapPolygon({super.key});

  @override
  State<GoogleMapPolygon> createState() => _GoogleMapPolygonState();
}

class _GoogleMapPolygonState extends State<GoogleMapPolygon> {
  LatLng myCurrentLocation = const LatLng(37.33233141, -122.0312186);
  final Completer<GoogleMapController> _completer = Completer();
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      myCurrentLocation = LatLng(position.latitude, position.longitude);
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: myCurrentLocation,
          infoWindow: InfoWindow(
            title: 'Current Location',
          ),
          icon: BitmapDescriptor.defaultMarker,
        ),
      );
    });

    final GoogleMapController controller = await _completer.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(myCurrentLocation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      myLocationButtonEnabled: false,
      markers: markers,
      initialCameraPosition: CameraPosition(
        target: myCurrentLocation,
        zoom: 14,
      ),
      onMapCreated: (GoogleMapController controller) {
        _completer.complete(controller);
      },
    );
  }
}
