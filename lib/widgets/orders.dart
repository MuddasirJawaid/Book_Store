import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final Set<String> _reviewedOrders = {};

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A38),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book, color: Color(0xFFFF9800), size: 26),
            SizedBox(width: 8),
            Text(
              'BOOK STORE',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: user!.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!.docs;
          if (orders.isEmpty) return const Center(child: Text("No orders found."));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final orderData = doc.data() as Map<String, dynamic>;
              final orderId = doc.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 24),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOrderStepper(context, orderData, orderId),
                      const SizedBox(height: 12),
                      _buildOrderInfoCard(orderData),
                      const SizedBox(height: 12),
                      _buildOrderedItemsList(orderData),
                      const Divider(),
                      _buildTotalPrice(orderData),
                      const SizedBox(height: 10),
                      _buildCancelOrderButton(orderId, orderData),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderStepper(BuildContext context, Map<String, dynamic> orderData, String orderId) {
    String status = orderData['status'] ?? 'placed';
    int currentStep = switch (status) {
      'placed' => 0,
      'dispatched' => 1,
      'on the way' => 2,
      'delivered' => 3,
      _ => 0,
    };

    if (status == 'delivered' && !_reviewedOrders.contains(orderId)) {
      _reviewedOrders.add(orderId);
      List<dynamic> items = orderData['items'] ?? [];

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        for (var item in items) {
          String bookId = item['id'];
          String title = item['title'];
          bool alreadyReviewed = await checkIfAlreadyReviewed(bookId);
          if (!alreadyReviewed) {
            showRatingReviewSheet(context, bookId, title);
          }
        }
      });
    }

    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: Theme.of(context).colorScheme.copyWith(primary: Colors.orange),
      ),
      child: Stepper(
        type: StepperType.vertical,
        currentStep: currentStep,
        physics: const ClampingScrollPhysics(),
        controlsBuilder: (context, details) => const SizedBox(),
        steps: const [
          Step(title: Text("Order Placed"), content: Text("Your order has been placed."), isActive: true),
          Step(title: Text("Dispatched"), content: Text("Your order has been dispatched."), isActive: true),
          Step(title: Text("On the Way"), content: Text("Your order is on the way."), isActive: true),
          Step(title: Text("Delivered"), content: Text("Your order has been delivered."), isActive: true),
        ],
      ),
    );
  }

  Widget _buildOrderInfoCard(Map<String, dynamic> orderData) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${orderData['name'] ?? ''}", style: const TextStyle(fontSize: 16)),
            Text("Phone: ${orderData['phone'] ?? ''}", style: const TextStyle(fontSize: 16)),
            Text("Email: ${orderData['email'] ?? ''}", style: const TextStyle(fontSize: 16)),
            Text("Address: ${orderData['address'] ?? ''}", style: const TextStyle(fontSize: 16)),
            Text("City: ${orderData['city'] ?? ''}", style: const TextStyle(fontSize: 16)),
            Text("Postal Code: ${orderData['postalCode'] ?? ''}", style: const TextStyle(fontSize: 16)),
            if (orderData['timestamp'] != null)
              Text(
                "Order Date: ${DateTime.fromMillisecondsSinceEpoch(orderData['timestamp'].millisecondsSinceEpoch)}",
                style: const TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderedItemsList(Map<String, dynamic> orderData) {
    List<dynamic> items = orderData['items'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Ordered Items:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...items.map((item) {
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.orange),
              title: Text(item['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Quantity: ${item['quantity']}, Price: \$ ${item['price']}"),
              trailing: Text("\$ ${item['subtotal']}", style: const TextStyle(color: Colors.orange)),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTotalPrice(Map<String, dynamic> orderData) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        "Total Price: \$ ${orderData['totalPrice'] ?? 0}",
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange),
      ),
    );
  }

  Widget _buildCancelOrderButton(String orderId, Map<String, dynamic> orderData) {
    final status = orderData['status'] ?? 'placed';
    if (status == 'placed' || status == 'dispatched') {
      return Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Cancel Order"),
                content: const Text("Are you sure you want to cancel this order?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Yes")),
                ],
              ),
            );
            if (confirm == true) {
              await FirebaseFirestore.instance.collection('orders').doc(orderId).update({'status': 'cancelled'});
              Fluttertoast.showToast(
                msg: "order cancel Successful",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
              );
            }
          },
          icon: const Icon(Icons.cancel, color: Colors.red),
          label: const Text("Cancel Order", style: TextStyle(color: Colors.red)),
        ),
      );
    }
    return const SizedBox();
  }

  Future<bool> checkIfAlreadyReviewed(String bookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    final doc = await FirebaseFirestore.instance
        .collection('books')
        .doc(bookId)
        .collection('ratings')
        .doc(user.uid)
        .get();

    return doc.exists;
  }

  void showRatingReviewSheet(BuildContext context, String bookId, String bookTitle) {
    double userRating = 0;
    TextEditingController reviewController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Rate & Review", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(bookTitle, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < userRating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 32,
                        ),
                        onPressed: () {
                          setState(() {
                            userRating = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: reviewController,
                    decoration: const InputDecoration(
                      labelText: "Write a review",
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null && userRating > 0) {
                        await FirebaseFirestore.instance
                            .collection('books')
                            .doc(bookId)
                            .collection('ratings')
                            .doc(user.uid)
                            .set({
                          'rating': userRating,
                          'review': reviewController.text.trim(),
                          'userId': user.uid,
                          'timestamp': FieldValue.serverTimestamp(),
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Thanks for your review!")),
                        );
                      }
                    },
                    child: const Text("Submit"),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
