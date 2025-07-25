// providers/reviewprovide.dart
import 'package:prj/models/reviewmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReviewProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  User? get user => _auth.currentUser;


  Future<void> fetchReviews(String bookId) async {
    final snapshot = await _firestore
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .orderBy('timestamp', descending: true)
        .get();

    _reviews = snapshot.docs
        .where((doc) => (doc.data()['review'] ?? '').toString().isNotEmpty)
        .map((doc) => Review.fromFirestore(doc))
        .toList();

    notifyListeners();
  }


  Future<void> submitReview(String bookId, String reviewText) async {
    final user = _auth.currentUser;
    if (user == null || reviewText.trim().isEmpty) return;

    final reviewRef = _firestore
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .doc(user.uid);

    final review = Review(
      id: user.uid,
      userId: user.uid,
      userName: user.displayName ?? user.email ?? 'User',
      text: reviewText,
      timestamp: Timestamp.now(),
      likes: [],
    );

    await reviewRef.set(review.toMap(), SetOptions(merge: true));
    await fetchReviews(bookId);
  }


  Future<bool> canSubmitReview(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final result = await _firestore
        .collection('orders')
        .doc(user.uid)
        .collection('user_orders')
        .where('bookId', isEqualTo: bookId)
        .where('status', isEqualTo: 'delivered')
        .get();

    return result.docs.isNotEmpty;
  }


  Future<void> toggleLike(String bookId, Review review) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final reviewRef = _firestore
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .doc(review.id);

    final isLiked = review.isLikedBy(user.uid);
    final updatedLikes = List<String>.from(review.likes);

    if (isLiked) {
      updatedLikes.remove(user.uid);
    } else {
      updatedLikes.add(user.uid);
    }

    await reviewRef.update({'likes': updatedLikes});
    await fetchReviews(bookId);
  }
}
