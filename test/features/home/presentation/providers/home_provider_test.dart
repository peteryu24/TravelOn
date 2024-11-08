import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:travel_on_final/features/home/domain/usecases/get_next_trip.dart';
import 'package:travel_on_final/features/home/domain/entities/next_trip_entity.dart';
import 'package:travel_on_final/features/home/presentation/providers/home_provider.dart';

// GetNextTrip 클래스를 모킹하기 위한 어노테이션
@GenerateMocks([GetNextTrip])
import 'home_provider_test.mocks.dart';

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

  test('loadNextTrip loads data successfully', () async {
    final tNextTrip = NextTripEntity(
      packageTitle: '부산 여행',
      tripDate: DateTime.now(),
      dDay: 5,
      isTodayTrip: false,
    );

    // String 타입의 매개변수를 명시적으로 지정
    when(mockGetNextTrip.call(argThat(isA<String>())))
        .thenAnswer((_) async => tNextTrip);

    await provider.loadNextTrip('test_user_id');
    verify(mockGetNextTrip.call(any)).called(1);
    expect(provider.nextTrip, equals(tNextTrip));
  });
}
