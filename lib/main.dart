// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'splashscreen.dart';
import 'login.dart';
import 'homescreen.dart';

import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/wishlist_provider.dart';
import 'providers/rating_provider.dart';
import 'providers/reviewprovide.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),


        ChangeNotifierProvider(create: (_) => BookProvider()),


        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cartProvider) {
            if (auth.user != null) {
              cartProvider!.loadCartFromFirestore();
            }
            return cartProvider!;
          },
        ),


        ChangeNotifierProxyProvider2<AuthProvider, BookProvider, WishlistProvider>(
          create: (_) => WishlistProvider(),
          update: (_, auth, bookProvider, wishlistProvider) {
            wishlistProvider!.allBooks = bookProvider.books;
            return wishlistProvider;
          },
        ),


        ChangeNotifierProvider(create: (_) => RatingProvider()),


        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BOOK STORE',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
