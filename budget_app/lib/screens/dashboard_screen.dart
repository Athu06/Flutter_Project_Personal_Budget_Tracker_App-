import 'package:budget_app/screens/auth.dart';
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


  List<String> defaultCategories = [
    'All',
    'Food',
    'Rent',
    'Healthcare',
    'Entertainment',
    'Shopping',
    'Other'
  ];

  DateTimeRange? _selectedDateRange;
  String _selectedCategory = 'All';
  String _sortBy = 'amount_asc'; // Default sorting by amount

 
  @override
  void initState() {
    super.initState();
    expensesFuture = apiService.getExpenses
    ();
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
        fetchExpenses();
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
void fetchExpenses() {
  setState(() {
    expensesFuture = apiService.getExpenses(
      expenseType: _selectedCategory != 'All' ? _selectedCategory : "All",
      startDate: _selectedDateRange?.start.millisecondsSinceEpoch,
      endDate: _selectedDateRange?.end.millisecondsSinceEpoch,
      sortBy: _sortBy,
    );
  });
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

              // if (expenseList.isEmpty) {
              //   return const Center(
              //     child: Text(
              //       'No expenses available.',
              //       style: TextStyle(
              //         color: Colors.black,
              //         fontSize: 18,
              //         fontWeight: FontWeight.bold,
              //       ),
              //     ),
              //   );
              // }

                double totalAmount =
                    expenseList.fold(0, (sum, item) => sum + item.amount);

                return Column(
                  
                  children: [
                    Align(
                      alignment: Alignment.topCenter,
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
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0), // Add padding for spacing
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Align items to opposite ends
                            crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
                            children: [
                              // Date Range Filter Section
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Button background color
                                ),
                                    onPressed: () => _selectDateRange(context),
                                    child: Text(
                                      _selectedDateRange == null
                                          ? 'Select Date Range'
                                          : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  if (_selectedDateRange != null)
                                    IconButton(
                                      icon: const Icon(Icons.clear, color: Colors.black),
                                      onPressed: () {
                                        setState(() {
                                          _selectedDateRange = null;
                                          fetchExpenses();
                                        });
                                      },
                                    ),
                                ],
                              ),
                              // Logout Button Section
                              ElevatedButton(
                                style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Button background color
                                  foregroundColor: MaterialStateProperty.all<Color>(Colors.white), // Text color
                                ),
                                onPressed: () {
                                  // Navigate to the Auth screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const Auth()),
                                  );
                                },
                                child: const Text("Logout"),
                              ),
                            ],
                          ),
                        ),                        // Category Dropdown
                        DropdownButton<String>(
                          value: _selectedCategory,
                          items: defaultCategories.map((String category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(category,
                                  style: const TextStyle(color: Colors.black)),
                            );
                          }).toList(),
                          iconEnabledColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value!;
                              fetchExpenses();
                            });
                          },
                        ),
                        // Sort By Dropdown
                        DropdownButton<String>(
                          value: _sortBy,
                          items: ['amount_asc', 'date_asc', 'amount_desc', 'date_desc']
                              .map(
                                  (String option) => DropdownMenuItem<String>( 
                                        value: option,
                                        child: Text(option.toUpperCase()),
                                      ))
                              .toList(),
                          iconEnabledColor: Colors.blue,
                          onChanged: (value) {
                            setState(() {
                              _sortBy = value!;
                              fetchExpenses();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                    Expanded(
                child: FutureBuilder<List<ExpenseData>>(
                  future: expensesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      final expenses = snapshot.data!;

                      return expenses.isEmpty
                          ? const Center(
                              child: Text(
                                'No expenses available.',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          : ListView.builder(
                              itemCount: expenses.length,
                              itemBuilder: (context, index) {
                                final expense = expenses[index];
                                final dateString = _formatDate(expense.date);

                                return ListTile(
                                  title: Text(
                                    'Category: ${expense.category}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Description: ${expense.description}',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        'Date: $dateString',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 14,
                                        ),
                                      ),
                                      // Text(
                                      //   'CreatedAt: ${expense.createdAt}',
                                      //   style: const TextStyle(
                                      //     color: Colors.black,
                                      //     fontSize: 14,
                                      //   ),
                                      // ),
                                      // Text(
                                      //   'UpdatedAt: ${expense.updatedAt}',
                                      //   style: const TextStyle(
                                      //     color: Colors.black,
                                      //     fontSize: 14,
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Rs ${expense.amount.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: Colors.black),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ExpenseDetailScreen(expense: expense),
                                            ),
                                          ).then((_) {
                                            fetchExpenses();
                                          });
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete, color: Colors.black),
                                        onPressed: () async {
                                          // Show confirmation dialog before deletion
                                          final confirmed = await _showDeleteConfirmationDialog(context);

                                          if (confirmed) {
                                            final result = await apiService.deleteExpense(expense.id);
                                            if (result) {
                                              fetchExpenses();
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                  content: Text('Expense deleted successfully')));
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                                  content: Text('Failed to delete expense')));
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                    }
                    return const Center(child: Text('No data available.'));
                  },
                ),
              ),
              
                  ],
                );
              
              }
               
              return Container();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Expense Screen (Assuming you have an add screen)
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExpenseDetailScreen()),
          ).then((_) {
            setState(() {
              expensesFuture = apiService.getExpenses
              ();
            });
          });
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
  /// Show confirmation dialog before deleting the expense
Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this expense?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed No
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed Yes
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    ) ??
        false; // Return false if dialog is dismissed by tapping outside
  }
