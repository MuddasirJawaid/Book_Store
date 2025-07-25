// widgets/checkout_screen.dart
import 'package:prj/models/sales.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' as myAuth;
import '../providers/cart_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  bool isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _prefillForm();
  }

  void _prefillForm() {
    final userData =
        Provider.of<myAuth.AuthProvider>(context, listen: false).userData;
    if (userData != null) {
      nameController.text = userData['name'] ?? '';
      emailController.text = userData['email'] ?? '';
      phoneController.text = userData['phone'] ?? '';
      addressController.text = userData['address'] ?? '';
      cityController.text = userData['city'] ?? '';
      postalCodeController.text = userData['postalCode'] ?? '';
    }
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isPlacingOrder = true);

    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in.")),
      );
      return;
    }

    final orderData = {
      'userId': user.uid,
      'name': nameController.text,
      'email': emailController.text,
      'phone': phoneController.text,
      'address': addressController.text,
      'city': cityController.text,
      'postalCode': postalCodeController.text,
      'items': cartProvider.items.values.map((item) => {
            'id': item.book.id,
            'title': item.book.title,
            'price': item.book.price,
            'quantity': item.quantity,
            'subtotal': item.subtotal,
          }).toList(),
      'totalPrice': cartProvider.totalPrice,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'placed',
    };

    try {

      final orderRef =
          await FirebaseFirestore.instance.collection('orders').add(orderData);


      for (var item in cartProvider.items.values) {
        final bookRef =
            FirebaseFirestore.instance.collection('books').doc(item.book.id);

        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(bookRef);
          if (snapshot.exists) {
            final currentQuantity = snapshot['quantity'] ?? 0;
            final newQuantity = currentQuantity - item.quantity;
            transaction.update(
                bookRef, {'quantity': newQuantity < 0 ? 0 : newQuantity});
          }
        });
      }


      for (var item in cartProvider.items.values) {
        final sale = Sale(
          bookId: item.book.id,
          quantity: item.quantity,
          totalPrice: item.book.price * item.quantity,
          timestamp: DateTime.now(),
        );
        await Sale.recordSale(sale);
      }


      await cartProvider.clearCartFromFirestore();

      if (context.mounted) {
        Fluttertoast.showToast(
          msg: "Order placed successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' Failed to place order: $e')),
      );
    } finally {
      setState(() => isPlacingOrder = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Checkout"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Shipping Information",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTextField(controller: nameController, label: 'Full Name'),
              _buildTextField(controller: emailController, label: 'Email'),
              _buildTextField(controller: phoneController, label: 'Phone'),
              _buildTextField(controller: addressController, label: 'Address'),
              _buildTextField(controller: cityController, label: 'City'),
              _buildTextField(
                  controller: postalCodeController, label: 'Postal Code'),
              const SizedBox(height: 24),
              Text(
                'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.orange,
                ),
                child: isPlacingOrder
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("PLACE ORDER"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Required' : null,
      ),
    );
  }
}
