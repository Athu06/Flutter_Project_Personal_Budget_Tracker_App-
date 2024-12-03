import 'package:budget_app/firebase_options.dart';
import 'package:budget_app/screens/auth.dart';
import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/expense_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/admin.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(BudgetTrackerApp());
}

class BudgetTrackerApp extends StatelessWidget {
  const BudgetTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Budget Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const Auth(),
        '/dashboardScreen': (context) => const DashboardScreen(),
        '/expenseDetail': (context) => const ExpenseDetailScreen(),
        '/adminPage':(context)=> const AdminPage(),
      },
    );
  }
}
