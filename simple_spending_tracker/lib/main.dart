import 'package:flutter/material.dart';
import 'package:get_x/route_manager.dart';
import 'package:simple_spending_tracker/view/dashboard.dart';
import 'package:simple_spending_tracker/view/transactions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const Transactions(),
    );
  }
}