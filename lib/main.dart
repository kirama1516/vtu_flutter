import 'package:flutter/material.dart';
import 'package:m5data_app/screens/buyAirtime_screen.dart';
import 'package:m5data_app/screens/order_screen.dart';
import 'package:m5data_app/screens/splash_screen.dart';
import 'package:m5data_app/screens/transaction_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'M5 DATA',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const SplashScreen(),
      routes: {
        '/buyAirtime': (context) => const BuyAirtimeScreen(),
        '/orders': (context) => const OrdersPage(),
        '/transactions': (context) => const TransactionScreen()
      },
    );
  }
}
