import 'package:flutter/material.dart';
import 'load_entry_screen.dart';

void main() {
  runApp(const MaxDemandCalculatorApp());
}

class MaxDemandCalculatorApp extends StatelessWidget {
  const MaxDemandCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Maximum Demand Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const LoadEntryScreen(),
    );
  }
}
