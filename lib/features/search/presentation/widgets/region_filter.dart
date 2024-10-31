import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class RegionFilter extends StatelessWidget {
  final Function(String) onRegionChanged;

  const RegionFilter({
    Key? key,
    required this.onRegionChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list),
      onSelected: onRegionChanged,
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'all',
          child: Text('전체'),
        ),
        const PopupMenuItem<String>(
          value: 'seoul',
          child: Text('서울'),
        ),
        const PopupMenuItem<String>(
          value: 'incheon_gyeonggi',
          child: Text('인천/경기'),
        ),
        const PopupMenuItem<String>(
          value: 'gangwon',
          child: Text('강원'),
        ),
        const PopupMenuItem<String>(
          value: 'daejeon_chungnam',
          child: Text('대전/충남'),
        ),
        const PopupMenuItem<String>(
          value: 'chungbuk',
          child: Text('충북'),
        ),
        const PopupMenuItem<String>(
          value: 'gwangju_jeonnam',
          child: Text('광주/전남'),
        ),
        const PopupMenuItem<String>(
          value: 'jeonbuk',
          child: Text('전북'),
        ),
        const PopupMenuItem<String>(
          value: 'busan_gyeongnam',
          child: Text('부산/경남'),
        ),
        const PopupMenuItem<String>(
          value: 'daegu_gyeongbuk',
          child: Text('대구/경북'),
        ),
        const PopupMenuItem<String>(
          value: 'jeju',
          child: Text('제주도'),
        ),
      ],
    );
  }
}
