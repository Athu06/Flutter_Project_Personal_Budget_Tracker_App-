import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import '../models/expense_models.dart'; // Ensure this contains the ExpenseData class
import '../services/db_helper.dart';

class DashboardScreen extends StatelessWidget {
  final DBHelper dbHelper = DBHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Budget Dashboard')),
      body: FutureBuilder<List<ExpenseData>>(
        future: dbHelper.getExpenses(), // Ensure this returns List<ExpenseData>
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasData) {
            final expenses = snapshot.data!;
            final expenseData = _prepareChartData(expenses);

            return Column(
              children: [
                SizedBox(
                  height: 200,
                  child: charts.PieChart(
                    expenseData,
                    animate: true,
                    animationDuration: Duration(seconds: 1),
                  ),
                ),
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
            return Center(child: Text('No expenses found.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/expenseDetail');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  List<charts.Series<ExpenseData, String>> _prepareChartData(
      List<ExpenseData> expenses) {
    final data = expenses.fold<Map<String, double>>({}, (map, expense) {
      map[expense.category] = (map[expense.category] ?? 0) + expense.amount;
      return map;
    });

    // Create a list of ExpenseData for the chart
    final List<ExpenseData> expenseData = data.entries.map((entry) {
      return ExpenseData(
        id: 0, // Dummy ID, adjust as necessary
        category: entry.key,
        description: "", // No description for aggregated data
        amount: entry.value,
        date: DateTime.now(), // Dummy date, adjust as necessary
      );
    }).toList();

    return [
      charts.Series<ExpenseData, String>(
        id: 'Expenses',
        data: expenseData,
        domainFn: (ExpenseData expense, _) => expense.category,
        measureFn: (ExpenseData expense, _) => expense.amount,
      )
    ];
  }
}
