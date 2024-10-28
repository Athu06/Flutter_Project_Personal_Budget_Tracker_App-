import 'package:flutter/material.dart';
import '../models/expense_models.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatelessWidget {
  final ApiService apiService = ApiService();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Dashboard')),
      body: FutureBuilder<List<ExpenseData>>(
        future: apiService.getExpenses(),
        builder: (context, snapshot) {
          // Show loading indicator while data is being fetched
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Show error message if there's an error
          else if (snapshot.hasError) {
            print('Error: ${snapshot.error}'); // Debugging output
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Check if data is received
          else if (snapshot.hasData) {
            final expenses = snapshot.data!;
            double totalAmount =
                expenses.fold(0, (sum, item) => sum + item.amount);

            return Column(
              children: [
                // Summary Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Expenses: \$${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // List of Expenses
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(expenses[index].description),
                        subtitle: Text('Category: ${expenses[index].category}'),
                        trailing: Text(
                          '\$${expenses[index].amount.toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else {
            return const Center(child: Text('No expenses found.'));
          }
        },
      ),

      // Floating action button to add a new expense
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/expenseDetail');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
