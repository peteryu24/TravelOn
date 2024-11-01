// test/features/home/presentation/providers/home_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:travel_on_final/features/home/domain/entities/next_trip_entity.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart';
import 'home_provider_test.mocks.dart';

@GenerateMocks([GetNextTrip]) // GenerateNiceMocks가 아닌 GenerateMocks 사용
void main() {
  late HomeProvider provider;
  late MockGetNextTrip mockGetNextTrip;

  setUp(() {
    mockGetNextTrip = MockGetNextTrip();
    provider = HomeProvider(mockGetNextTrip);
  });

  test('initial state is correct', () {
    expect(provider.isLoading, false);
    expect(provider.nextTrip, null);
  });

  group('loadNextTrip', () {
    test('should set loading state and update next trip data', () async {
      // given
      final tNextTrip = NextTripEntity(
        packageTitle: '부산 여행',
        tripDate: DateTime.now(),
        dDay: 5,
        isTodayTrip: false,
      );

      when(mockGetNextTrip(argThat(isA<String>())))
          .thenAnswer((_) async => tNextTrip);

      // when
      await provider.loadNextTrip('test_user_id');

      // then
      expect(provider.nextTrip, tNextTrip);
      expect(provider.isLoading, false);
      verify(mockGetNextTrip(argThat(isA<String>()))).called(1);
    });

    test('should handle error and set loading to false', () async {
      // given
      when(mockGetNextTrip(argThat(isA<String>())))
          .thenThrow(Exception('Failed to load next trip'));

      // when
      await provider.loadNextTrip('test_user_id');

      // then
      expect(provider.nextTrip, null);
      expect(provider.isLoading, false);
      verify(mockGetNextTrip(argThat(isA<String>()))).called(1);
    });
  });
}
