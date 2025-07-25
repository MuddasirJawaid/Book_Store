// admin/admin_order_history.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrderHistoryScreen extends StatelessWidget {
  const AdminOrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 42, 56),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 248, 231)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book, color: Color.fromARGB(255, 255, 152, 0), size: 28),
            SizedBox(width: 8),
            Text(
              'DELIVERED ORDERS',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 248, 231),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', isEqualTo: 'delivered')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text('No delivered orders found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Name: ${orderData['name'] ?? ''}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text("Email: ${orderData['email'] ?? ''}"),
                      const SizedBox(height: 6),
                      Text("Phone: ${orderData['phone'] ?? ''}"),
                      const SizedBox(height: 6),
                      Text("Address: ${orderData['address'] ?? ''}, ${orderData['city'] ?? ''}, ${orderData['postalCode'] ?? ''}"),
                      const SizedBox(height: 6),
                      Text("Total Price: \$ ${orderData['totalPrice'] ?? 0}", style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        "Delivered On: ${DateTime.fromMillisecondsSinceEpoch(orderData['timestamp'].millisecondsSinceEpoch)}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const Divider(height: 20),
                      const Text(
                        "Items:",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      ...List.generate((orderData['items'] as List).length, (i) {
                        final item = orderData['items'][i];
                        return ListTile(
                          leading: const Icon(Icons.book, color: Colors.orange),
                          title: Text(item['title']),
                          subtitle: Text("Qty: ${item['quantity']} × \$ ${item['price']}"),
                          trailing: Text("\$ ${item['subtotal']}", style: const TextStyle(color: Colors.orange)),
                        );
                      }),
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
}
