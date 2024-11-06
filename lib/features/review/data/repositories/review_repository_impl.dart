import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/review/domain/entities/review.dart';
import 'package:travel_on_final/features/review/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<Review>> getPackageReviews(String packageId) async {
    try {
      print('Fetching reviews for package: $packageId'); // 디버깅용

      final snapshot = await _firestore
          .collection('reviews')
          .where('packageId', isEqualTo: packageId)
          .orderBy('createdAt', descending: true)
          .get();

      print('Found ${snapshot.docs.length} reviews'); // 디버깅용

      final reviews = snapshot.docs.map((doc) {
        final rating = (doc['rating'] as num).toDouble();
        print('Review rating: $rating'); // 디버깅용
        return Review(
          id: doc.id,
          packageId: doc['packageId'],
          userId: doc['userId'],
          userName: doc['userName'],
          rating: rating,
          content: doc['content'],
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
          reservationId: doc['reservationId'],
        );
      }).toList();

      // 평균 별점 계산 및 업데이트
      if (reviews.isNotEmpty) {
        double totalRating = reviews.fold(0.0, (sum, review) => sum + review.rating);
        double averageRating = totalRating / reviews.length;
        print('Average rating: $averageRating'); // 디버깅용

        await _firestore.collection('packages').doc(packageId).update({
          'averageRating': double.parse(averageRating.toStringAsFixed(1)),
          'reviewCount': reviews.length,
        });
      }

      return reviews;
    } catch (e) {
      print('Error getting package reviews: $e');
      rethrow;
    }
  }

  @override
  Future<bool> canUserReview(String userId, String packageId) async {
    try {
      // 승인된 예약이 있는지 확인
      final reservations = await _firestore
          .collection('reservations')
          .where('customerId', isEqualTo: userId)  // userId 대신 customerId 사용
          .where('packageId', isEqualTo: packageId)
          .where('status', isEqualTo: 'approved')
          .get();

      // 디버깅을 위한 로그 추가
      print('Checking review permission for user $userId and package $packageId');
      print('Found ${reservations.docs.length} approved reservations');

      return reservations.docs.isNotEmpty;
    } catch (e) {
      print('Error checking review permission: $e');
      return false;
    }
  }

  @override
  Future<void> addReview(Review review) async {
    try {
      // 예약 확인
      if (!await canUserReview(review.userId, review.packageId)) {
        throw '예약 승인된 사용자만 리뷰를 작성할 수 있습니다.';
      }

      // 리뷰 추가
      final reviewRef = await _firestore.collection('reviews').add({
        'packageId': review.packageId,
        'userId': review.userId,
        'userName': review.userName,
        'rating': review.rating,
        'content': review.content,
        'createdAt': FieldValue.serverTimestamp(),
        'reservationId': review.reservationId,
      });

      // 패키지 문서 가져오기
      final packageRef = _firestore.collection('packages').doc(review.packageId);

      // 현재 리뷰 수와 평균 별점 계산을 위한 모든 리뷰 가져오기
      final reviewsSnapshot = await _firestore
          .collection('reviews')
          .where('packageId', isEqualTo: review.packageId)
          .get();

      // 리뷰 개수와 총 별점 계산
      final reviewCount = reviewsSnapshot.docs.length;
      double totalRating = 0;
      for (var doc in reviewsSnapshot.docs) {
        totalRating += (doc.data()['rating'] as num).toDouble();
      }

      // 평균 별점 계산
      final averageRating = totalRating / reviewCount;

      // 패키지 문서 업데이트
      await packageRef.update({
        'reviewCount': reviewCount,
        'averageRating': double.parse(averageRating.toStringAsFixed(1)), // 소수점 첫째자리까지만
      });

    } catch (e) {
      print('Error adding review: $e');
      rethrow;
    }
  }

  Future<void> _updatePackageRating(String packageId) async {
    final reviews = await getPackageReviews(packageId);
    if (reviews.isEmpty) return;

    final averageRating = reviews.map((r) => r.rating).reduce((a, b) => a + b) / reviews.length;

    await _firestore.collection('packages').doc(packageId).update({
      'averageRating': averageRating,
      'reviewCount': reviews.length,
    });
  }

  @override
  Future<void> updateReview(Review review) async {
    await _firestore.collection('reviews').doc(review.id).update({
      'rating': review.rating,
      'content': review.content,
      // 필요한 다른 필드들...
    });

    // 패키지의 평균 별점 업데이트
    await _updatePackageRating(review.packageId);
  }


  @override
  Future<void> deleteReview(String reviewId) async {
    // 리뷰 문서 가져오기
    final reviewDoc = await _firestore.collection('reviews').doc(reviewId).get();
    final packageId = reviewDoc.data()?['packageId'];

    // 리뷰 삭제
    await _firestore.collection('reviews').doc(reviewId).delete();

    // 패키지의 평균 별점 업데이트
    if (packageId != null) {
      await _updatePackageRating(packageId);
    }
  }
}