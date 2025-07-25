// homescreen.dart
// homescreen.dart
import 'package:prj/widgets/authorstab.dart';
import 'package:prj/widgets/books_tab.dart';
import 'package:prj/widgets/helpPage.dart';
import 'package:prj/widgets/orderhistory.dart';
import 'package:prj/widgets/orders.dart';
import 'package:prj/widgets/resetpassword.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/categories_tab.dart';
import '../widgets/cart_tab.dart';
import '../widgets/profile_tab.dart';
import '../widgets/wishlist_tab.dart';
import '../widgets/best_seller.dart';

class HomeScreen extends StatefulWidget {
  final bool showAppBar;
  const HomeScreen({super.key, this.showAppBar = true});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (authProvider.user != null) {
      wishlistProvider.loadWishlist();
      if (authProvider.userData == null) {
        authProvider.fetchUserData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.userData?['name'] ?? 'Guest User';

    final pages = [
      const BooksTab(),
      const CategoriesTab(),
      const CartTab(),
      const WishlistTab(),
      const BestSellerScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E7),
      appBar: widget.showAppBar
          ? AppBar(
        backgroundColor: const Color(0xFF1E2A38),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFFFFF8E7)),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book, color: Color(0xFFFF9800), size: 28),
            const SizedBox(width: 8),
            const Text(
              'BOOK STORE',
              style: TextStyle(
                color: Color(0xFFFFF8E7),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.person, color: Color(0xFFFFF8E7)),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileTab()));
              },
            ),
          ],
        ),
      )
          : null,
      drawer: widget.showAppBar
          ? Drawer(
        backgroundColor: const Color(0xFF1E2A38),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1E2A38)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.menu_book, color: Color(0xFFFF9800), size: 28),
                      const SizedBox(width: 8),
                      const Text(
                        'BOOK STORE',
                        style: TextStyle(
                          color: Color(0xFFFFF8E7),
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 70),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: Colors.white),
              title: const Text('Home', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Authors', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => AuthorsScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.white),
              title: const Text('Your Orders', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text('Orders History', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileTab()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.lock_reset, color: Colors.white),
              title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ResetPasswordScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.white),
              title: const Text('Help', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpScreen()));
              },
            ),
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
      )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverFillRemaining(
            child: pages[_selectedIndex],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.orange,
        unselectedItemColor: const Color(0xFF1E2A38),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Books'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'Categories'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Wishlist'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Best Sellers'),
        ],
      ),
    );
  }
}