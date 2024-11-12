import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/home/data/repositories/home_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

@GenerateNiceMocks([MockSpec<FirebaseFirestore>()])
void main() {
  group('HomeRepositoryImpl', () {
    late HomeRepositoryImpl repository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = HomeRepositoryImpl(fakeFirestore);
    });

    test('getNextTrip returns null when no reservations exist', () async {
      final nextTrip = await repository.getNextTrip('user1');
      expect(nextTrip, isNull);
    });

    test('getNextTrip returns closest future approved reservation', () async {
      // 테스트 데이터 준비
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final nextWeek = now.add(const Duration(days: 7));

      // 예약 데이터 추가
      await fakeFirestore.collection('reservations').add({
        'customerId': 'user1',
        'packageTitle': 'Test Package 1',
        'reservationDate': Timestamp.fromDate(tomorrow),
        'status': 'approved',
      });

      await fakeFirestore.collection('reservations').add({
        'customerId': 'user1',
        'packageTitle': 'Test Package 2',
        'reservationDate': Timestamp.fromDate(nextWeek),
        'status': 'approved',
      });

      // 테스트 실행
      final nextTrip = await repository.getNextTrip('user1');

      // 검증
      expect(nextTrip, isNotNull);
      expect(nextTrip!.packageTitle, 'Test Package 1');
    });
  });
}
