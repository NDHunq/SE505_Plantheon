import 'package:flutter/material.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  static NavigationService get instance => _instance;

  Function(int)? _onTabChanged;

  void setTabChangeCallback(Function(int) callback) {
    _onTabChanged = callback;
  }

  void changeTab(int tabIndex) {
    _onTabChanged?.call(tabIndex);
  }

  void removeCallback() {
    _onTabChanged = null;
  }
}
