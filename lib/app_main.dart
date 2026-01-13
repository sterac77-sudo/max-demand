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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF00B4D8),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFF1B263B),
        cardColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFFF1F6FB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF00B4D8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Color(0xFF00B4D8), width: 2),
          ),
          labelStyle: TextStyle(color: Color(0xFF0077B6)),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF00B4D8)),
          bodyMedium: TextStyle(fontSize: 16, color: Color(0xFF22223B)),
        ),
      ),
      home: const LoadEntryScreen(),
    );
  }
}
