import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/reservation_model.dart';

class ReservationProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<ReservationModel> _reservations = [];

  ReservationProvider(FirebaseFirestore instance);

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
      final docRef = await _firestore.collection('reservations').add({
        'packageId': packageId,
        'packageTitle': packageTitle,
        'customerId': customerId,
        'customerName': customerName,
        'guideName': guideName,
        'guideId': guideId,
        'reservationDate': Timestamp.fromDate(reservationDate),
        'requestedAt': Timestamp.fromDate(DateTime.now()),
        'status': 'pending',
        'price': price,
      });

      // 가이드에게 알림 보내기
      await _firestore.collection('notifications').add({
        'userId': guideId,
        'title': '새로운 예약 요청',
        'message': '$customerName님이 $packageTitle 패키지를 예약 신청했습니다.',
        'type': 'reservation_request',
        'reservationId': docRef.id,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      notifyListeners();
    } catch (e) {
      print('Error creating reservation: $e');
      rethrow;
    }
  }

  Future<void> updateReservationStatus(String reservationId, String status) async {
    try {
      await _firestore.collection('reservations').doc(reservationId).update({
        'status': status,
      });

      // 예약자에게 알림 보내기
      final reservation = await _firestore.collection('reservations').doc(reservationId).get();
      final data = reservation.data()!;

      await _firestore.collection('notifications').add({
        'userId': data['customerId'],
        'title': '예약 상태 변경',
        'message': '${data['packageTitle']} 패키지의 예약이 $status 되었습니다.',
        'type': 'reservation_update',
        'reservationId': reservationId,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      notifyListeners();
    } catch (e) {
      print('Error updating reservation status: $e');
      rethrow;
    }
  }

  Future<void> loadReservations(String userId, {bool isGuide = false}) async {
    try {
      final queryField = isGuide ? 'guideId' : 'customerId';
      final snapshot = await _firestore
          .collection('reservations')
          .where(queryField, isEqualTo: userId)
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
}