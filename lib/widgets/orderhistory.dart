// widgets/orderhistory.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('📖 My Orders'),
        backgroundColor: const Color(0xFF1E2A38),
        foregroundColor: Color(0xFFFFF8E7),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('userId', isEqualTo: currentUser?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('You have no orders yet.'));

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final data = orders[index].data() as Map<String, dynamic>;
              final status = data['status'] ?? 'placed';
              final items = data['items'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('📦 Order Summary', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...items.map((item) => Text(
                            '📘 ${item['title']} x${item['quantity']} - Rs ${item['subtotal'].toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14),
                          )),
                      const Divider(),
                      Text('💰 Total: \$ ${data['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text(
                        '📌 Status: ${status[0].toUpperCase()}${status.substring(1)}',
                        style: TextStyle(
                          color: status == 'delivered' ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: _getProgress(status),
                        backgroundColor: Colors.grey.shade300,
                        color: status == 'delivered' ? Colors.green : Colors.orange,
                      ),
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

  double _getProgress(String status) {
    switch (status) {
      case 'placed':
        return 0.25;
      case 'dispatched':
        return 0.50;
      case 'on the way':
        return 0.75;
      case 'delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }
}
