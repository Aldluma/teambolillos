// lib/session/inactivity_observer.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InactivityObserver extends NavigatorObserver {
  Timer? _inactivityTimer;
  final Duration _timeoutDuration = Duration(minutes: 3);
  
  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(_timeoutDuration, () {
      // Cierra sesión al alcanzar el tiempo de inactividad
      FirebaseAuth.instance.signOut();
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _resetTimer();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _resetTimer();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _resetTimer();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _resetTimer();
  }
}
