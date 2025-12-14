import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hint;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback? onToggleVisibility;

  const CustomInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.hint,
    required this.controller,
    this.obscure = false,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 14
          ),
        ),

        const SizedBox(height: 6),

        TextField(
          controller: controller,
          obscureText: obscure,
          style: TextStyle(fontSize: 12),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade200,
            prefixIcon: Icon(icon, size: 20),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            suffixIcon: onToggleVisibility != null
                ? IconButton(
              icon: Icon(
                obscure
                    ? FontAwesomeIcons.eyeSlash
                    : FontAwesomeIcons.eye,
                size: 16,
              ),
              onPressed: onToggleVisibility,
            )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(12)
          ),
        ),
      ],
    );
  }
}