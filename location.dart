import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _currentPosition;
  Marker? _currentMarker;

  // Default camera position (for example, India)
  static const CameraPosition _initialCamera = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 4,
  );

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location services are disabled.")),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied.")),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permissions permanently denied.")),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng userLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = userLatLng;
        _currentMarker = Marker(
          markerId: const MarkerId("me"),
          position: userLatLng,
          infoWindow: const InfoWindow(title: "You are here!"),
        );
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 15));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error getting location: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View My Location"),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialCamera,
            myLocationEnabled: _currentPosition != null,
            myLocationButtonEnabled: false, // we'll use our own button
            markers: _currentMarker != null ? {_currentMarker!} : {},
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),

          // 🟢 Floating button to get current location
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              backgroundColor: Colors.green,
              icon: const Icon(Icons.my_location),
              label: const Text("My Location"),
              onPressed: _getCurrentLocation,
            ),
          ),
        ],
      ),
    );
  }
}
