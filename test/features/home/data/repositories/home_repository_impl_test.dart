// test/features/home/data/repositories/home_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/home/data/repositories/home_repository_impl.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  late HomeRepositoryImpl repository;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    repository = HomeRepositoryImpl(fakeFirestore);
  });

  group('HomeRepositoryImpl', () {
    test('getNextTrip returns null when no reservations exist', () async {
      final result = await repository.getNextTrip('user1');
      expect(result, isNull);
    });

    test('getNextTrip returns next trip when approved reservations exist',
        () async {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      await fakeFirestore.collection('reservations').add({
        'customerId': 'user1',
        'packageTitle': 'Test Package',
        'reservationDate': Timestamp.fromDate(tomorrow),
        'status': 'approved',
      });

      final result = await repository.getNextTrip('user1');

      expect(result, isNotNull);
      expect(result!.packageTitle, 'Test Package');
      expect(result.isTodayTrip, isFalse);
    });
  });
}
