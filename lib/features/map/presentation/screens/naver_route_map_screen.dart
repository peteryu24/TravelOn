import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:travel_on_final/features/map/domain/entities/travel_point.dart';

class NaverRouteMapScreen extends StatefulWidget {
  final List<TravelPoint> points;

  const NaverRouteMapScreen({Key? key, required this.points}) : super(key: key);

  @override
  State<NaverRouteMapScreen> createState() => _NaverRouteMapScreenState();
}

class _NaverRouteMapScreenState extends State<NaverRouteMapScreen> {
  NaverMapController? _mapController;
  String totalDistance = '';
  String totalDuration = '';
  final Map<String, NPathOverlay> _pathOverlays = {}; // 경로 오버레이 관리용 맵

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_mapController != null) {
        _createRoute(_mapController!);
      }
    });
  }

  String _formatDuration(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;

    if (hours > 0) {
      return '$hours시간 ${minutes}분';
    } else {
      return '$minutes분';
    }
  }

  String _formatDistance(int meters) {
    if (meters >= 1000) {
      double kilometers = meters / 1000;
      return '${kilometers.toStringAsFixed(1)}km';
    } else {
      return '${meters}m';
    }
  }

  Future<void> _createRoute(NaverMapController controller) async {
    if (widget.points.length < 2) return;

    try {
      // 기존 경로 제거
      for (var overlay in _pathOverlays.values) {
        await controller.deleteOverlay(overlay as NOverlayInfo);
      }
      _pathOverlays.clear();

      int totalDistanceMeters = 0;
      int totalDurationSeconds = 0;

      for (var i = 0; i < widget.points.length - 1; i++) {
        final start = widget.points[i];
        final end = widget.points[i + 1];

        final uri = Uri.parse('https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving')
            .replace(queryParameters: {
          'start': '${start.location.longitude},${start.location.latitude}',
          'goal': '${end.location.longitude},${end.location.latitude}',
          'option': 'trafast',
        });

        final response = await http.get(
          uri,
          headers: {
            'X-NCP-APIGW-API-KEY-ID': 'j3gnaneqmd',
            'X-NCP-APIGW-API-KEY': 'WdWzIfcchu614fM1CD1vKA9JzaJATTj0DGKM5CPF',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['route']?['trafast']?[0]?['path'] != null) {
            final path = data['route']['trafast'][0]['path'] as List;
            final coords = path.map((point) => NLatLng(
              (point[1] as num).toDouble(),
              (point[0] as num).toDouble(),
            )).toList();

            final pathOverlay = NPathOverlay(
              id: 'path_$i',
              coords: coords,
              color: Colors.blue.withOpacity(0.8),
              width: 5,
              outlineColor: Colors.white,
              patternInterval: 80,
            );

            _pathOverlays['path_$i'] = pathOverlay;
            await controller.addOverlay(pathOverlay);

            // 거리와 시간 정보 누적
            final summary = data['route']['trafast'][0]['summary'];
            totalDistanceMeters += summary['distance'] as int;
            totalDurationSeconds += summary['duration'] as int;

            setState(() {
              totalDistance = _formatDistance(totalDistanceMeters);
              totalDuration = _formatDuration(totalDurationSeconds);
            });
          }
        } else {
          throw Exception('Failed to load route: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error in _createRoute: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('경로 생성 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  NLatLngBounds _calculateBounds(List<TravelPoint> points) {
    if (points.isEmpty) {
      return NLatLngBounds(
        southWest: NLatLng(37.4517, 126.8707),
        northEast: NLatLng(37.7019, 127.1842),
      );
    }

    double minLat = points[0].location.latitude;
    double maxLat = points[0].location.latitude;
    double minLng = points[0].location.longitude;
    double maxLng = points[0].location.longitude;

    for (var point in points) {
      if (point.location.latitude < minLat) minLat = point.location.latitude;
      if (point.location.latitude > maxLat) maxLat = point.location.latitude;
      if (point.location.longitude < minLng) minLng = point.location.longitude;
      if (point.location.longitude > maxLng) maxLng = point.location.longitude;
    }

    return NLatLngBounds(
      southWest: NLatLng(minLat, minLng),
      northEast: NLatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 코스'),
      ),
      body: Stack(
        children: [
          NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: widget.points.isNotEmpty
                    ? widget.points.first.location
                    : const NLatLng(37.5666102, 126.9783881),
                zoom: 12,
              ),
              contentPadding: EdgeInsets.zero,
            ),
            onMapReady: (NaverMapController controller) {
              setState(() {
                _mapController = controller;
              });

              for (var i = 0; i < widget.points.length; i++) {
                final point = widget.points[i];
                final marker = NMarker(
                  id: 'marker_${point.id}',
                  position: point.location,
                );

                marker.setCaption(
                  NOverlayCaption(
                    text: '${i + 1}. ${point.name}',
                    textSize: 14,
                    color: Colors.blue,
                    haloColor: Colors.white,
                  ),
                );

                controller.addOverlay(marker);
              }

              if (widget.points.length > 1) {
                _createRoute(controller);
              }

              if (widget.points.isNotEmpty) {
                final bounds = _calculateBounds(widget.points);
                controller.updateCamera(
                  NCameraUpdate.fitBounds(
                    bounds,
                    padding: const EdgeInsets.all(50),
                  ),
                );
              }
            },
          ),
          if (totalDistance.isNotEmpty || totalDuration.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (totalDistance.isNotEmpty)
                        Text(
                          '총 이동 거리: $totalDistance',
                          style: const TextStyle(fontSize: 16),
                        ),
                      if (totalDuration.isNotEmpty)
                        Text(
                          '예상 소요 시간: $totalDuration',
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // 모든 오버레이 제거
    if (_mapController != null) {
      for (var overlay in _pathOverlays.values) {
        _mapController!.deleteOverlay(overlay as NOverlayInfo);
      }
    }
    _mapController?.dispose();
    super.dispose();
  }
}