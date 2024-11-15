// providers/scan_provider.dart
import 'package:flutter/material.dart';
import 'dart:io';

class ScanProvider extends ChangeNotifier {
  File? _selectedImage;
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _scanResult;

  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get scanResult => _scanResult;

  void setImage(File image) {
    _selectedImage = image;
    _error = null;
    notifyListeners();
  }

  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void setScanResult(Map<String, dynamic> result) {
    _scanResult = result;
    notifyListeners();
  }

  void reset() {
    _selectedImage = null;
    _isLoading = false;
    _error = null;
    _scanResult = null;
    notifyListeners();
  }
}
