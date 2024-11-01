import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../data/models/reservation_model.dart';

class ReservationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore;
  List<ReservationModel> _reservations = [];

  ReservationProvider(this._firestore);

  List<ReservationModel> get reservations => _reservations;

  Future<void> createReservation({
    required String packageId,
    required String packageTitle,
    required String customerId,
    required String customerName,
    required String guideName,
    required String guideId,
    required DateTime reservationDate,
    required double price,
  }) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final packageRef = _firestore.collection('packages').doc(packageId);
        final packageDoc = await transaction.get(packageRef);

        if (!packageDoc.exists) {
          throw '패키지를 찾을 수 없습니다';
        }

        final maxParticipants = packageDoc.data()?['maxParticipants'] ?? 0;

        // 해당 날짜의 예약 수 확인
        final reservationsQuery = await _firestore
            .collection('reservations')
            .where('packageId', isEqualTo: packageId)
            .where('status', isEqualTo: 'approved')
            .where('reservationDate', isEqualTo: Timestamp.fromDate(DateTime(reservationDate.year, reservationDate.month, reservationDate.day)))
            .get();

        if (reservationsQuery.docs.length >= maxParticipants) {
          throw '선택한 날짜는 예약이 마감되었습니다';
        }

        // 예약 생성
        final reservationRef = _firestore.collection('reservations').doc();
        transaction.set(reservationRef, {
          'packageId': packageId,
          'packageTitle': packageTitle,
          'customerId': customerId,
          'customerName': customerName,
          'guideName': guideName,
          'guideId': guideId,
          'reservationDate': Timestamp.fromDate(reservationDate),
          'requestedAt': FieldValue.serverTimestamp(),
          'status': 'pending',
          'price': price,
        });

        // 알림 생성
        final notificationRef = _firestore.collection('notifications').doc();
        transaction.set(notificationRef, {
          'userId': guideId,
          'title': '새로운 예약 요청',
          'message': '$customerName님이 $packageTitle 패키지를 예약 신청했습니다.',
          'type': 'reservation_request',
          'reservationId': reservationRef.id,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      });

      notifyListeners();
    } catch (e) {
      print('Error creating reservation: $e');
      rethrow;
    }
  }

  Future<void> updateReservationStatus(String reservationId, String status) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final reservationRef = _firestore.collection('reservations').doc(reservationId);
        final reservationDoc = await transaction.get(reservationRef);

        if (!reservationDoc.exists) {
          throw '예약을 찾을 수 없습니다';
        }

        final data = reservationDoc.data()!;
        final String packageId = data['packageId'];
        final DateTime reservationDate = (data['reservationDate'] as Timestamp).toDate();

        if (status == 'approved') {
          // 해당 날짜의 예약 수 다시 확인
          final reservationsQuery = await _firestore
              .collection('reservations')
              .where('packageId', isEqualTo: packageId)
              .where('status', isEqualTo: 'approved')
              .where('reservationDate', isEqualTo: Timestamp.fromDate(DateTime(reservationDate.year, reservationDate.month, reservationDate.day)))
              .get();

          final packageDoc = await transaction.get(_firestore.collection('packages').doc(packageId));
          final maxParticipants = packageDoc.data()?['maxParticipants'] ?? 0;

          if (reservationsQuery.docs.length >= maxParticipants) {
            throw '선택한 날짜는 예약이 마감되었습니다';
          }
        }

        // 상태 업데이트
        transaction.update(reservationRef, {
          'status': status,
        });

        // 알림 생성
        final notificationRef = _firestore.collection('notifications').doc();
        transaction.set(notificationRef, {
          'userId': data['customerId'],
          'title': '예약 상태 변경',
          'message': '${data['packageTitle']} 패키지의 예약이 ${_getStatusMessage(status)}되었습니다.',
          'type': 'reservation_update',
          'reservationId': reservationId,
          'createdAt': FieldValue.serverTimestamp(),
          'isRead': false,
        });
      });

      notifyListeners();
    } catch (e) {
      print('Error updating reservation status: $e');
      rethrow;
    }
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'approved':
        return '승인';
      case 'rejected':
        return '거절';
      default:
        return status;
    }
  }

  Future<void> loadReservations(String userId, {bool isGuide = false}) async {
    try {
      final queryField = isGuide ? 'guideId' : 'customerId';
      final snapshot = await _firestore
          .collection('reservations')
          .where(queryField, isEqualTo: userId)
          .orderBy('requestedAt', descending: true)
          .get();

      _reservations = snapshot.docs
          .map((doc) => ReservationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      notifyListeners();
    } catch (e) {
      print('Error loading reservations: $e');
      rethrow;
    }
  }

  // 패키지의 현재 예약 가능 여부 확인
  Future<bool> isPackageAvailable(String packageId) async {
    try {
      final packageDoc = await _firestore.collection('packages').doc(packageId).get();
      if (!packageDoc.exists) return false;

      final currentParticipants = packageDoc.data()?['currentParticipants'] ?? 0;
      final maxParticipants = packageDoc.data()?['maxParticipants'] ?? 0;

      return currentParticipants < maxParticipants;
    } catch (e) {
      print('Error checking package availability: $e');
      return false;
    }
  }

  Future<bool> isDateAvailable(String packageId, DateTime date) async {
    try {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));

      // 패키지 정보 가져오기
      final packageDoc = await _firestore.collection('packages').doc(packageId).get();
      if (!packageDoc.exists) return false;

      final maxParticipants = packageDoc.data()?['maxParticipants'] ?? 0;

      // 해당 날짜의 승인된 예약 수 확인
      final snapshot = await _firestore
          .collection('reservations')
          .where('packageId', isEqualTo: packageId)
          .where('status', isEqualTo: 'approved')
          .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('reservationDate', isLessThan: Timestamp.fromDate(end))
          .get();

      return snapshot.docs.length < maxParticipants;
    } catch (e) {
      print('Error checking date availability: $e');
      return false;
    }
  }
  Future<List<ReservationModel>> getMonthReservations(
      String packageId,
      DateTime start,
      DateTime end,
      ) async {
    try {
      final snapshot = await _firestore
          .collection('reservations')
          .where('packageId', isEqualTo: packageId)
          .where('status', isEqualTo: 'approved')
          .where('reservationDate', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
          .where('reservationDate', isLessThan: Timestamp.fromDate(end.add(const Duration(days: 1))))
          .get();

      return snapshot.docs
          .map((doc) => ReservationModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e) {
      print('Error getting month reservations: $e');
      return [];
    }
  }
}