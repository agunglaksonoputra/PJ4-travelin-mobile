import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/auth_helper.dart';
import '../../widgets/bottom_navbar.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Admin",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
            child: Column(
              children: [
                _adminMenuCard(
                  icon: FontAwesomeIcons.users,
                  title: "User Management",
                  subtitle: "Kelola data pengguna",
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/users');
                  },
                ),
                const SizedBox(height: 10),
                _adminMenuCard(
                  icon: FontAwesomeIcons.car,
                  title: "Vehicle Management",
                  subtitle: "Kelola data kendaraan",
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/vehicles');
                  },
                ),
                const SizedBox(height: 10),
                _adminMenuCard(
                  icon: FontAwesomeIcons.userTag,
                  title: "Owner Management",
                  subtitle: "Kelola data owner",
                  onTap: () {
                    Navigator.pushNamed(context, '/admin/owners');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Report
        role: AuthHelper.currentRole,
        onTap: (i) {
          switch (i) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;

            case 1:
              Navigator.pushReplacementNamed(context, '/actual');
              break;

            case 2:
            // already on report
              break;
          }
        },
      ),

    );
  }

  Widget _adminMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE6F0FF),
          child: Icon(icon, color: Colors.blue, size: 18),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(FontAwesomeIcons.angleRight, size: 18),
      ),
    );
  }
}