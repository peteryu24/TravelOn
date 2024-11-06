import 'package:travel_on_final/features/review/domain/entities/review.dart';

abstract class ReviewRepository {
  Future<List<Review>> getPackageReviews(String packageId);
  Future<bool> canUserReview(String userId, String packageId);  // 예약 확인
  Future<void> addReview(Review review);
  Future<void> updateReview(Review review);
  Future<void> deleteReview(String reviewId);
}