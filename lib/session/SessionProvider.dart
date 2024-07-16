import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionProvider extends ChangeNotifier {
  Timer? _timer;
  final int _timeout = 60; // Tiempo de inactividad en segundos

  SessionProvider() {
    _initializeTimer();
  }

  void _initializeTimer() {
    _timer = Timer.periodic(Duration(seconds: _timeout), (_) {
      // Cerrar sesión automáticamente después de _timeout segundos de inactividad
      _logoutUser();
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _initializeTimer();
  }

  void _logoutUser() {
    FirebaseAuth.instance.signOut();
    _timer?.cancel();
    // Limpiar información de sesión almacenada
    _clearSessionData();
    notifyListeners();
  }

  Future<void> _clearSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  void userInteractionDetected() {
    _resetTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
