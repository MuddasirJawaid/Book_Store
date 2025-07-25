// providers/connectivity_provider.dart
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityProvider with ChangeNotifier {
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _startMonitoring();
  }

  void _startMonitoring() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    } as void Function(List<ConnectivityResult> event)?);

    // Initial check
    Connectivity().checkConnectivity().then((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }
}
