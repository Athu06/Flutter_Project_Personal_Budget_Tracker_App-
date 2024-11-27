// import 'package:flutter/material.dart';
// import '../models/expense_models.dart';
// import '../services/api_service.dart';
// import 'expense_detail_screen.dart';

// class FilterScreen extends StatefulWidget {
//   const FilterScreen({Key? key}) : super(key: key);

//   @override
//   _FilterScreenState createState() => _FilterScreenState();
// }

// class _FilterScreenState extends State<FilterScreen> {
//   final ApiService apiService = ApiService();
//   late Future<List<ExpenseData>> expensesFuture;

//   final List<String> defaultCategories = [
//     'All',
//     'Food',
//     'Rent',
//     'Healthcare',
//     'Entertainment',
//     'Shopping',
//     'Other'
//   ];

//   DateTimeRange? _selectedDateRange;
//   String _selectedCategory = 'All';
//   String _sortBy = 'amount_asc'; // Default sorting by amount

//   @override
//   void initState() {
//     super.initState();
//     fetchExpenses(); // Initial fetch without filters
//   }

//   /// Fetch expenses with current filters
//   void fetchExpenses() {
//     setState(() {
//       expensesFuture = apiService.getExpenses(
//         expenseType: _selectedCategory != 'All' ? _selectedCategory : "All",
//         startDate: _selectedDateRange?.start.millisecondsSinceEpoch,
//         endDate: _selectedDateRange?.end.millisecondsSinceEpoch,
//         sortBy: _sortBy,
//       );
//     });
//   }

//   Future<void> _selectDateRange(BuildContext context) async {
//     final DateTimeRange? picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(1970),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null && picked != _selectedDateRange) {
//       setState(() {
//         _selectedDateRange = picked;
//         fetchExpenses();
//       });
//     }
//   }

//   String _formatDate(DateTime date) {
//     return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Filter Expenses'),
//         centerTitle: true,
//         backgroundColor: const Color.fromARGB(255, 48, 217, 254),
//       ),
//       body: Stack(
//         children: [
//           Positioned.fill(
//             child: Image.asset(
//               'assets/Budget.jpeg',
//               fit: BoxFit.cover,
//             ),
//           ),
//           Column(
//             children: [
//               // Filters section
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                 child: Column(
//                   children: [
//                     // Date Range Selector
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         TextButton(
//                           onPressed: () => _selectDateRange(context),
//                           child: Text(
//                             _selectedDateRange == null
//                                 ? 'Select Date Range'
//                                 : '${_formatDate(_selectedDateRange!.start)} - ${_formatDate(_selectedDateRange!.end)}',
//                             style: const TextStyle(
//                               color: Colors.black,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ),
//                         if (_selectedDateRange != null)
//                           IconButton(
//                             icon: const Icon(Icons.clear, color: Colors.black),
//                             onPressed: () {
//                               setState(() {
//                                 _selectedDateRange = null;
//                                 fetchExpenses();
//                               });
//                             },
//                           ),
//                       ],
//                     ),
//                     // Category Dropdown
//                     DropdownButton<String>(
//                       value: _selectedCategory,
//                       items: defaultCategories.map((String category) {
//                         return DropdownMenuItem<String>(
//                           value: category,
//                           child: Text(category,
//                               style: const TextStyle(color: Colors.black)),
//                         );
//                       }).toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _selectedCategory = value!;
//                           fetchExpenses();
//                         });
//                       },
//                     ),
//                     // Sort By Dropdown
//                     DropdownButton<String>(
//                       value: _sortBy,
//                       items: ['amount_asc', 'date_asc', 'amount_desc', 'date_desc']
//                           .map(
//                               (String option) => DropdownMenuItem<String>( 
//                                     value: option,
//                                     child: Text(option.toUpperCase()),
//                                   ))
//                           .toList(),
//                       onChanged: (value) {
//                         setState(() {
//                           _sortBy = value!;
//                           fetchExpenses();
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//               // Expenses List
//               Expanded(
//                 child: FutureBuilder<List<ExpenseData>>(
//                   future: expensesFuture,
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     } else if (snapshot.hasError) {
//                       return Center(child: Text('Error: ${snapshot.error}'));
//                     } else if (snapshot.hasData) {
//                       final expenses = snapshot.data!;

//                       return expenses.isEmpty
//                           ? const Center(
//                               child: Text(
//                                 'No expenses available.',
//                                 style: TextStyle(
//                                   color: Colors.black,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             )
//                           : ListView.builder(
//                               itemCount: expenses.length,
//                               itemBuilder: (context, index) {
//                                 final expense = expenses[index];
//                                 final dateString = _formatDate(expense.date);

//                                 return ListTile(
//                                   title: Text(
//                                     'Category: ${expense.category}',
//                                     style: const TextStyle(
//                                       color: Colors.black,
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Text(
//                                         'Description: ${expense.description}',
//                                         style: const TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                       Text(
//                                         'Date: $dateString',
//                                         style: const TextStyle(
//                                           color: Colors.black,
//                                           fontSize: 14,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   trailing: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         'Rs ${expense.amount.toStringAsFixed(2)}',
//                                         style: const TextStyle(
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.black,
//                                         ),
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(Icons.edit, color: Colors.black),
//                                         onPressed: () {
//                                           Navigator.push(
//                                             context,
//                                             MaterialPageRoute(
//                                               builder: (context) =>
//                                                   ExpenseDetailScreen(expense: expense),
//                                             ),
//                                           ).then((_) {
//                                             fetchExpenses();
//                                           });
//                                         },
//                                       ),
//                                       IconButton(
//                                         icon: const Icon(Icons.delete, color: Colors.black),
//                                         onPressed: () async {
//                                           // Show confirmation dialog before deletion
//                                           final confirmed = await _showDeleteConfirmationDialog(context);

//                                           if (confirmed) {
//                                             final result = await apiService.deleteExpense(expense.id);
//                                             if (result) {
//                                               fetchExpenses();
//                                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                                                   content: Text('Expense deleted successfully')));
//                                             } else {
//                                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                                                   content: Text('Failed to delete expense')));
//                                             }
//                                           }
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             );
//                     }
//                     return const Center(child: Text('No data available.'));
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   /// Show confirmation dialog before deleting the expense
//   Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
//     return await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Deletion'),
//           content: const Text('Are you sure you want to delete this expense?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(false); // User pressed No
//               },
//               child: const Text('No'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(true); // User pressed Yes
//               },
//               child: const Text('Yes'),
//             ),
//           ],
//         );
//       },
//     ) ??
//         false; // Return false if dialog is dismissed by tapping outside
//   }
// }
