import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelin/models/user_models.dart';
import 'package:travelin/services/user_service.dart';

import '../../widgets/vehicle_detail_row.dart';
import '../../widgets/custom_flushbar.dart';
import '../../widgets/form/UserMaster/add_user_modal.dart';
import '../../widgets/form/UserMaster/update_user_modal.dart';
import '../../widgets/form/UserMaster/delete_user_confirmation.dart';

class UserMasterPage extends StatefulWidget {
  const UserMasterPage({super.key});

  @override
  State<UserMasterPage> createState() => _UserMasterPageState();
}

class _UserMasterPageState extends State<UserMasterPage> {
  List<UserModel> _users = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _getCurrentUserId();
    _loadUsers();
  }

  Future<void> _getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUserId = prefs.getString("Id");
    });
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await UserService.getAllUsers();
      if (!mounted) return;
      setState(() {
        _users = data;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "User Management",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.blue),
                )
                : _errorMessage != null
                ? _buildErrorState()
                : _users.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                  onRefresh: _loadUsers,
                  color: Colors.blue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                      child: Column(
                        children:
                            _users.map((users) {
                              return _userCard(users);
                            }).toList(),
                      ),
                    ),
                  ),
                ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 8),
        child: SizedBox(
          width: 50,
          height: 50,
          child: FloatingActionButton(
            backgroundColor: Colors.blue,
            elevation: 5,
            shape: const CircleBorder(),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (_) => AddUserModal(onUserAdded: _loadUsers),
              );
            },
            child: const Icon(
              FontAwesomeIcons.add,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _userCard(UserModel user) {
    return Card(
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => _showusersDetail(user),
        leading: const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(FontAwesomeIcons.user, color: Colors.white, size: 16),
        ),
        title: Text(
          "${user.username}",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(user.role),
        trailing: const Icon(FontAwesomeIcons.angleRight, size: 18),
      ),
    );
  }

  void _showusersDetail(UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail User",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              VehicleDetailRow(label: "Username", value: user.username),
              VehicleDetailRow(label: "Name", value: user.name),
              VehicleDetailRow(label: "Role", value: user.role),
              VehicleDetailRow(
                label: "Status",
                value: user.isActive ? "Active" : "Inactive",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                          ),
                          builder:
                              (_) => UpdateUserModal(
                                user: user,
                                onUserUpdated: _loadUsers,
                              ),
                        );
                      },
                      icon: const Icon(
                        FontAwesomeIcons.pencil,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Edit",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed:
                          _currentUserId == user.id
                              ? null
                              : () {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder:
                                      (_) => DeleteUserConfirmation(
                                        user: user,
                                        onUserDeleted: _loadUsers,
                                      ),
                                );
                              },
                      icon: const Icon(
                        FontAwesomeIcons.trashCan,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _currentUserId == user.id
                                ? Colors.grey
                                : Colors.red,
                        disabledBackgroundColor: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              FontAwesomeIcons.circleExclamation,
              size: 48,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Users',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _loadUsers,
              icon: const Icon(FontAwesomeIcons.rotateRight),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(FontAwesomeIcons.users, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No Users Found',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Start by adding a new user',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
