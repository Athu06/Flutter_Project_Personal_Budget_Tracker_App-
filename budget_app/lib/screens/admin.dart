import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/expense_models.dart';
import '../services/api_service.dart';
import 'expense_detail_screen.dart';
import 'auth.dart';


class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
  String _sortBy = 'date_desc';
  Map<String, String> userEmailsToUID = {};
  String _selectedUser = 'Users'; // Default value

  @override
  void initState() {
    super.initState();
    fetchData();
    fetchExpenses();
    expensesFuture = apiService.getExpenses();
  }

  Future<void> fetchData() async {
    try {
      final emails = await apiService.fetchUserEmails();
      setState(() {   
        userEmailsToUID = emails;
      });
    } catch (e) {
      print('Error fetching user emails: $e');
    }
  }

  Future<void> fetchExpenses() async {
  setState(() {
    final selectedUserUID = _selectedUser != 'All' ? userEmailsToUID[_selectedUser] : null;
    print(selectedUserUID);
    print(userEmailsToUID[_selectedUser]);
    expensesFuture = apiService.getExpensesbyUser(
      userId: selectedUserUID, // Use the selected user's UID
      expenseType: _selectedCategory != 'All' ? _selectedCategory : '',
      startDate: _selectedDateRange?.start.millisecondsSinceEpoch,
      endDate: _selectedDateRange?.end.millisecondsSinceEpoch,
      sortBy: _sortBy,
    );
  });
}


  String _formatDateTime(DateTime dateTime) {
    const List<String> weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    String dayOfWeek = weekdays[dateTime.weekday - 1];

    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} $dayOfWeek';
  }

List<ExpenseData> _filterExpenses(List<ExpenseData> expenses) {
  return expenses.where((expense) {
    // Convert Timestamp to DateTime before comparing
    DateTime expenseDate = expense.date.toDate();

    // Date matching logic
    bool dateMatches = _selectedDateRange == null ||
        (expenseDate.isAfter(
                _selectedDateRange!.start.subtract(const Duration(days: 1))) &&
            expenseDate.isBefore(
                _selectedDateRange!.end.add(const Duration(days: 1))));

    // Category matching logic
    bool categoryMatches = _selectedCategory == 'All' ||
        (_selectedCategory == 'Other' &&
            !defaultCategories.contains(expense.category)) ||
        (_selectedCategory != 'Other' && expense.category == _selectedCategory);

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
      fetchExpenses();
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this expense?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
                final expenses = _filterExpenses(snapshot.data!);

                double totalAmount =
                    expenses.fold(0, (sum, item) => sum + item.amount);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const Auth()),
                              );
                            },
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    ),
                    DropdownButton<String>(
                      value: _selectedCategory,
                      items: defaultCategories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value!;
                        });
                        fetchExpenses();
                      },
                    ),
                    DropdownButton<String>(
                      value: _selectedUser,
                      items: ['All', ...userEmailsToUID.keys].map((user) {
                        return DropdownMenuItem<String>(
                          value: user,
                          child: Text(user),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUser = value!;
                        });
                        fetchExpenses();
                      },
                    ),

                    DropdownButton<String>(
                      value: _sortBy,
                      items: ['amount_asc', 'date_asc', 'amount_desc', 'date_desc']
                          .map((option) => DropdownMenuItem<String>(
                                value: option,
                                child: Text(option.toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _sortBy = value!;
                        });
                        fetchExpenses();
                      },
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
                            final expenses = _filterExpenses(snapshot.data!);

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
                                      // final dateString = _formatDate(expense.date);

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
                                              // Format 'date' field
                                              'Date: ${_formatDateTime((expense.date as Timestamp).toDate())}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              // Format 'createdAt' field
                                              'CreatedAt: ${expense.createdAt != null ? _formatDateTime((expense.createdAt).toDate()) : 'N/A'}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              // Format 'updatedAt' field
                                              'UpdatedAt: ${expense.updatedAt != null ? _formatDateTime((expense.updatedAt as Timestamp).toDate()) : 'N/A'}',
                                              style: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                              ),
                                            ),
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
              } else {
                return const Center(child: Text('No data available.'));
              }
            },
          ),
        ],
      ),
    );
  }
}
