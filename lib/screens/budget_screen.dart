import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../models/budget.dart';
import 'home_screen.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_scope.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  _BudgetScreenState createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final _amountController = TextEditingController();

  void _syncBudgetAmount() {
    final expenseProvider = context.read<ExpenseProvider>();
    final budgetText = expenseProvider.budget?.amount.toString() ?? '';
    if (_amountController.text != budgetText) {
      _amountController.text = budgetText;
    }
  }

  @override
  void initState() {
    super.initState();
    _syncBudgetAmount();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final budgetText = expenseProvider.budget?.amount.toString() ?? '';
    if (_amountController.text != budgetText) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncBudgetAmount();
      });
    }

    return ExitConfirmationScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Set Budget'),
        ),
        drawer: AppDrawer(
        currentIndex: 4,
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
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Monthly Budget Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _setBudget,
              child: const Text('Set Budget'),
            ),
            const SizedBox(height: 20),
            if (expenseProvider.budget != null)
              Text('Current Budget: \$${expenseProvider.budget!.amount}'),
            Text('Remaining: \$${expenseProvider.remainingBudget}'),
          ],
        ),
      ),
    ));
  }

  void _navigateToIndex(BuildContext context, int index) {
    if (index == 3) return;
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const AddExpenseScreen();
        break;
      case 2:
        target = const CalendarScreen();
        break;
      case 3:
        target = const AnalyticsScreen();
        break;
      case 5:
        target = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => target));
  }

  Future<void> _setBudget() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount')));
      return;
    }

    final budget = Budget(
      amount: amount,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
    );

    await context.read<ExpenseProvider>().setBudget(budget);
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
}