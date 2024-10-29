import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/travel_package.dart';

class PackageDetailScreen extends StatelessWidget {
  final TravelPackage package;
  final NumberFormat _priceFormat = NumberFormat('#,###');

  PackageDetailScreen({
    Key? key,
    required this.package,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('패키지 상세'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 메인 이미지
            if (package.mainImage != null && package.mainImage!.isNotEmpty)
              Image.network(
                package.mainImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.error_outline,
                        size: 40,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                height: 200,
                width: double.infinity,
                color: Colors.blue.shade100,
                child: Center(
                  child: Icon(
                    Icons.landscape,
                    size: 64,
                    color: Colors.blue.shade900,
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 및 지역
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          package.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getRegionText(package.region),
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 가격
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.payment, color: Colors.blue),
                        const SizedBox(width: 8),
                        Text(
                          '₩${_priceFormat.format(package.price.toInt())}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 설명
                  const Text(
                    '상세 설명',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    package.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),

                  // 설명 이미지들
                  if (package.descriptionImages.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      '상세 이미지',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: package.descriptionImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              package.descriptionImages[index],
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  width: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.error_outline,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            // TODO: 예약 기능 구현
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text(
            '예약하기',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ),
    );
  }

  String _getRegionText(String region) {
    switch (region) {
      case 'seoul':
        return '서울';
      case 'incheon_gyeonggi':
        return '인천/경기';
      case 'gangwon':
        return '강원';
      case 'daejeon_chungnam':
        return '대전/충남';
      case 'chungbuk':
        return '충북';
      case 'gwangju_jeonnam':
        return '광주/전남';
      case 'jeonbuk':
        return '전북';
      case 'busan_gyeongnam':
        return '부산/경남';
      case 'daegu_gyeongbuk':
        return '대구/경북';
      case 'jeju':
        return '제주도';
      default:
        return '전체';
    }
  }
}