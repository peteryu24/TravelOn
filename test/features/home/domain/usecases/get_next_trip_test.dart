// test/features/home/domain/usecases/get_next_trip_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:travel_on_final/features/home/domain/repositories/home_repository.dart';
import 'package:travel_on_final/features/home/domain/entities/next_trip_entity.dart';
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart';

@GenerateNiceMocks([MockSpec<HomeRepository>()])
import 'get_next_trip_test.mocks.dart';

void main() {
  late GetNextTrip useCase;
  late MockHomeRepository mockRepository;

  setUp(() {
    mockRepository = MockHomeRepository();
    useCase = GetNextTrip(mockRepository);
  });

  test('should get next trip from repository', () async {
    final mockNextTrip = NextTripEntity(
      packageTitle: 'Test Package',
      tripDate: DateTime.now().add(const Duration(days: 1)),
      isTodayTrip: false,
    );

    when(mockRepository.getNextTrip('user1'))
        .thenAnswer((_) async => mockNextTrip);

    final result = await useCase('user1');

    expect(result, equals(mockNextTrip));
    verify(mockRepository.getNextTrip('user1')).called(1);
  });

  test('should return null when no next trip exists', () async {
    when(mockRepository.getNextTrip('user1')).thenAnswer((_) async => null);

    final result = await useCase('user1');

    expect(result, isNull);
    verify(mockRepository.getNextTrip('user1')).called(1);
  });
}
