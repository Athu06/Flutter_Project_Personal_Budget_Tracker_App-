// main.dart
import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expense_detail_screen.dart';

void main() {
  runApp(BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Budget Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => DashboardScreen(),
        '/expenseDetail': (context) => ExpenseDetailScreen(),
      },
    );
  }
}
