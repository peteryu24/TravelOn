import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_on_final/features/search/domain/entities/travel_package.dart';
import 'package:travel_on_final/features/search/domain/repositories/travel_repositories.dart';



class TravelRepositoryImpl implements TravelRepository {
  final FirebaseFirestore _firestore;

  TravelRepositoryImpl(this._firestore);

  @override
  Future<List<TravelPackage>> getPackages() async {
    try {
      final snapshot = await _firestore.collection('packages').get();
      return snapshot.docs
          .map((doc) => TravelPackage(
        id: doc.id,
        title: doc['title'],
        region: doc['region'],
        price: doc['price'].toDouble(),
        description: doc['description'],
      ))
          .toList();
    } catch (e) {
      print('Error fetching packages: $e');
      return [];
    }
  }

  @override
  Future<void> addPackage(TravelPackage package) async {
    try {
      await _firestore.collection('packages').add({
        'title': package.title,
        'region': package.region,
        'price': package.price,
        'description': package.description,
      });
    } catch (e) {
      print('Error adding package: $e');
      throw Exception('Failed to add package');
    }
  }
}
