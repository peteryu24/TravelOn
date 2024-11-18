import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/regional_spot.dart';

class RegionalSpotCard extends StatelessWidget {
  final RegionalSpot spot;

  const RegionalSpotCard({
    super.key,
    required this.spot,
  });

  Future<void> _launchNaverMap() async {
    // 네이버 지도 검색 URL 생성
    final searchQuery = Uri.encodeComponent('${spot.name} ${spot.address}');
    final naverMapUrl = Uri.parse(
      'nmap://search?query=$searchQuery&appname=com.example.travel_on_final',
    );

    // 웹 URL (앱이 설치되지 않은 경우 사용)
    final webUrl = Uri.parse(
      'https://map.naver.com/v5/search/$searchQuery',
    );

    try {
      // 네이버 지도 앱으로 열기 시도
      if (await canLaunchUrl(naverMapUrl)) {
        await launchUrl(naverMapUrl);
      } else {
        // 앱이 없으면 웹으로 열기
        if (await canLaunchUrl(webUrl)) {
          await launchUrl(webUrl);
        } else {
          throw '지도를 열 수 없습니다.';
        }
      }
    } catch (e) {
      print('Error launching map: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      child: ListTile(
        title: Text(
          spot.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(spot.address),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    spot.category,
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '연관도 ${spot.rank}위',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(CupertinoIcons.placemark_fill, color: Colors.blue),
          onPressed: _launchNaverMap,
        ),
        onTap: _launchNaverMap,
      ),
    );
  }
}
