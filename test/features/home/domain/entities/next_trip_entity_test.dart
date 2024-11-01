// test/features/home/domain/entities/next_trip_entity_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_on_final/features/home/domain/entities/next_trip_entity.dart';

void main() {
  group('NextTripEntity', () {
    test('should create NextTripEntity instance', () {
      final nextTrip = NextTripEntity(
        packageTitle: '부산 여행',
        tripDate: DateTime(2024, 3, 1),
        dDay: 5,
        isTodayTrip: false,
      );

      expect(nextTrip.packageTitle, '부산 여행');
      expect(nextTrip.tripDate, DateTime(2024, 3, 1));
      expect(nextTrip.dDay, 5);
      expect(nextTrip.isTodayTrip, false);
    });
  });
}
