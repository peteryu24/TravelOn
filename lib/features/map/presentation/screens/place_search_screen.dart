import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:travel_on_final/features/map/domain/entities/travel_point.dart';
import 'package:http/http.dart' as http;

class PlaceSearchScreen extends StatefulWidget {
  final List<TravelPoint> selectedPoints;

  const PlaceSearchScreen({
    Key? key,
    required this.selectedPoints,
  }) : super(key: key);

  @override
  State<PlaceSearchScreen> createState() => _PlaceSearchScreenState();
}

class _PlaceSearchScreenState extends State<PlaceSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;

  Future<void> _searchPlaces(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
    });

    try {
      final uri = Uri.parse('https://openapi.naver.com/v1/search/local.json')
          .replace(queryParameters: {
        'query': query,
        'display': '20',
      });

      print('Request URL: $uri'); // URL 출력
      print('Headers: ${
          {
            'X-Naver-Client-Id': 'j3gnaneqmd',
            'X-Naver-Client-Secret': 'WdWzIfcchu614fM1CD1vKA9JzaJATTj0DGKM5CPF',
          }
      }'); // 헤더 출력

      final response = await http.get(
        uri,
        headers: {
          'X-Naver-Client-Id': 'GzfydSb1vlCZqce1VtJq',
          'X-Naver-Client-Secret': 'viquA27z93',
        },
      );

      print('Response status code: ${response.statusCode}'); // 상태 코드 출력
      print('Response body: ${response.body}'); // 응답 내용 출력

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['items'] ?? [];
        });
        print('Search results: $_searchResults'); // 결과 출력
      }
    } catch (e) {
      print('Error searching places: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  PointType _determinePointType(String category) {
    if (category.contains('숙박') || category.contains('호텔') ||
        category.contains('펜션') || category.contains('게스트하우스')) {
      return PointType.hotel;
    } else if (category.contains('음식') || category.contains('식당') ||
        category.contains('카페')) {
      return PointType.restaurant;
    } else {
      return PointType.attraction;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('장소 검색'),
      ),
      body: Column(
        children: [
          // 선택된 장소들 표시
          if (widget.selectedPoints.isNotEmpty)
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.selectedPoints.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final point = widget.selectedPoints[index];
                  return Chip(
                    label: Text('${index + 1}. ${point.name}'),
                    avatar: Icon(
                      point.type == PointType.hotel ? Icons.hotel :
                      point.type == PointType.restaurant ? Icons.restaurant :
                      Icons.photo_camera,
                    ),
                  );
                },
              ),
            ),

          // 검색창
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '장소 이름으로 검색...',
                suffixIcon: IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Icon(Icons.search),
                  onPressed: () => _searchPlaces(_searchController.text),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _searchPlaces,
            ),
          ),

          // 검색 결과
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final place = _searchResults[index];
                // HTML 태그 제거
                final title = place['title'].toString().replaceAll(RegExp(r'<[^>]*>'), '');
                final type = _determinePointType(place['category'] ?? '');

                return ListTile(
                  leading: Icon(
                    type == PointType.hotel ? Icons.hotel :
                    type == PointType.restaurant ? Icons.restaurant :
                    Icons.photo_camera,
                  ),
                  title: Text(title),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(place['address'] ?? ''),
                      if (place['category'] != null)
                        Text(
                          place['category'],
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    final newPoint = TravelPoint(
                      id: UniqueKey().toString(),
                      name: title,
                      type: type,
                      location: NLatLng(
                        double.parse(place['mapy']) / 10000000,
                        double.parse(place['mapx']) / 10000000,
                      ),
                      address: place['address'] ?? '',
                      description: place['description'] ?? '',
                      order: widget.selectedPoints.length, day: 1,
                    );

                    Navigator.pop(context, newPoint);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}