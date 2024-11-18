import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

class MapDetailScreen extends StatelessWidget {
  final double latitude;
  final double longitude;

  const MapDetailScreen({
    Key? key,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late NaverMapController mapController;

    return Scaffold(
      appBar: AppBar(title: Text('위치 상세')),
      body: Column(
        children: [
          Container(
            height: 650.0,
            child: NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: NLatLng(latitude, longitude),
                  zoom: 16,
                ),
                mapType: NMapType.basic,
              ),
              onMapReady: (controller) {
                mapController = controller;
                mapController.addOverlay(NMarker(
                  id: 'detail-marker',
                  position: NLatLng(latitude, longitude),
                ));
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '위치 상세 정보',
                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final url = 'https://map.naver.com/v5/?c=18,${latitude},${longitude},0,0,0,dh'; // 네이버 지도 URL 예제
                        if (await canLaunchUrl(Uri.parse(url))) {
                          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('URL을 열 수 없습니다.')),
                          );
                        }
                      },
                      icon: Icon(Icons.link),
                      label: Text('네이버 지도에서 열기'),
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
}
