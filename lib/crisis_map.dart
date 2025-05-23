import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class CrisisMapScreen extends StatefulWidget {
  const CrisisMapScreen({super.key});

  @override
  State<CrisisMapScreen> createState() => _CrisisMapScreenState();
}

class _CrisisMapScreenState extends State<CrisisMapScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initMapLogic();
  }

  Future<void> _initMapLogic() async {
    await _checkLocationPermission();
    await _loadCrisisCenters();
  }

  Future<void> _checkLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;

    if (!status.isGranted) {
      status = await Permission.locationWhenInUse.request();
    }

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
      } catch (e) {
        print("⚠️ Геолокация недоступна, используем дефолтную точку");
        _useDefaultLocation();
      }
    } else if (status.isPermanentlyDenied) {
      // _showPermissionDialog();
      _useDefaultLocation();
    } else {
      _useDefaultLocation();
    }
  }

  void _useDefaultLocation() {
    setState(() {
      _currentPosition = const LatLng(51.128, 71.430); // Астана
    });
  }

  Future<void> _loadCrisisCenters() async {
    List<Map<String, dynamic>> crisisCenters = [
      {"lat": 51.125, "lng": 71.443, "name": "Центр №1"},
      {"lat": 51.132, "lng": 71.445, "name": "Центр №2"},
    ];

    Set<Marker> loadedMarkers = crisisCenters.map((center) {
      return Marker(
        markerId: MarkerId(center["name"]),
        position: LatLng(center["lat"], center["lng"]),
        infoWindow: InfoWindow(title: center["name"]),
      );
    }).toSet();

    setState(() {
      _markers = loadedMarkers;
    });
  }

  void _goToMyLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final LatLng currentLatLng =
          LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 14),
      );
    } catch (e) {
      print("⚠️ Не удалось перейти к текущей позиции");
    }
  }

  // void _showPermissionDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: const Text("Геолокация отключена"),
  //       content: const Text(
  //           "Чтобы отображать ваше местоположение на карте, разрешите доступ в настройках."),
  //       actions: [
  //         TextButton(
  //           onPressed: () => Navigator.of(ctx).pop(),
  //           child: const Text("Отмена"),
  //         ),
  //         ElevatedButton(
  //           onPressed: () {
  //             openAppSettings(); // Открывает системные настройки
  //             Navigator.of(ctx).pop();
  //           },
  //           child: const Text("Открыть настройки"),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Карта кризисных центров")),
      body: _currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentPosition!,
                zoom: 13,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              markers: _markers,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToMyLocation,
        backgroundColor: Colors.green,
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
