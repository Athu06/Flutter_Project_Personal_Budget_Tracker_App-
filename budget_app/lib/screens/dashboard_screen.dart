import 'package:budget_app/screens/expense_detail_screen.dart';
import 'package:flutter/material.dart';
import '../models/expense_models.dart';
import '../services/api_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService apiService = ApiService();
  late Future<List<ExpenseData>> expensesFuture;

  @override
  void initState() {
    super.initState();
    expensesFuture = apiService.getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budget Dashboard')),
      body: FutureBuilder<List<ExpenseData>>(
        future: expensesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final expenseList = snapshot.data!;
            double totalAmount =
                expenseList.fold(0, (sum, item) => sum + item.amount);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Expenses: \Rs ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenseList.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text('Category: ${expenseList[index].category}'),
                        subtitle: Text(expenseList[index].description),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16.0),
                        leading: const SizedBox(width: 0),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rs ${expenseList[index].amount.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ExpenseDetailScreen(
                                        expense: expenseList[index]),
                                  ),
                                ).then((_) {
                                  setState(() {
                                    // Refresh list after editing
                                    expensesFuture = apiService.getExpenses();
                                  });
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
                                // Show confirmation dialog
                                bool? confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Delete Expense'),
                                      content: const Text(
                                          'Do you want to delete this expense?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(
                                                false); // Close dialog without deleting
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(true); // Confirm delete
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  // Call the deleteExpense API to delete from the database
                                  print("expenseList;${expenseList[index].id}");
                                  bool result = await apiService.deleteExpense(
                                      expenseList[index].id.toString());

                                  if (result) {
                                    // If deletion is successful, remove it from the list
                                    setState(() {});

                                    // Optionally, refresh the list by calling the API again
                                    // expensesFuture = apiService.getExpenses();

                                    // Show success message
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Expense deleted successfully')),
                                    );
                                  } else {
                                    // Show failure message if deletion failed
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Failed to delete expense')),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/expenseDetail')
              .then((_) => setState(() {}));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
