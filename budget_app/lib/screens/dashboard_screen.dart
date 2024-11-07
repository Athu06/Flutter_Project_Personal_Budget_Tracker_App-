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
  DateTimeRange? _selectedDateRange;
  String? _selectedCategory;

  List<String> defaultCategories = [
    'All',
    'Food',
    'Rent',
    'Healthcare',
    'Entertainment',
    'Shopping',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    expensesFuture = apiService.getExpenses();
  }

  List<ExpenseData> _filterExpenses(List<ExpenseData> expenses) {
    return expenses.where((expense) {
      bool dateMatches = _selectedDateRange == null ||
          (expense.date.isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              expense.date.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1))));

      bool categoryMatches = _selectedCategory == null ||
          _selectedCategory == 'All' ||
          (_selectedCategory == 'Other' &&
              !defaultCategories.contains(expense.category)) ||
          (_selectedCategory != 'Other' &&
              expense.category == _selectedCategory);

      return dateMatches && categoryMatches;
    }).toList();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1970),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
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
            final expenseList = _filterExpenses(snapshot.data!);
            double totalAmount =
                expenseList.fold(0, (sum, item) => sum + item.amount);

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Expenses: Rs ${totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _selectDateRange(context),
                            child: Text(
                              _selectedDateRange == null
                                  ? 'Select Date Range'
                                  : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                            ),
                          ),
                          if (_selectedDateRange != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _selectedDateRange = null;
                                });
                              },
                            ),
                        ],
                      ),
                      DropdownButton<String>(
                        hint: const Text('Select Category'),
                        value: _selectedCategory,
                        items: defaultCategories.map((String category) {
                          return DropdownMenuItem<String>(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: expenseList.length,
                    itemBuilder: (context, index) {
                      String dateString = _formatDate(expenseList[index].date);

                      return ListTile(
                        title: Text('Category: ${expenseList[index].category}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Description: ${expenseList[index].description}'),
                            Text('Date: $dateString'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Rs ${expenseList[index].amount.toStringAsFixed(2)}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                try {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ExpenseDetailScreen(
                                          expense: expenseList[index]),
                                    ),
                                  ).then((_) {
                                    setState(() {
                                      expensesFuture = apiService.getExpenses();
                                    });
                                  });
                                } catch (e) {
                                  print('Error navigating to edit screen: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Failed to open edit screen: $e')),
                                  );
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () async {
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
                                            Navigator.of(context).pop(false);
                                          },
                                          child: const Text('No'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop(true);
                                          },
                                          child: const Text('Yes'),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmDelete == true) {
                                  bool result = await apiService.deleteExpense(
                                      expenseList[index].id.toString());
                                  if (result) {
                                    setState(() {
                                      expensesFuture = apiService.getExpenses();
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Expense deleted successfully')),
                                    );
                                  } else {
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
              .then((_) => setState(() {
                    expensesFuture = apiService.getExpenses();
                  }));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
