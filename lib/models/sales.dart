// models/sales.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Sale {
  final String bookId;
  final int quantity;
  final double totalPrice;
  final DateTime timestamp;

  Sale({
    required this.bookId,
    required this.quantity,
    required this.totalPrice,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  static Future<void> recordSale(Sale sale) async {
    await FirebaseFirestore.instance.collection('sales').add(sale.toMap());
  }
}
