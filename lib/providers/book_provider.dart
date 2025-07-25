// providers/book_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';

class BookProvider with ChangeNotifier {
  List<Book> _books = [];

  List<Book> get books => _books;

  BookProvider() {
    _startBookStream();
  }

  void _startBookStream() {
    FirebaseFirestore.instance.collection('books').snapshots().listen((snapshot) {
      _books = snapshot.docs.map((doc) => Book.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    });
  }

  Future<void> deleteBook(String bookId) async {
    try {
      await FirebaseFirestore.instance.collection('books').doc(bookId).delete();

    } catch (error) {
      print('Error deleting book: $error');
      rethrow;
    }
  }

  void toggleWishlist(String bookId) {
    final index = _books.indexWhere((book) => book.id == bookId);
    if (index != -1) {
      _books[index] = _books[index].copyWith(
        isWishlisted: !_books[index].isWishlisted,
      );
      notifyListeners();
    }
  }

  Book? findById(String id) {
    try {
      return _books.firstWhere((book) => book.id == id);
    } catch (e) {
      return null;
    }
  }
}
