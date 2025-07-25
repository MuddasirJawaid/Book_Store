// admin/adminorders.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  Future<void> _updateStatus(String orderId, String currentStatus) async {
    String newStatus;
    if (currentStatus == 'placed') {
      newStatus = 'dispatched';
    } else if (currentStatus == 'dispatched') {
      newStatus = 'on the way';
    } else if (currentStatus == 'on the way') {
      newStatus = 'delivered';
    } else {
      return;
    }

    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'status': newStatus,
    });
  }

  String _getNextStatusLabel(String status) {
    switch (status) {
      case 'placed':
        return 'Dispatch';
      case 'dispatched':
        return 'On The Way';
      case 'on the way':
        return 'Delivered';
      default:
        return '';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 30, 42, 56),
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 248, 231)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book, color: Color.fromARGB(255, 255, 152, 0), size: 28),
            SizedBox(width: 8),
            Text(
              'ORDER MANAGEMENT',
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
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
            return const Center(child: Text('No orders found.'));

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;
              final status = data['status'] ?? 'placed';

              final userInfo = '''
 Name: ${data['name'] ?? ''}
 Phone: ${data['phone'] ?? ''}
 Email: ${data['email'] ?? ''}
Address: ${data['address'] ?? ''}, ${data['city'] ?? ''}, ${data['postalCode'] ?? ''}
''';

              final items = data['items'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.all(12),
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userInfo, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 10),
                      const Text('🛒 Ordered Books:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '📘 ${item['title']} x${item['quantity']} - \$ ${item['subtotal']?.toStringAsFixed(2) ?? '0.00'}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        );
                      }).toList(),
                      const Divider(),
                      Text(
                        '💰 Total: \$ ${data['totalPrice']?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '📦 Status: ${status[0].toUpperCase()}${status.substring(1)}',
                            style: TextStyle(
                              color: _getStatusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (status == 'delivered')
                            const Icon(Icons.check_circle, color: Colors.green, size: 24)
                          else if (status == 'cancelled')
                            const Icon(Icons.cancel, color: Colors.red, size: 24)
                          else
                            ElevatedButton(
                              onPressed: () => _updateStatus(order.id, status),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E2A38),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                              ),
                              child: Text(
                                _getNextStatusLabel(status),
                                style: const TextStyle(color: Color(0xFFFFF8E7)),
                              ),
                            ),
                        ],
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
}
