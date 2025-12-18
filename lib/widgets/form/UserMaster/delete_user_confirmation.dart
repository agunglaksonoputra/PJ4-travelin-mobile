import 'package:flutter/material.dart';
import 'package:travelin/models/user_models.dart';
import 'package:travelin/services/user_service.dart';
import 'package:travelin/widgets/custom_flushbar.dart';
import 'package:travelin/utils/handler/UserMaster/error_handler.dart';

class DeleteUserConfirmation extends StatefulWidget {
  final UserModel user;

  const DeleteUserConfirmation({super.key, required this.user});

  @override
  State<DeleteUserConfirmation> createState() => _DeleteUserConfirmationState();
}

class _DeleteUserConfirmationState extends State<DeleteUserConfirmation> {
  bool _isLoading = false;

  Future<void> _handleDeleteUser() async {
    setState(() => _isLoading = true);

    try {
      await UserService.deleteUser(widget.user.id);

      if (!mounted) return;

      // Pop with return value true = user successfully deleted
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;

      CustomFlushbar.show(
        context,
        message: UserMasterErrorHandler.parseErrorMessage(e.toString()),
        type: FlushbarType.error,
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text("Delete User"),
      content: Text("Are you sure you want to delete ${widget.user.username}?"),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel", style: TextStyle(color: Colors.black)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            disabledBackgroundColor: Colors.grey,
          ),
          onPressed: _isLoading ? null : _handleDeleteUser,
          child:
              _isLoading
                  ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                  : const Text("Delete", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
