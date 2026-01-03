import 'package:flutter/material.dart';
import 'status_picker_item.dart';

class StatusPickerBottomSheet {
  static void show({
    required BuildContext context,
    required String current,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatusPickerItem(
                  label: "Active",
                  value: "active",
                  current: current,
                  onSelected: onSelected,
                ),
                StatusPickerItem(
                  label: "Inactive",
                  value: "inactive",
                  current: current,
                  onSelected: onSelected,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
