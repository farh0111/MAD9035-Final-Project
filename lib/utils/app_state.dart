import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AppState with ChangeNotifier {
  String? _deviceId; 
  String? _sessionId; 
  final SharedPreferences
      _prefs; // shared preferences instance for persistent storage

  
  AppState(this._prefs) {
    _deviceId =
        _prefs.getString('device_id'); 
    _sessionId = _prefs
        .getString('session_id');
  }

  // getter for device id
  String? get deviceId => _deviceId;
  // getter for session id
  String? get sessionId => _sessionId;

  // method to set device id
  void setDeviceId(String id) {
    _deviceId = id;
    _prefs.setString('device_id', id);
    notifyListeners(); // notify listeners about the change
  }

  // method to set session id and save it in shared preferences
  void setSessionId(String id) {
    _sessionId = id;
    _prefs.setString('session_id', id);
    notifyListeners(); // notify listeners about the change
  }
}
