import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../models/role.dart';
import '../services/land_service.dart';
import '../widgets/step_progress.dart';

class MapScreen extends StatefulWidget {
  static const String routeName = '/map';
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  LatLng? _pinned;
  final TextEditingController _labelController = TextEditingController();
  final LandService _landService = LandService.instance;

  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(20.5937, 78.9629),
    zoom: 4.5,
  );

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Land Location'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Builder(builder: (context) {
            final role = context.read<AuthProvider>().currentUser?.role;
            if (role == UserRole.buyer) return const SizedBox.shrink();
            return const Padding(
              padding: EdgeInsets.all(12),
              child: StepProgress(currentStep: 3, totalSteps: 5, labels: ['Register', 'OTP', 'Map', 'Process', 'Result']),
            );
          }),
          Expanded(
            child: GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: (GoogleMapController controller) {
                _controller = controller;
                print('Google Maps initialized successfully');
              },
              onTap: (LatLng position) {
                setState(() {
                  _pinned = position;
                  print('Map tapped at: ${position.latitude}, ${position.longitude}');
                });
              },
              markers: {
                if (_pinned != null)
                  Marker(
                    markerId: const MarkerId('pin'),
                    position: _pinned!,
                    infoWindow: InfoWindow(
                      title: 'Selected Location',
                      snippet: '${_pinned!.latitude.toStringAsFixed(4)}, ${_pinned!.longitude.toStringAsFixed(4)}',
                    ),
                  ),
              },
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              myLocationEnabled: false,
              zoomControlsEnabled: true,
              compassEnabled: true,
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Land label/description',
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _pinned == null || user == null
                    ? null
                    : () async {
                        final label = _labelController.text.trim();
                        if (label.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a label')));
                          return;
                        }
                        final land = await _landService.submitLand(
                          label: label,
                          latitude: _pinned!.latitude,
                          longitude: _pinned!.longitude,
                          ownerUserId: user.id,
                        );
                        if (!mounted) return;
                        Navigator.of(context).pushNamed(
                          '/satellite-processing',
                          arguments: {
                            'lat': _pinned!.latitude,
                            'lng': _pinned!.longitude,
                            'label': label,
                            'landId': land.id,
                          },
                        );
                      },
                child: Text(_pinned == null
                    ? 'Tap map to drop a pin'
                    : 'Submit (${_pinned!.latitude.toStringAsFixed(5)}, ${_pinned!.longitude.toStringAsFixed(5)})'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


