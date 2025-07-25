// providers/wishlist_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/book.dart';

class WishlistProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Book> _wishlist = [];


  List<Book> get wishlist => _wishlist;

  get books => null;

  set allBooks(List<Book> allBooks) {}


  bool isWishlisted(String bookId) {
    return _wishlist.any((book) => book.id == bookId);
  }


  Future<void> loadWishlist() async {
    _wishlist.clear();
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final snapshot = await _firestore
          .collection('wishlists')
          .doc(user.uid)
          .collection('items')
          .get();

      for (var doc in snapshot.docs) {
        final data = doc.data();

        final book = Book(
          id: doc.id,
          title: data['title'] ?? '',
          author: data['author'] ?? '',
          price: (data['price'] ?? 0).toDouble(),
          imageUrl: data['imageUrl'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          quantity: data['quantity'] ?? 0,
        );

        _wishlist.add(book);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading wishlist: $e');
    }
  }


  Future<void> addToWishlist(Book book) async {
    final user = _auth.currentUser;
    if (user == null || book.id.isEmpty) return;

    try {
      _wishlist.add(book);
      notifyListeners();

      await _firestore
          .collection('wishlists')
          .doc(user.uid)
          .collection('items')
          .doc(book.id)
          .set(book.toMap());
    } catch (e) {
      debugPrint('Error adding to wishlist: $e');
    }
  }


  Future<void> removeFromWishlist(String bookId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      _wishlist.removeWhere((book) => book.id == bookId);
      notifyListeners();

      await _firestore
          .collection('wishlists')
          .doc(user.uid)
          .collection('items')
          .doc(bookId)
          .delete();
    } catch (e) {
      debugPrint('Error removing from wishlist: $e');
    }
  }


  Future<void> toggleWishlist(Book book) async {
    if (isWishlisted(book.id)) {
      await removeFromWishlist(book.id);
    } else {
      await addToWishlist(book);
    }
  }


  Future<void> clearWishlist({required bool deleteFromFirebase}) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      if (deleteFromFirebase) {
        final wishlistRef = _firestore
            .collection('wishlists')
            .doc(user.uid)
            .collection('items');

        final snapshot = await wishlistRef.get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }

      _wishlist.clear();
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing wishlist: $e');
    }
  }


  void clearLocalWishlistOnly() {
    _wishlist.clear();
    notifyListeners();
  }
}
