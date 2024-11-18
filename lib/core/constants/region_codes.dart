class RegionCodes {
  static const Map<String, Map<String, String>> codes = {
    '서울': {
      '중구': '11140',
      '종로구': '11110',
      '용산구': '11170',
    },
    '부산': {
      '중구': '26110',
      '해운대구': '26310',
      '서구': '26140',
    },
    '대구': {
      '중구': '27110',
      '동구': '27140',
      '서구': '27170',
    },
    '인천': {
      '중구': '28110',
      '동구': '28140',
      '미추홀구': '28177',
    },
    '광주': {
      '동구': '29110',
      '서구': '29140',
      '남구': '29155',
    },
    '대전': {
      '동구': '30110',
      '중구': '30140',
      '서구': '30170',
    },
    '울산': {
      '중구': '31110',
      '남구': '31140',
      '동구': '31170',
    },
    '경기': {
      '수원시': '41110',
      '성남시': '41130',
      '과천시': '41290',
    },
    '강원': {
      '춘천시': '42110',
      '원주시': '42130',
      '강릉시': '42150',
    },
    '제주': {
      '제주시': '50110',
      '서귀포시': '50130',
    },
  };

  static String? getAreaCode(String region) {
    if (!codes.containsKey(region)) return null;
    // 지역코드는 시군구 코드의 앞 2자리
    return codes[region]!.values.first.substring(0, 2);
  }

  static String? getSignguCode(String region, String district) {
    if (!codes.containsKey(region)) return null;
    return codes[region]![district];
  }

  static List<String> get regions => codes.keys.toList();

  static List<String> getDistricts(String region) {
    if (!codes.containsKey(region)) return [];
    return codes[region]!.keys.toList();
  }
}
