// test/features/home/domain/usecases/get_next_trip_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:travel_on_final/features/home/domain/entities/next_trip_entity.dart';
import 'package:travel_on_final/features/home/domain/repositories/home_repository.dart';
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late GetNextTrip usecase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    usecase = GetNextTrip(mockRepository);
  });

  test('should get next trip from repository', () async {
    // given
    final tUserId = 'test_user_id';
    final tNextTrip = NextTripEntity(
      packageTitle: '부산 여행',
      tripDate: DateTime.now(),
      dDay: 5,
      isTodayTrip: false,
    );

    when(mockRepository.getNextTrip(tUserId))
        .thenAnswer((_) async => tNextTrip);

    // when
    final result = await usecase(tUserId);

    // then
    expect(result, tNextTrip);
    verify(mockRepository.getNextTrip(tUserId));
    verifyNoMoreInteractions(mockRepository);
  });
}
