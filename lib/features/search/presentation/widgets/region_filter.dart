import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
        PopupMenuItem<String>(
          value: 'all',
          child: Text('regions.all'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'seoul',
          child: Text('regions.seoul'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'incheon_gyeonggi',
          child: Text('regions.incheon_gyeonggi'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'gangwon',
          child: Text('regions.gangwon'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'daejeon_chungnam',
          child: Text('regions.daejeon_chungnam'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'chungbuk',
          child: Text('regions.chungbuk'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'gwangju_jeonnam',
          child: Text('regions.gwangju_jeonnam'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'jeonbuk',
          child: Text('regions.jeonbuk'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'busan_gyeongnam',
          child: Text('regions.busan_gyeongnam'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'daegu_gyeongbuk',
          child: Text('regions.daegu_gyeongbuk'.tr()),
        ),
        PopupMenuItem<String>(
          value: 'jeju',
          child: Text('regions.jeju'.tr()),
        ),
      ],
    );
  }
}