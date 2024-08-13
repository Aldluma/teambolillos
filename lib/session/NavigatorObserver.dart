import 'dart:async';
import 'package:flutter/material.dart';

class InactivityObserver extends NavigatorObserver {
  late Timer _timer;
  static const int _inactiveTimeInSeconds = 180;

  InactivityObserver() {
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: _inactiveTimeInSeconds), _onInactivity);
  }

  void _resetTimer() {
    _timer.cancel();
    _startTimer();
  }

  void _onInactivity() {
    // Acción que deseas realizar después del tiempo de inactividad, como cerrar sesión
    print("Sesión expirada por inactividad");
    // Aquí puedes navegar a la pantalla de inicio de sesión o cerrar la sesión
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
