import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import Syncfusion charts
import '../models/expense_models.dart';
import '../services/db_helper.dart';

class DashboardScreen extends StatelessWidget {
  final DBHelper dbHelper = DBHelper();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Dashboard')),
      body: FutureBuilder<List<ExpenseData>>(
        future: dbHelper.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
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
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                // Chart Section
                Expanded(
                  child: SfCartesianChart(
                    title: ChartTitle(text: 'Expenses Overview'),
                    legend: Legend(isVisible: true),
                    primaryXAxis: CategoryAxis(),
                    primaryYAxis: NumericAxis(),
                    series: <ChartSeries>[
                      PieSeries<ExpenseData, String>(
                        dataSource: expenses,
                        xValueMapper: (ExpenseData expense, _) =>
                            expense.category,
                        yValueMapper: (ExpenseData expense, _) =>
                            expense.amount,
                        name: 'Expenses',
                        dataLabelSettings: DataLabelSettings(isVisible: true),
                      ),
                    ],
                  ),
                ),
                // List of Expenses
                Expanded(
                  child: ListView.builder(
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(expenses[index].description),
                        subtitle: Text(expenses[index].category),
                        trailing: Text(
                            '\$${expenses[index].amount.toStringAsFixed(2)}'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/expenseDetail');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
