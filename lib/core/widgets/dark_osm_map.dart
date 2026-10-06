import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../theme.dart';

class DarkOsmMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final double height;

  const DarkOsmMap({
    super.key,
    required this.latitude,
    required this.longitude,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    // A matrix that converts colors to grayscale and then inverts them,
    // resulting in a dark theme effect.
    const ColorFilter invertMatrix = ColorFilter.matrix(<double>[
      -0.2126, -0.7152, -0.0722, 0, 255, // Red
      -0.2126, -0.7152, -0.0722, 0, 255, // Green
      -0.2126, -0.7152, -0.0722, 0, 255, // Blue
      0,       0,       0,       1, 0,   // Alpha
    ]);

    final center = LatLng(latitude, longitude);

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.hairline, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: FlutterMap(
        options: MapOptions(
          initialCenter: center,
          initialZoom: 15.0,
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          ColorFiltered(
            colorFilter: invertMatrix,
            child: TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              // Use a custom string to bypass OSM generic app blocking
              userAgentPackageName: 'app.tomorrow.citizen_reporter',
              retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
            ),
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_on,
                  color: AppTheme.accent,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
