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
      print('Fetching packages from Firestore...');
      final snapshot = await _firestore.collection('packages').get();
      print('Fetched ${snapshot.docs.length} packages');

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
        );
      }).toList();
    } catch (e) {
      print('Error fetching packages: $e');
      return [];
    }
  }

  @override
  Future<void> addPackage(TravelPackage package) async {
    try {
      print('Starting to add package...');
      String? mainImageUrl;
      List<String> descriptionImageUrls = [];

      // 메인 이미지 업로드
      if (package.mainImage != null) {
        print('Uploading main image...');
        final mainImageFile = File(package.mainImage!);
        final mainImageRef = _storage.ref('package_images/${DateTime.now().millisecondsSinceEpoch}_main.jpg');
        await mainImageRef.putFile(mainImageFile);
        mainImageUrl = await mainImageRef.getDownloadURL();
        print('Main image uploaded: $mainImageUrl');
      }

      // 설명 이미지들 업로드
      for (String imagePath in package.descriptionImages) {
        print('Uploading description image...');
        final file = File(imagePath);
        final imageRef = _storage.ref('package_images/${DateTime.now().millisecondsSinceEpoch}_${descriptionImageUrls.length}.jpg');
        await imageRef.putFile(file);
        final imageUrl = await imageRef.getDownloadURL();
        descriptionImageUrls.add(imageUrl);
        print('Description image uploaded: $imageUrl');
      }

      // Firestore에 데이터 저장
      print('Saving package data to Firestore...');
      final docRef = await _firestore.collection('packages').add({
        'title': package.title,
        'description': package.description,
        'price': package.price,
        'region': package.region,
        'mainImage': mainImageUrl,
        'descriptionImages': descriptionImageUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });
      print('Package saved with ID: ${docRef.id}');

    } catch (e) {
      print('Error adding package: $e');
      rethrow;
    }
  }
}