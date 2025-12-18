import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:travelin/services/user_service.dart';
import 'package:travelin/widgets/custom_input_field.dart';
import 'package:travelin/widgets/custom_flushbar.dart';
import 'package:travelin/widgets/role_dropdown.dart';
import 'package:travelin/utils/handler/UserMaster/error_handler.dart';

class AddUserModal extends StatefulWidget {
  final VoidCallback onUserAdded;

  const AddUserModal({super.key, required this.onUserAdded});

  @override
  State<AddUserModal> createState() => _AddUserModalState();
}

class _AddUserModalState extends State<AddUserModal> {
  final usernameController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  String? selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    usernameController.dispose();
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAddUser() async {
    // Validation
    if (usernameController.text.isEmpty ||
        nameController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedRole == null) {
      CustomFlushbar.show(
        context,
        message: "All fields must be filled",
        type: FlushbarType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await UserService.createUser({
        'username': usernameController.text,
        'name': nameController.text,
        'password': passwordController.text,
        'role': selectedRole!,
      });

      if (!mounted) return;

      CustomFlushbar.show(
        context,
        message: "User added successfully",
        type: FlushbarType.success,
      );

      Navigator.pop(context);

      // Delay callback to avoid navigator lock
      await Future.delayed(const Duration(milliseconds: 100));
      widget.onUserAdded();
    } catch (e) {
      if (!mounted) return;

      CustomFlushbar.show(
        context,
        message: UserMasterErrorHandler.parseErrorMessage(e.toString()),
        type: FlushbarType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Add User",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: "Username",
              hint: "Enter username",
              icon: FontAwesomeIcons.user,
              controller: usernameController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: "Name",
              hint: "Enter full name",
              icon: FontAwesomeIcons.signature,
              controller: nameController,
            ),
            const SizedBox(height: 12),
            CustomInputField(
              label: "Password",
              hint: "Enter password",
              icon: FontAwesomeIcons.lock,
              controller: passwordController,
              obscure: true,
            ),
            const SizedBox(height: 12),
            RoleDropdown(
              label: "Role",
              selectedRole: selectedRole,
              onRoleChanged: (role) {
                setState(() {
                  selectedRole = role;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleAddUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  disabledBackgroundColor: Colors.grey,
                ),
                child:
                    _isLoading
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                        : const Text(
                          "Add User",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
