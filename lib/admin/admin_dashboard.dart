import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:prj/admin/admin_add_book.dart';
import 'package:prj/admin/admin_order_history.dart';
import 'package:prj/admin/admin_sales_analytics.dart';
import 'package:prj/admin/adminorders.dart';
import 'package:prj/admin/manage_books_screen.dart';
import 'package:prj/admin/manageuser.dart';
import 'package:prj/models/book.dart';
import 'package:prj/providers/auth_provider.dart';

import 'package:provider/provider.dart';

import 'admin_book_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E2A38),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color.fromARGB(255, 255, 248, 231)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.menu_book, color: Color.fromARGB(255, 255, 152, 0), size: 28),
            SizedBox(width: 8),
            Text(
              'ADMIN DASHBOARD',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 248, 231),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: const Color(0xFF1E2A38),
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(color: Colors.transparent),
                    child: Text(
                      'Admin Menu',
                      style: TextStyle(
                        color: Color.fromARGB(255, 255, 248, 231),
                        fontSize: 24,
                      ),
                    ),
                  ),
                  _buildDrawerItem(Icons.bar_chart, 'SALES', () => AdminSalesAnalytics()),
                  _buildDrawerItem(Icons.book, 'Manage Books', () => const ManageBooksScreen()),
                  _buildDrawerItem(Icons.book, 'Add New Books', () => const AdminAddBookScreen()),
                  _buildDrawerItem(Icons.people, 'Manage Users', () => const ManageUsersScreen()),
                  _buildDrawerItem(Icons.shopping_bag, 'Manage Orders', () => const AdminOrdersScreen()),
                  _buildDrawerItem(Icons.history, 'Orders History', () => const AdminOrderHistoryScreen()),
                  const Divider(color: Colors.white70),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
                    onTap: () async {
                      await Provider.of<AuthProvider>(context, listen: false).logout(context);
                      Fluttertoast.showToast(
                        msg: "Logout successful",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black87,
                        textColor: Colors.white,
                      );
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📦 Book Stock Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 2;
                  if (constraints.maxWidth >= 1200) {
                    crossAxisCount = 5;
                  } else if (constraints.maxWidth >= 800) {
                    crossAxisCount = 4;
                  } else if (constraints.maxWidth >= 600) {
                    crossAxisCount = 3;
                  }

                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance.collection('books').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final books = snapshot.data?.docs ?? [];
                      if (books.isEmpty) {
                        return const Center(child: Text('No books found.'));
                      }

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.35,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          final data = book.data() as Map<String, dynamic>;

                          final bookModel = Book(
                            id: book.id,
                            title: data['title'] ?? 'Untitled',
                            author: data['author'] ?? '',
                            description: data['description'] ?? '',
                            imageUrl: data['imageUrl'] ?? '',
                            price: (data['price'] ?? 0).toDouble(),
                            quantity: data['quantity'] ?? 0, category: '',
                          );

                          return AdminBookCard(
                            book: bookModel,
                            onEdit: () {
                              _showEditStockDialog(context, bookModel.id, bookModel.quantity);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, Widget Function() builder) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (context) => builder()));
      },
    );
  }

  void _showEditStockDialog(BuildContext context, String bookId, int currentQuantity) {
    final controller = TextEditingController(text: currentQuantity.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Stock'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Enter new quantity'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Update'),
            onPressed: () async {
              final newQuantity = int.tryParse(controller.text);
              if (newQuantity != null) {
                await FirebaseFirestore.instance.collection('books').doc(bookId).update({
                  'quantity': newQuantity,
                });
                Navigator.pop(ctx);
              }
            },
          ),
        ],
      ),
    );
  }
}
