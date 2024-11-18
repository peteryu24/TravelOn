import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/tourism_density_model.dart';

class TourismDensityApi {
  static const baseUrl = 'http://apis.data.go.kr/B551011/TatsCnctrRateService';

  // 환경변수에서 API 키 가져오기
  static String get apiKey => dotenv.env['TOURISMDENSITY_API_KEY'] ?? '';

  Future<List<TourismDensityModel>> getTourismDensity() async {
    try {
      final uri = Uri.parse('$baseUrl/tatsCnctrRateList').replace(
        queryParameters: {
          'serviceKey': apiKey,
          'numOfRows': '20',
          'pageNo': '1',
          'MobileOS': 'ETC',
          'MobileApp': 'TravelOn',
          '_type': 'json',
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['response']['body']['items']['item'] as List;
        return items.map((item) => TourismDensityModel.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load tourism density data');
      }
    } catch (e) {
      // 테스트용 더미 데이터 반환
      return [
        TourismDensityModel(
            name: '경복궁', density: 75.5, location: '서울', category: '고궁'),
        TourismDensityModel(
            name: '해운대', density: 82.3, location: '부산', category: '해변'),
        // ... 더미 데이터 추가
      ];
    }
  }
}
