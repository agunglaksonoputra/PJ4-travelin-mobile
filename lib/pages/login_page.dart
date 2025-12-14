import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelin/widgets/input_field.dart';
import '../services/auth_service.dart';
import '../widgets/custom_flushbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService(); // <-- instance AuthService
  bool isLoading = false;
  bool isPasswordHidden = true;

  Future<void> handleLogin() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      CustomFlushbar.show(
        context,
        message: "Semua field wajib diisi",
        type: FlushbarType.warning,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await authService.login(username, password);

      setState(() => isLoading = false);

      if (user != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("Id", user.id);
        await prefs.setString("username", user.username);
        await prefs.setString("role", user.role);

        CustomFlushbar.show(
          context,
          message: "Login berhasil",
          type: FlushbarType.success,
        );

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/home');
        });

      } else {
        CustomFlushbar.show(
          context,
          message: "Username atau password salah",
          type: FlushbarType.error,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      CustomFlushbar.show(
        context,
        message: "Terjadi kesalahan: ${e.toString()}",
        type: FlushbarType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.directions_bus, size: 100, color: Colors.teal),
              const SizedBox(height: 10),
              const Text(
                'Travelin',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),

              const SizedBox(height: 40),

              InputField(
                  label: "Username",
                  icon: FontAwesomeIcons.envelope,
                  hint: "Enter your username",
                  controller: usernameController
              ),

              const SizedBox(height: 12),

              InputField(
                label: "Password",
                icon: FontAwesomeIcons.lock,
                hint: "Enter your password",
                controller: passwordController,
                obscure: isPasswordHidden,
                onToggleVisibility: () {
                  setState(() {
                    isPasswordHidden = !isPasswordHidden;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: isLoading ? null : handleLogin,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    'LOGIN',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/signup'),
                child: const Text(
                  "Don't have an account? Register here",
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
