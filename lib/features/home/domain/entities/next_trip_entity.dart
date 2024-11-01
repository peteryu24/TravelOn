// lib/features/home/domain/entities/next_trip_entity.dart
class NextTripEntity {
  final String packageTitle;
  final DateTime tripDate;
  final int? dDay;
  final bool isTodayTrip; // null이 아닌 기본값을 가지도록 수정

  NextTripEntity({
    required this.packageTitle,
    required this.tripDate,
    this.dDay,
    required this.isTodayTrip, // required로 변경
  });
}
