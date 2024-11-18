import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/regional_spot_model.dart';
import '../../domain/repositories/regional_repository.dart';
import '../../domain/entities/regional_spot.dart';
import '../../../../core/error/failures.dart';
import 'package:intl/intl.dart';

class RegionalRepositoryImpl implements RegionalRepository {
  final http.Client client;

  RegionalRepositoryImpl({required this.client});

  @override
  Future<List<RegionalSpot>> getRegionalSpots({
    required String cityCode,
    required String districtCode,
    String? category,
  }) async {
    try {
      final now = DateTime.now();
      final lastMonth = DateTime(now.year, now.month - 1);
      final baseYm = DateFormat('yyyyMM').format(lastMonth);

      print('Requesting data for: $baseYm');

      final apiKey = dotenv.env['TOURISMDENSITY_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw ServerFailure('API 키가 설정되지 않았습니다.');
      }

      final queryParameters = {
        'serviceKey': apiKey,
        'numOfRows': '100',
        'pageNo': '1',
        'MobileOS': 'AND',
        'MobileApp': 'TravelOn',
        '_type': 'json',
        'baseYm': baseYm,
      };

      if (cityCode != 'all') {
        queryParameters['areaCd'] = cityCode;
        if (districtCode.isNotEmpty) {
          queryParameters['signguCd'] = districtCode;
        }
      }

      final uri = Uri.https(
        'apis.data.go.kr',
        '/B551011/TarRlteTarService/areaBasedList',
        queryParameters,
      );

      print('Request URL: $uri');

      final response = await client.get(
        uri,
        headers: {'Accept-Charset': 'UTF-8'},
      );

      final decodedBody = utf8.decode(response.bodyBytes);
      print('Response status code: ${response.statusCode}');
      print('Response body: $decodedBody');

      if (response.statusCode == 200) {
        if (decodedBody.trim().startsWith('<')) {
          // XML 에러 응답 처리
          if (decodedBody.contains('SERVICE_KEY_IS_NOT_REGISTERED_ERROR')) {
            throw ServerFailure('API 키가 유효하지 않습니다. API 키를 확인해주세요.');
          }
          throw ServerFailure('서버에서 XML 응답이 반환되었습니다.');
        }

        try {
          final data = json.decode(decodedBody);
          if (data['response']?['header']?['resultCode'] == '0000') {
            final items = data['response']?['body']?['items']?['item'];

            // items가 null이거나 빈 문자열인 경우 빈 리스트 반환
            if (items == null || items == '') {
              return [];
            }

            // items가 List인지 확인
            if (items is List) {
              var spots = items
                  .map((item) => RegionalSpotModel.fromJson(item))
                  .toList();

              if (category != null && category != '전체') {
                spots = spots.where((spot) {
                  print(
                      'Category check: ${spot.category} == $category'); // 디버그용
                  return spot.category == category;
                }).toList();
              }

              print('Parsed spots: ${spots.length}'); // 디버그용
              return spots;
            }

            return [];
          } else {
            final resultMsg = data['response']?['header']?['resultMsg'] ??
                '알 수 없는 오류가 발생했습니다.';
            throw ServerFailure('API 오류: $resultMsg');
          }
        } catch (e) {
          print('JSON 파싱 에러 상세: $e'); // 더 자세한 에러 정보
          if (e is ServerFailure) rethrow;
          throw ServerFailure('응답 데이터 처리 중 오류가 발생했습니다: $e');
        }
      }
      throw ServerFailure('서버 응답 오류: ${response.statusCode}');
    } catch (e) {
      print('Error details: $e');
      if (e is ServerFailure) {
        rethrow;
      }
      throw ServerFailure(e.toString());
    }
  }
}
