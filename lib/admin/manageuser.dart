// admin/manageuser.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  Future<void> _deleteUser(BuildContext context, String userId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting user: $e')),
      );
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
              'MANAGE USERS',
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
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found'));
          }

          final users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final userData = user.data() as Map<String, dynamic>;
              final userId = user.id;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.person, color: Colors.orange),
                  title: Text(userData['name'] ?? 'No Name'),
                  subtitle: Text(userData['email'] ?? 'No Email'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _confirmDelete(context, userId);
                    },
                  ),
                  onTap: () {
                    _showUserDetails(context, userData);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete User'),
        content: const Text('Are you sure you want to delete this user?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(context, userId);
            },
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, Map<String, dynamic> userData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(userData['name'] ?? 'User Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${userData['email'] ?? ''}'),
            Text('Phone: ${userData['phone'] ?? ''}'),
            Text('Address: ${userData['address'] ?? ''}'),
            Text('City: ${userData['city'] ?? ''}'),
            Text('Postal Code: ${userData['postalCode'] ?? ''}'),
            Text('Gender: ${userData['gender'] ?? ''}'),
            Text('DOB: ${userData['dob'] ?? ''}'),
            Text('Country: ${userData['country'] ?? ''}'),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
