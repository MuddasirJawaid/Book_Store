// providers/cart_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/book.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CartItem {
  final Book book;
  int quantity;

  CartItem({required this.book, this.quantity = 1});

  double get subtotal => book.price * quantity;

  Map<String, dynamic> toMap() {
    return {...book.toCartMap(), 'quantity': quantity};
  }

  static CartItem fromMap(Map<String, dynamic> map) {
    return CartItem(
      book: Book.fromCartMap(map),
      quantity: map['quantity'] ?? 1,
    );
  }
}

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, CartItem> get items => Map.unmodifiable(_items);

  int get totalItems => _items.values.fold(0, (sum, item) => sum + item.quantity);

  double get totalPrice => _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  Future<void> addToCart(Book book) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final bookSnapshot = await _firestore.collection('books').doc(book.id).get();
    final int currentStock = bookSnapshot.data()?['quantity'] ?? 0;

    if (currentStock <= 0) {
      throw Exception('Book is out of stock');
    }

    if (_items.containsKey(book.id)) {
      final currentQuantity = _items[book.id]!.quantity;
      if (currentQuantity >= currentStock) {
        throw Exception('Only $currentStock in stock');
      }
      _items[book.id]!.quantity += 1;
    } else {
      _items[book.id] = CartItem(book: book, quantity: 1);
    }

    notifyListeners();
    await _saveCartToFirestore(user.uid);
  }

  Future<void> removeFromCart(String bookId) async {
    final user = _auth.currentUser;
    if (_items.containsKey(bookId)) {
      _items.remove(bookId);
      notifyListeners();
      if (user != null) {
        await _saveCartToFirestore(user.uid);
      }
    }
  }

  Future<void> updateQuantity(String bookId, int quantity) async {
    final user = _auth.currentUser;
    if (!_items.containsKey(bookId)) return;

    final bookRef = _firestore.collection('books').doc(bookId);
    final snapshot = await bookRef.get();
    final currentStock = snapshot.data()?['quantity'] ?? 0;

    if (quantity > currentStock) {
      Fluttertoast.showToast(msg: "Only $currentStock in stock", backgroundColor: Colors.red);
      return;
    }

    if (quantity <= 0) {
      await removeFromCart(bookId);
    } else {
      _items[bookId]!.quantity = quantity;
      notifyListeners();
      if (user != null) {
        await _saveCartToFirestore(user.uid);
      }
    }
  }


  Future<void> increaseQuantity(String bookId) async {
    if (!_items.containsKey(bookId)) return;
    int currentQty = _items[bookId]!.quantity;
    await updateQuantity(bookId, currentQty + 1);
  }

  Future<void> decreaseQuantity(String bookId) async {
    if (!_items.containsKey(bookId)) return;
    int currentQty = _items[bookId]!.quantity;
    await updateQuantity(bookId, currentQty - 1);
  }

  void clearLocalCartOnly() {
    _items.clear();
    notifyListeners();
  }

  Future<void> clearCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('carts').doc(user.uid).delete();
    }
    clearLocalCartOnly();
  }

  bool contains(String bookId) => _items.containsKey(bookId);

  int? getQuantity(String bookId) => _items[bookId]?.quantity;

  Future<void> loadCartFromFirestore() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cartDoc = await _firestore.collection('carts').doc(user.uid).get();
    if (cartDoc.exists) {
      final cartData = cartDoc.data();
      if (cartData != null && cartData['items'] is List) {
        _items.clear();
        for (var item in cartData['items']) {
          final cartItem = CartItem.fromMap(Map<String, dynamic>.from(item));
          _items[cartItem.book.id] = cartItem;
        }
        notifyListeners();
      }
    }
  }

  Future<void> _saveCartToFirestore(String userId) async {
    if (_items.isEmpty) return;

    final cartData = {
      'items': _items.values.map((item) => item.toMap()).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    await _firestore.collection('carts').doc(userId).set(cartData);
  }

  Future<void> reduceStockAfterOrder() async {
    for (var cartItem in _items.values) {
      final bookRef = _firestore.collection('books').doc(cartItem.book.id);
      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(bookRef);
        final currentData = snapshot.data() as Map<String, dynamic>;
        final currentQuantity = currentData['quantity'] ?? 0;

        final newQuantity = currentQuantity - cartItem.quantity;
        if (newQuantity < 0) {
          throw Exception('Stock inconsistency detected');
        }

        transaction.update(bookRef, {'quantity': newQuantity});
      });
    }
  }

  Future<void> clearCartAfterOrder() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('carts').doc(user.uid).delete();
      clearLocalCartOnly();
    }
  }
}
