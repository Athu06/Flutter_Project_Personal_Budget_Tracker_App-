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
  String _selectedCategory = 'All';
  TextEditingController _customCategoryController = TextEditingController();

  List<String> defaultCategories = [
    'All',
    'Food',
    'Rent',
    'Healthcare',
    'Entertainment',
    'Shopping',
    'Other'
  ];

  String _sortOption = 'Amount'; // Default sorting by amount
  bool _isAscending = true; // Default sorting in ascending order

  @override
  void initState() {
    super.initState();
    expensesFuture = apiService.getExpensesByType(_selectedCategory);
  }

  List<ExpenseData> _filterExpenses(List<ExpenseData> expenses) {
    return expenses.where((expense) {
      bool dateMatches = _selectedDateRange == null ||
          (expense.date.isAfter(_selectedDateRange!.start
                  .subtract(const Duration(days: 1))) &&
              expense.date.isBefore(
                  _selectedDateRange!.end.add(const Duration(days: 1))));

      bool categoryMatches = _selectedCategory == 'All' ||
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

  List<ExpenseData> _sortExpenses(List<ExpenseData> expenses) {
    if (_sortOption == 'Amount') {
      expenses.sort((a, b) => a.amount.compareTo(b.amount));
    } else {
      expenses.sort((a, b) => a.date.compareTo(b.date));
    }

    if (!_isAscending) {
      expenses = expenses.reversed.toList();
    }

    return expenses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Dashboard'),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 48, 217, 254),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Budget.jpeg',
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder<List<ExpenseData>>(
            future: expensesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData) {
                final expenseList = _filterExpenses(snapshot.data!);
                final sortedExpenseList = _sortExpenses(expenseList);

                if (sortedExpenseList.isEmpty) {
                  return const Center(
                    child: Text(
                      'No expenses available.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }

                double totalAmount =
                    sortedExpenseList.fold(0, (sum, item) => sum + item.amount);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Total Expenses: Rs ${totalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
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
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (_selectedDateRange != null)
                                IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.black),
                                  onPressed: () {
                                    setState(() {
                                      _selectedDateRange = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                          DropdownButton<String>(
                            hint: const Text(
                              'Select Category',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            value: _selectedCategory,
                            items: defaultCategories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value!;
                                if (_selectedCategory != 'Other') {
                                  _customCategoryController.clear();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_selectedCategory == 'Other')
                      TextFormField(
                        controller: _customCategoryController,
                        decoration:
                            const InputDecoration(labelText: 'Custom Category'),
                        validator: (value) =>
                            value!.isEmpty ? 'Enter a custom category' : null,
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<String>(
                            value: _sortOption,
                            items: ['Amount', 'Date']
                                .map(
                                    (String option) => DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(option),
                                        ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _sortOption = value!;
                              });
                            },
                          ),
                          DropdownButton<bool>(
                            value: _isAscending,
                            items: [
                              DropdownMenuItem<bool>(
                                value: true,
                                child: Text('Ascending'),
                              ),
                              DropdownMenuItem<bool>(
                                value: false,
                                child: Text('Descending'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _isAscending = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: sortedExpenseList.length,
                        itemBuilder: (context, index) {
                          String dateString =
                              _formatDate(sortedExpenseList[index].date);

                          return ListTile(
                            title: Text(
                              'Category: ${sortedExpenseList[index].category}',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Description: ${sortedExpenseList[index].description}',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Date: $dateString',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Rs ${sortedExpenseList[index].amount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: 18,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.black),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ExpenseDetailScreen(
                                                expense:
                                                    sortedExpenseList[index]),
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        expensesFuture =
                                            apiService.getExpensesByType(
                                                _selectedCategory);
                                      });
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.black),
                                  onPressed: () async {
                                    // Show confirmation dialog before deletion
                                    bool? confirmDelete =
                                        await showDialog<bool>(
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
                                                    false); // User pressed 'No'
                                              },
                                              child: const Text('No'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(
                                                    true); // User pressed 'Yes'
                                              },
                                              child: const Text('Yes'),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    // If the user confirmed the deletion
                                    if (confirmDelete == true) {
                                      bool result =
                                          await apiService.deleteExpense(
                                              sortedExpenseList[index].id);
                                      if (result) {
                                        setState(() {
                                          expensesFuture =
                                              apiService.getExpensesByType(
                                                  _selectedCategory); // Refresh the list
                                        });
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Expense deleted successfully')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                              content: Text(
                                                  'Failed to delete expense')),
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
                return const Center(
                  child: Text('No expenses available.'),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Expense Screen (Assuming you have an add screen)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ExpenseDetailScreen()),
          ).then((_) {
            setState(() {
              expensesFuture = apiService.getExpensesByType(_selectedCategory);
            });
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
