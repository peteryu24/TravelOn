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
  final List<NMarker> markers = [];
  final List<NPathOverlay> paths = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _createMarkers();
      _createRoute();
    });
  }

  void _createMarkers() {
    for (var i = 0; i < widget.points.length; i++) {
      final point = widget.points[i];
      final marker = NMarker(
        id: point.name,
        position: point.location,
      );

      marker.setOnTapListener((overlay) {
        // infoWindow 대신 caption 사용
        marker.setCaption(
          NOverlayCaption(
            text: '${i + 1}. ${point.name}',
            textSize: 14,
            color: Colors.blue,
            haloColor: Colors.white,
          ),
        );
      });

      setState(() {
        markers.add(marker);
      });
    }
  }

  Future<void> _createRoute() async {
    try {
      for (int i = 0; i < widget.points.length - 1; i++) {
        final start = widget.points[i];
        final end = widget.points[i + 1];

        final coords = await _fetchDirections(
          start.location,
          end.location,
        );

        if (coords != null && coords.isNotEmpty) {
          final pathOverlay = NPathOverlay(
            id: 'path_$i',
            coords: coords,
            color: const Color(0xFF2196F3).withOpacity(0.8),
            width: 3,
            outlineColor: Colors.white,
          );

          setState(() {
            paths.add(pathOverlay);
          });
        }
      }
    } catch (e) {
      print('Error creating route: $e');
    }
  }

  Future<List<NLatLng>?> _fetchDirections(NLatLng start, NLatLng end) async {
    try {
      final url = Uri.parse(
          'https://naveropenapi.apigw.ntruss.com/map-direction/v1/driving'
              '?start=${start.longitude},${start.latitude}'
              '&goal=${end.longitude},${end.latitude}'
              '&option=trafast'
      );

      final response = await http.get(
        url,
        headers: {
          'X-NCP-APIGW-API-KEY-ID': 'j3gnaneqmd',
          'X-NCP-APIGW-API-KEY': 'WdWzIfcchu614fM1CD1vKA9JzaJATTj0DGKM5CPF',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['route'] != null &&
            data['route']['trafast'] != null &&
            data['route']['trafast'][0]['path'] != null) {
          final path = data['route']['trafast'][0]['path'] as List;
          return path.map((point) => NLatLng(
            (point[1] as num).toDouble(),
            (point[0] as num).toDouble(),
          )).toList();
        }
      }
      return null;
    } catch (e) {
      print('Error fetching directions: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('여행 코스'),
      ),
      body: NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: widget.points.isNotEmpty
                ? widget.points.first.location
                : const NLatLng(37.5666102, 126.9783881),
            zoom: 12,
          ),
          // enableGestures 대신 각각의 제스처 설정
          contentPadding: EdgeInsets.zero,
          scrollGesturesEnable: true,
          rotationGesturesEnable: true,
          tiltGesturesEnable: true,
          zoomGesturesEnable: true,
        ),
        onMapReady: (controller) {
          _mapController = controller;
          if (widget.points.isNotEmpty) {
            for (var marker in markers) {
              controller.addOverlay(marker);
            }
            for (var path in paths) {
              controller.addOverlay(path);
            }

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
    );
  }

  NLatLngBounds _calculateBounds(List<TravelPoint> points) {
    var minLat = points.first.location.latitude;
    var maxLat = points.first.location.latitude;
    var minLng = points.first.location.longitude;
    var maxLng = points.first.location.longitude;

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
  void dispose() {
    _mapController = null;
    super.dispose();
  }
}