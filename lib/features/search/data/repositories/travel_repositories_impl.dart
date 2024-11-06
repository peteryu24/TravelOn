import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/repositories/travel_repositories.dart';
import '../../domain/entities/travel_package.dart';

class TravelRepositoryImpl implements TravelRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<List<TravelPackage>> getPackages() async {
    try {
      final snapshot = await _firestore.collection('packages').get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TravelPackage(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          region: data['region'] ?? '',
          mainImage: data['mainImage'],
          descriptionImages: List<String>.from(data['descriptionImages'] ?? []),
          guideName: data['guideName'] ?? '',
          guideId: data['guideId'] ?? '',
          minParticipants: (data['minParticipants'] as num?)?.toInt() ?? 4,
          maxParticipants: (data['maxParticipants'] as num?)?.toInt() ?? 8,
          nights: (data['nights'] ?? 1).toInt(),
          departureDays: List<int>.from(data['departureDays'] ?? [1,2,3,4,5,6,7]),
          reviewCount: (data['reviewCount'] as num?)?.toInt() ?? 0,

        );
      }).toList();
    } catch (e) {
      print('Error getting packages: $e');
      rethrow;
    }
  }

  @override
  Future<void> addPackage(TravelPackage package) async {
    try {
      print('Starting to add package...');

      String? mainImageUrl;
      List<String> descriptionImageUrls = [];

      if (package.mainImage != null) {
        print('Uploading main image...');
        final mainImageFile = File(package.mainImage!);
        final mainImageRef = _storage.ref(
            'package_images/${DateTime.now().millisecondsSinceEpoch}_main.jpg');
        await mainImageRef.putFile(mainImageFile);
        mainImageUrl = await mainImageRef.getDownloadURL();
        print('Main image uploaded: $mainImageUrl');
      }

      for (String imagePath in package.descriptionImages) {
        print('Uploading description image...');
        final file = File(imagePath);
        final imageRef = _storage.ref(
            'package_images/${DateTime.now().millisecondsSinceEpoch}_${descriptionImageUrls.length}.jpg');
        await imageRef.putFile(file);
        final imageUrl = await imageRef.getDownloadURL();
        descriptionImageUrls.add(imageUrl);
        print('Description image uploaded: $imageUrl');
      }

      final packageData = {
        'title': package.title,
        'description': package.description,
        'price': package.price,
        'region': package.region,
        'mainImage': mainImageUrl,
        'descriptionImages': descriptionImageUrls,
        'createdAt': FieldValue.serverTimestamp(),
        'guideName': package.guideName,
        'guideId': package.guideId,
        'minParticipants': package.minParticipants,
        'maxParticipants': package.maxParticipants,
        'nights': package.nights,
        'departureDays': package.departureDays,
        'likedBy': [], // 초기 빈 배열로 설정
        'likesCount': 0, // 초기값 0으로 설정
      };

      if (package.minParticipants <= 0) {
        throw '최소 인원은 0보다 커야 합니다';
      }
      if (package.maxParticipants < package.minParticipants) {
        throw '최대 인원은 최소 인원보다 작을 수 없습니다';
      }

      final docRef = await _firestore.collection('packages').add(packageData);
      print('Package saved with ID: ${docRef.id}');

      final savedDoc = await docRef.get();
      final savedData = savedDoc.data();
      print('Saved package data:');
      print('minParticipants: ${savedData?['minParticipants']}');
      print('maxParticipants: ${savedData?['maxParticipants']}');
    } catch (e) {
      print('Error adding package: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePackage(TravelPackage package) async {
    try {
      print('Starting to update package...');

      String? mainImageUrl;
      List<String> descriptionImageUrls = [];

      // 메인 이미지가 로컬 파일인 경우에만 업로드
      if (package.mainImage != null && package.mainImage!.startsWith('/')) {
        print('Uploading new main image...');
        final mainImageFile = File(package.mainImage!);
        final mainImageRef = _storage.ref(
            'package_images/${DateTime.now().millisecondsSinceEpoch}_main.jpg');
        await mainImageRef.putFile(mainImageFile);
        mainImageUrl = await mainImageRef.getDownloadURL();
      }

      // 설명 이미지 처리
      for (String imagePath in package.descriptionImages) {
        if (imagePath.startsWith('/')) {
          // 새로운 이미지는 업로드
          print('Uploading new description image...');
          final file = File(imagePath);
          final imageRef = _storage.ref(
              'package_images/${DateTime.now().millisecondsSinceEpoch}_${descriptionImageUrls.length}.jpg');
          await imageRef.putFile(file);
          final imageUrl = await imageRef.getDownloadURL();
          descriptionImageUrls.add(imageUrl);
        } else {
          // 기존 URL은 그대로 유지
          descriptionImageUrls.add(imagePath);
        }
      }

      final packageData = {
        'title': package.title,
        'description': package.description,
        'price': package.price,
        'region': package.region,
        'mainImage': mainImageUrl ?? package.mainImage,
        'descriptionImages': descriptionImageUrls,
        'updatedAt': FieldValue.serverTimestamp(),
        'guideName': package.guideName,
        'guideId': package.guideId,
        'minParticipants': package.minParticipants,
        'maxParticipants': package.maxParticipants,
        'nights': package.nights,
        'departureDays': package.departureDays,
      };

      if (package.minParticipants <= 0) {
        throw '최소 인원은 0보다 커야 합니다';
      }
      if (package.maxParticipants < package.minParticipants) {
        throw '최대 인원은 최소 인원보다 작을 수 없습니다';
      }

      await _firestore
          .collection('packages')
          .doc(package.id)
          .update(packageData);
      print('Package updated successfully');
    } catch (e) {
      print('Error updating package: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePackage(String packageId) async {
    try {
      print('Starting to delete package...');

      // 패키지 문서 가져오기
      final packageDoc =
          await _firestore.collection('packages').doc(packageId).get();
      final data = packageDoc.data();

      if (data != null) {
        // 연결된 이미지 삭제
        final mainImage = data['mainImage'] as String?;
        final descriptionImages =
            List<String>.from(data['descriptionImages'] ?? []);

        // 메인 이미지 삭제
        if (mainImage != null && mainImage.isNotEmpty) {
          try {
            await _storage.refFromURL(mainImage).delete();
            print('Main image deleted');
          } catch (e) {
            print('Error deleting main image: $e');
          }
        }

        // 설명 이미지들 삭제
        for (String imageUrl in descriptionImages) {
          try {
            await _storage.refFromURL(imageUrl).delete();
            print('Description image deleted');
          } catch (e) {
            print('Error deleting description image: $e');
          }
        }
      }

      // Firestore 문서 삭제
      await _firestore.collection('packages').doc(packageId).delete();
      print('Package deleted successfully');
    } catch (e) {
      print('Error deleting package: $e');
      rethrow;
    }
  }

  @override
  Future<void> toggleLike(String packageId, String userId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final packageRef = _firestore.collection('packages').doc(packageId);
        final userRef = _firestore.collection('users').doc(userId);

        // 패키지와 사용자 문서 가져오기
        final packageDoc = await transaction.get(packageRef);
        final userDoc = await transaction.get(userRef);

        if (!packageDoc.exists || !userDoc.exists) {
          throw '패키지 또는 사용자를 찾을 수 없습니다';
        }

        // 현재 데이터
        final List<String> likedBy =
            List<String>.from(packageDoc.data()!['likedBy'] ?? []);
        final List<String> userLikedPackages =
            List<String>.from(userDoc.data()!['likedPackages'] ?? []);

        if (likedBy.contains(userId)) {
          // 좋아요 취소
          likedBy.remove(userId);
          userLikedPackages.remove(packageId);
          transaction.update(packageRef, {
            'likedBy': likedBy,
            'likesCount': FieldValue.increment(-1),
          });
        } else {
          // 좋아요 추가
          likedBy.add(userId);
          userLikedPackages.add(packageId);
          transaction.update(packageRef, {
            'likedBy': likedBy,
            'likesCount': FieldValue.increment(1),
          });
        }

        // 사용자 문서 업데이트
        transaction.update(userRef, {
          'likedPackages': userLikedPackages,
        });
      });
    } catch (e) {
      print('Error in toggleLike: $e');
      rethrow;
    }
  }

  @override
  Future<List<String>> getLikedPackages(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return [];
      }
      return List<String>.from(userDoc.data()!['likedPackages'] ?? []);
    } catch (e) {
      print('Error getting liked packages: $e');
      return [];
    }
  }
}
