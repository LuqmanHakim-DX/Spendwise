import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import '../models/expense.dart';
import 'home_screen.dart';
import 'add_expense_screen.dart';
import 'budget_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_scope.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryData = expenseProvider.getCategoryExpenses();
    final expenses = expenseProvider.expenses;

    return ExitConfirmationScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Spending Analytics'),
        ),
        drawer: AppDrawer(
        currentIndex: 3,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Expenses by Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categoryData.length,
                itemBuilder: (context, index) {
                  final data = categoryData[index];
                  return Card(
                    margin: const EdgeInsets.only(right: 12),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['category'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          Text('\$${data['amount'].toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            const Text('Expense Items', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: expenses.isEmpty
                  ? const Center(child: Text('No expenses yet. Add some expenses to see details.'))
                  : ListView.separated(
                      itemCount: expenses.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return ListTile(
                          title: Text(expense.title),
                          subtitle: Text('${expense.category} • ${expense.date.toLocal().toString().split(' ')[0]}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('\$${expense.amount.toStringAsFixed(2)}'),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _confirmDelete(context, expense),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                          onTap: () => _showExpenseDetails(context, expense),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    ));
  }

  void _navigateToIndex(BuildContext context, int index) {
    if (index == 2) return;
    Widget target;
    switch (index) {
      case 0:
        target = const HomeScreen();
        break;
      case 1:
        target = const AddExpenseScreen();
        break;
      case 3:
        target = const CalendarScreen();
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

  void _showExpenseDetails(BuildContext context, Expense expense) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(expense.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Category: ${expense.category}'),
              const SizedBox(height: 8),
              Text('Amount: \$${expense.amount.toStringAsFixed(2)}'),
              const SizedBox(height: 8),
              Text('Date: ${expense.date.toLocal().toString().split(' ')[0]}'),
              const SizedBox(height: 16),
              const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(expense.description.isEmpty ? 'No description provided.' : expense.description),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Expense expense) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Expense'),
          content: const Text('Are you sure you want to delete this expense? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete == true) {
      await context.read<ExpenseProvider>().deleteExpense(expense);
    }
  }
}