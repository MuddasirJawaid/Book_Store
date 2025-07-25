import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/checkout_screen.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.loadCartFromFirestore();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cartItems = cartProvider.items.values.toList();

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (cartItems.isEmpty) {
          return const Center(
            child: Text("🛒 Your cart is empty", style: TextStyle(fontSize: 18)),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: cartItems.length,
                itemBuilder: (ctx, index) {
                  final item = cartItems[index];
                  return Card(
                    margin: const EdgeInsets.all(8),
                    child: ListTile(
                      leading: item.book.imageUrl.isNotEmpty
                          ? Image.network(
                        item.book.imageUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                      )
                          : const Icon(Icons.book),
                      title: Text(item.book.title),
                      subtitle: Text(
                        'Quantity: ${item.quantity} | \$${(item.book.price * item.quantity).toStringAsFixed(2)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () async {
                              if (item.quantity > 1) {
                                await cartProvider.updateQuantity(item.book.id, item.quantity - 1);
                              } else {
                                await cartProvider.removeFromCart(item.book.id);
                              }
                            },
                          ),
                          Text(item.quantity.toString()),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () async {
                              await cartProvider.updateQuantity(item.book.id, item.quantity + 1);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await cartProvider.removeFromCart(item.book.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      );
                    },
                    child: const Text("PROCEED TO CHECKOUT"),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
