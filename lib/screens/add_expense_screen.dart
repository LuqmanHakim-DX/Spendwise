import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'home_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_scope.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Food';
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Entertainment', 'Other'];

  @override
  Widget build(BuildContext context) {
    context.watch<ExpenseProvider>();
    return ExitConfirmationScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Expense'),
        ),
        drawer: AppDrawer(
        currentIndex: 1,
        onDestinationSelected: (index) => _navigateToIndex(context, index),
        onLogout: () async {
          await context.read<AuthProvider>().signOut();
          if (!context.mounted) return;
          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) => setState(() => _selectedCategory = value!),
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Expense Date'),
              subtitle: Text(_selectedDate.toLocal().toString().split(' ')[0]),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() => _selectedDate = pickedDate);
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addExpense,
              child: const Text('Add Expense'),
            ),
          ],
        ),
      ),
    ));
  }

  void _navigateToIndex(BuildContext context, int index) {
    if (index == 1) return;
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 2:
        target = const CalendarScreen();
        break;
      case 3:
        target = const AnalyticsScreen();
        break;
      case 4:
        target = const BudgetScreen();
        break;
      case 5:
        target = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
  }

  Future<void> _addExpense() async {
    final title = _titleController.text;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final description = _descriptionController.text;

    if (title.isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    final expense = Expense(
      title: title,
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      description: description,
    );

    await context.read<ExpenseProvider>().addExpense(expense);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
}