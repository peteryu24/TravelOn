import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/reservation/domain/entities/reservation_entity.dart';

class ReservationModel extends ReservationEntity {
  ReservationModel({
    required String id,
    required String packageId,
    required String packageTitle,
    required String customerId,
    required String customerName,
    required String guideName,
    required String guideId,
    required DateTime reservationDate,
    required DateTime requestedAt,
    required String status,
    required double price,
  }) : super(
    id: id,
    packageId: packageId,
    packageTitle: packageTitle,
    customerId: customerId,
    customerName: customerName,
    guideName: guideName,
    guideId: guideId,
    reservationDate: reservationDate,
    requestedAt: requestedAt,
    status: status,
    price: price,
  );

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as String,
      packageId: json['packageId'] as String,
      packageTitle: json['packageTitle'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      guideName: json['guideName'] as String,
      guideId: json['guideId'] as String,
      reservationDate: (json['reservationDate'] as Timestamp).toDate(),
      requestedAt: (json['requestedAt'] as Timestamp).toDate(),
      status: json['status'] as String,
      price: json['price'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'packageId': packageId,
      'packageTitle': packageTitle,
      'customerId': customerId,
      'customerName': customerName,
      'guideName': guideName,
      'guideId': guideId,
      'reservationDate': Timestamp.fromDate(reservationDate),
      'requestedAt': Timestamp.fromDate(requestedAt),
      'status': status,
      'price': price,
    };
  }
}