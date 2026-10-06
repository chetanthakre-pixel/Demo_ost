import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../providers/community_map_provider.dart';
import '../../core/theme.dart';
import '../../models/enums.dart';

class CommunityMapScreen extends ConsumerWidget {
  const CommunityMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsyncValue = ref.watch(communityMapProvider);

    // Color inversion for OSM Dark mode
    const ColorFilter invertMatrix = ColorFilter.matrix(<double>[
      -0.2126, -0.7152, -0.0722, 0, 255, // Red
      -0.2126, -0.7152, -0.0722, 0, 255, // Green
      -0.2126, -0.7152, -0.0722, 0, 255, // Blue
      0,       0,       0,       1, 0,   // Alpha
    ]);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          reportsAsyncValue.when(
            loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 1.5)),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (reports) {
              // Default to NYC or center on the first report
              LatLng initialCenter = const LatLng(40.7128, -74.0060);
              if (reports.isNotEmpty) {
                initialCenter = LatLng(reports.first.latitude, reports.first.longitude);
              }

              return FlutterMap(
                options: MapOptions(
                  initialCenter: initialCenter,
                  initialZoom: 13.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  ColorFiltered(
                    colorFilter: invertMatrix,
                    child: TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'app.tomorrow.citizen_reporter',
                      retinaMode: MediaQuery.of(context).devicePixelRatio > 1.0,
                    ),
                  ),
                  MarkerLayer(
                    markers: reports.map((report) {
                      return Marker(
                        point: LatLng(report.latitude, report.longitude),
                        width: 40,
                        height: 40,
                        child: GestureDetector(
                          onTap: () {
                            context.push('/report/${report.reportId}');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: report.status.value == 'resolved' ? AppTheme.statusResolved : AppTheme.accent,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.background, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _getIconForCategory(report.category),
                              color: Colors.black,
                              size: 20,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          ),
          
          // Header overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background.withAlpha(200),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Text(
                'CITY MAP',
                style: TextStyle(
                  fontFamily: 'Michroma',
                  fontSize: 24,
                  color: AppTheme.text,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(Category category) {
    switch (category) {
      case Category.pothole:
      case Category.damagedRoad:
      case Category.damagedConcrete:
        return Icons.add_road;
      case Category.electricHazard:
        return Icons.lightbulb_outline;
      case Category.fallenTree:
        return Icons.nature;
      case Category.garbage:
        return Icons.delete_outline;
      case Category.vandalism:
        return Icons.format_paint;
      default:
        return Icons.warning_amber_rounded;
    }
  }
}
