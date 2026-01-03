import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RoleDropdown extends StatefulWidget {
  final String label;
  final String? selectedRole;
  final ValueChanged<String> onRoleChanged;
  final List<String>? customRoles;
  final bool isRequired;

  const RoleDropdown({
    super.key,
    required this.label,
    this.selectedRole,
    required this.onRoleChanged,
    this.customRoles,
    this.isRequired = true,
  });

  @override
  State<RoleDropdown> createState() => _RoleDropdownState();
}

class _RoleDropdownState extends State<RoleDropdown> {
  late String? _selectedRole;
  late List<String> _availableRoles;

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.selectedRole;
    _availableRoles = widget.customRoles ?? ['admin', 'staff', 'owner'];
  }

  @override
  void didUpdateWidget(RoleDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedRole != oldWidget.selectedRole) {
      _selectedRole = widget.selectedRole;
    }
    if (widget.customRoles != oldWidget.customRoles) {
      _availableRoles = widget.customRoles ?? ['admin', 'staff', 'owner'];
    }
  }

  String _formatRoleLabel(String role) {
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: widget.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              if (widget.isRequired)
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!, width: 1.5),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: DropdownButton<String>(
            value: _selectedRole,
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRole = newValue;
                });
                widget.onRoleChanged(newValue);
              }
            },
            underline: const SizedBox(), // Remove default underline
            isExpanded: true,
            dropdownColor: Colors.white,
            hint: Row(
              children: [
                Icon(
                  FontAwesomeIcons.userTie,
                  size: 14,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 12),
                Text(
                  'Select a role',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
            items:
                _availableRoles.map((String role) {
                  return DropdownMenuItem<String>(
                    value: role,
                    child: Row(
                      children: [
                        Icon(
                          FontAwesomeIcons.userTie,
                          size: 14,
                          color: _getRoleColor(role),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatRoleLabel(role),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _getRoleColor(role),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            selectedItemBuilder: (BuildContext context) {
              return _availableRoles.map((String role) {
                return Row(
                  children: [
                    Icon(
                      FontAwesomeIcons.userTie,
                      size: 14,
                      color: _getRoleColor(role),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _formatRoleLabel(role),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _getRoleColor(role),
                      ),
                    ),
                  ],
                );
              }).toList();
            },
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red[700]!;
      case 'staff':
        return Colors.blue[700]!;
      case 'owner':
        return Colors.green[700]!;
      default:
        return Colors.grey[700]!;
    }
  }
}
