// providers/rating_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RatingProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Map<String, double> _averageRatings = {};
  double getRatingForBook(String bookId) => _averageRatings[bookId] ?? 0;


  Future<void> saveRating(String bookId, double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await _firestore
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .doc(user.uid)
        .set({'rating': rating});
  }


  Future<void> fetchAverageRating(String bookId) async {
    final snapshot = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .get();

    if (snapshot.docs.isEmpty) {
      _averageRatings[bookId] = 0;
    } else {
      double total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['rating'] ?? 0).toDouble();
      }
      _averageRatings[bookId] = total / snapshot.docs.length;
    }

    notifyListeners();
  }


  Stream<double> averageRatingStream(String bookId) {
    return _firestore
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      double total = 0.0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['rating'] ?? 0).toDouble();
      }
      final average = total / snapshot.docs.length;
      _averageRatings[bookId] = average;
      return average;
    });
  }


  Future<double?> getUserRating(String bookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final doc = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      return (doc.data()?['rating'] ?? 0).toDouble();
    }

    return null;
  }


  Future<bool> hasUserOrderedAndDelivered(String bookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    final querySnapshot = await _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'delivered')
        .get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final items = data['items'] as List<dynamic>?;

      if (items != null) {
        for (var item in items) {
          if (item['id'] == bookId) return true;
          if (item['book'] != null && item['book']['id'] == bookId) return true;
        }
      }
    }

    return false;
  }


  Future<double> getAverageRating(String bookId) async {
    if (_averageRatings.containsKey(bookId)) {
      return _averageRatings[bookId]!;
    } else {
      await fetchAverageRating(bookId);
      return _averageRatings[bookId] ?? 0;
    }
  }
}
