import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum FlushbarType { success, error, warning, info }

class CustomFlushbar {
  static void show(
      BuildContext context, {
        required String message,
        FlushbarType type = FlushbarType.info,
        Duration duration = const Duration(seconds: 3),
      }) {
    final data = _getFlushbarData(type);

    Flushbar(
      messageText: Row(
        children: [
          Icon(
            data.icon,
            color: Colors.white,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: data.backgroundColor,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      duration: duration,
      flushbarPosition: FlushbarPosition.BOTTOM,
      flushbarStyle: FlushbarStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 400),
      isDismissible: true,
      shouldIconPulse: false,
    ).show(context);
  }

  static _FlushbarData _getFlushbarData(FlushbarType type) {
    switch (type) {
      case FlushbarType.success:
        return _FlushbarData(
          backgroundColor: Colors.green,
          icon: FontAwesomeIcons.circleCheck,
        );
      case FlushbarType.error:
        return _FlushbarData(
          backgroundColor: Colors.red,
          icon: FontAwesomeIcons.circleXmark,
        );
      case FlushbarType.warning:
        return _FlushbarData(
          backgroundColor: Colors.orange,
          icon: FontAwesomeIcons.triangleExclamation,
        );
      case FlushbarType.info:
      default:
        return _FlushbarData(
          backgroundColor: Colors.blue,
          icon: FontAwesomeIcons.circleInfo,
        );
    }
  }
}

class _FlushbarData {
  final Color backgroundColor;
  final IconData icon;

  _FlushbarData({
    required this.backgroundColor,
    required this.icon,
  });
}
