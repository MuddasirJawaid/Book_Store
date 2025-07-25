import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_provider.dart';
import 'wishlist_provider.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic>? _userData;

  AuthProvider();

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get userData => _userData;
  User? get user => _auth.currentUser;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<void> fetchUserData() async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _userData = doc.data();
        notifyListeners();
      }
    }
  }

  Future<bool> login(String email, String password, BuildContext context) async {
    _setLoading(true);
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await fetchUserData();

      await Provider.of<CartProvider>(context, listen: false).loadCartFromFirestore();
      await Provider.of<WishlistProvider>(context, listen: false).loadWishlist();

      _setErrorMessage(null);
      return true;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
    } catch (_) {
      _setErrorMessage('An unknown error occurred');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String city,
    required String postalCode,
    required BuildContext context,
  }) async {
    _setLoading(true);
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'city': city,
        'postalCode': postalCode,
        'gender': '',
        'dateOfBirth': '',
        'country': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchUserData();

      _setErrorMessage(null);
      return true;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
    } catch (_) {
      _setErrorMessage('An unknown error occurred');
    } finally {
      _setLoading(false);
    }
    return false;
  }

  Future<void> updateUserData(Map<String, dynamic> newData) async {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('users').doc(uid).update(newData);
      await fetchUserData();
    }
  }

  Future<void> logout(BuildContext context) async {
    // Clear locally stored data
    Provider.of<CartProvider>(context, listen: false).clearLocalCartOnly();
    Provider.of<WishlistProvider>(context, listen: false).clearLocalWishlistOnly();

    _userData = null;
    notifyListeners();

    await _auth.signOut();
  }

  /// 🔐 Forgot Password Functionality
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setErrorMessage(null);
      return true;
    } on FirebaseAuthException catch (e) {
      _setErrorMessage(e.message);
    } catch (_) {
      _setErrorMessage('An unknown error occurred');
    } finally {
      _setLoading(false);
    }
    return false;
  }
}
