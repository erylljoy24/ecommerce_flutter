import 'package:flutter/foundation.dart';

class ChangeNotifierConnection with ChangeNotifier, DiagnosticableTreeMixin {
  bool _isConnected = true;
  bool _hasError = false;

  int _statusCode = 200;

  void setOnline(bool isConnected) {
    _isConnected = isConnected;
    notifyListeners();
  }

  bool isOnline() {
    return _isConnected;
  }

  void setError(bool hasError) {
    _hasError = hasError;
    notifyListeners();
  }

  bool hasError() {
    return _hasError;
  }

  void setStatusCode(int statusCode) {
    _statusCode = statusCode;
    notifyListeners();
  }

  int getStatusCode() {
    return _statusCode;
  }
}
