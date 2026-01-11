import 'package:flutter/material.dart';

class BottomNavController {
  static Future<void> onItemTapped({
    required BuildContext context,
    required int index,
    required Function(int) onIndexChanged,
  }) async {
    onIndexChanged(index);

    final currentRoute = ModalRoute.of(context)?.settings.name;

    String? targetRoute;

    switch (index) {
      case 0:
        targetRoute = '/home';
        break;
      case 1:
        targetRoute = '/actual';
        break;
      case 2:
        targetRoute = '/report';
        break;
      case 3:
        targetRoute = '/admin';
        break;
    }

    if (targetRoute == null || currentRoute == targetRoute) return;

    Navigator.pushReplacementNamed(context, targetRoute);
  }
}
