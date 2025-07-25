import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:prj/login.dart';
import 'package:prj/providers/auth_provider.dart' as auth;

class RegistrationPage extends StatelessWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();
    final cityController = TextEditingController();
    final postalCodeController = TextEditingController();

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
                    const SizedBox(height: 40),
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
                    const SizedBox(height: 30),
                    Container(
                      width: 350,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Form(
                        key: formKey,
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
                              controller: nameController,
                              decoration: _inputDecoration('Full Name', Icons.person),
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Enter your name' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: emailController,
                              decoration: _inputDecoration('Email', Icons.email),
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) =>
                              value == null || !value.contains('@') ? 'Enter a valid email' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: passwordController,
                              decoration: _inputDecoration('Password', Icons.lock),
                              obscureText: true,
                              validator: (value) =>
                              value == null || value.length < 6 ? 'Minimum 6 characters' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: phoneController,
                              decoration: _inputDecoration('Phone Number', Icons.phone),
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                              value == null || value.length < 10 ? 'Enter a valid number' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: addressController,
                              decoration: _inputDecoration('Address', Icons.home),
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Enter address' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: cityController,
                              decoration: _inputDecoration('City', Icons.location_city),
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Enter city' : null,
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: postalCodeController,
                              decoration: _inputDecoration('Postal Code', Icons.markunread_mailbox),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                              value == null || value.isEmpty ? 'Enter postal code' : null,
                            ),
                            const SizedBox(height: 20),
                            authProvider.isLoading
                                ? const CircularProgressIndicator()
                                : SizedBox(
                              width: 160,
                              height: 42,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () async {
                                  if (formKey.currentState?.validate() ?? false) {
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

                                    bool success = await authProvider.register(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                      name: nameController.text.trim(),
                                      phone: phoneController.text.trim(),
                                      address: addressController.text.trim(),
                                      city: cityController.text.trim(),
                                      postalCode: postalCodeController.text.trim(),
                                      context: context,
                                    );

                                    Navigator.pop(context); // Close the loading dialog

                                    if (success) {
                                      Fluttertoast.showToast(
                                        msg: "Registration successful!",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: Colors.orange,
                                        textColor: Colors.white,
                                        fontSize: 16.0,
                                      );
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LoginPage()),
                                      );
                                    }
                                  }

                                },
                                icon: const Icon(Icons.check_circle_outline, size: 18),
                                label: const Text(
                                  'Register',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 100),
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
