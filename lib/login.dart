import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:prj/admin/admin_dashboard.dart';
import 'package:prj/homescreen.dart';
import 'package:prj/registration.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:prj/providers/auth_provider.dart' as auth;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showForgotPasswordDialog() {
    final TextEditingController resetEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: resetEmailController,
          decoration: const InputDecoration(hintText: 'Enter your email'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          TextButton(
            child: const Text('Send'),
            onPressed: () async {
              String email = resetEmailController.text.trim();
              if (email.isEmpty || !email.contains('@')) {
                Fluttertoast.showToast(msg: "Enter a valid email");
                return;
              }
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                Fluttertoast.showToast(msg: "Reset link sent to $email");
              } catch (e) {
                Fluttertoast.showToast(msg: "Error: ${e.toString()}");
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<auth.AuthProvider>(
        builder: (context, authProvider, child) {
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFF8E7), Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 100),
                    // Logo
                    Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF1E2A38),
                      ),
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        children: const [
                          Icon(Icons.menu_book_rounded, color: Color(0xFFFFA500), size: 60),
                          SizedBox(height: 8),
                          Text(
                            'BOOK STORE',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Explore a World of Books',
                            style: TextStyle(
                              fontSize: 10,
                              color: Color(0xFFCCCCCC),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Form
                    Container(
                      width: 350,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (authProvider.errorMessage != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Text(
                                  authProvider.errorMessage!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ),
                            TextFormField(
                              controller: emailController,
                              decoration: _inputDecoration('Email', Icons.email),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => value == null || !value.contains('@')
                                  ? 'Enter valid email'
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.lock),
                                labelText: 'Password',
                                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) => value == null || value.length < 6
                                  ? 'Minimum 6 characters'
                                  : null,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _showForgotPasswordDialog,
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(fontSize: 13, color: Colors.blue),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            authProvider.isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                              width: 160,
                              height: 42,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                      context,
                                    );
                                  }
                                },
                                icon: const Icon(Icons.login, size: 18),
                                label: const Text(
                                  'Login',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Register link
                    TextButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => Center(
                            child: LoadingAnimationWidget.fourRotatingDots(
                              color: Colors.orange,
                              size: 50,
                            ),
                          ),
                        );

                        await Future.delayed(const Duration(seconds: 2));

                        Navigator.pop(context); // close loader
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationPage()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),

                    const SizedBox(height: 313),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20),
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

Future<void> login(String email, String password, BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Center(
      child: LoadingAnimationWidget.fourRotatingDots(
        color: Colors.orange,
        size: 50,
      ),
    ),
  );

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    Fluttertoast.showToast(msg: "Login Successful");

    Navigator.pop(context); // Close loading dialog

    if (email == 'admin@gmail.com' && password == '123123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboard()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  } catch (e) {
    Navigator.pop(context); // Close loading dialog
    Fluttertoast.showToast(msg: "Login Failed: $e");
    log(e.toString());
  }
}
