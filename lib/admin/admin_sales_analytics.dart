// admin/admin_sales_analytics.dart
// admin/admin_sales_analytics.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pie_chart/pie_chart.dart';

class AdminSalesAnalytics extends StatefulWidget {
  @override
  State<AdminSalesAnalytics> createState() => _AdminSalesAnalyticsState();
}

class _AdminSalesAnalyticsState extends State<AdminSalesAnalytics> {
  Map<String, double> salesData = {};
  double totalRevenue = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchSalesData();
  }

  Future<void> fetchSalesData() async {
    Map<String, double> tempSales = {};
    double revenue = 0;

    final salesSnapshot = await FirebaseFirestore.instance.collection('sales').get();

    for (var doc in salesSnapshot.docs) {
      final data = doc.data();
      final bookId = data['bookId'];
      final quantity = data['quantity'] ?? 0;
      final totalPrice = (data['totalPrice'] ?? 0).toDouble();

      revenue += totalPrice;

      // Fetch book title from 'books' collection using bookId
      final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
      final bookTitle = bookDoc.exists ? (bookDoc.data()?['title'] ?? 'Unknown') : 'Unknown';

      tempSales[bookTitle] = (tempSales[bookTitle] ?? 0) + quantity.toDouble();
    }

    setState(() {
      salesData = tempSales;
      totalRevenue = revenue;
      isLoading = false;
    });
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
              'SALES',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 248, 231),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFA500),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Total Revenue Earned:',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${totalRevenue.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 22,
                              color: Color(0xFF1E2A38),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Book-wise Sales Distribution:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: PieChart(
                      dataMap: salesData,
                      animationDuration: const Duration(milliseconds: 1200),
                      chartType: ChartType.disc,
                      chartRadius: MediaQuery.of(context).size.width / 1.6, // bigger pie
                      legendOptions: const LegendOptions(
                        showLegendsInRow: false,
                        legendPosition: LegendPosition.bottom, // moved below
                        showLegends: true,
                        legendShape: BoxShape.circle,
                        legendTextStyle: TextStyle(
                          fontSize: 12, // smaller font for book names
                        ),
                      ),
                      chartValuesOptions: const ChartValuesOptions(
                        showChartValuesInPercentage: true,
                        showChartValues: true,
                        showChartValueBackground: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
