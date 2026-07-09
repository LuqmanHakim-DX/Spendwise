import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'calendar_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_scope.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final authProvider = context.read<AuthProvider>();

    return ExitConfirmationScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('SpendWise'),
        ),
        drawer: AppDrawer(
          currentIndex: 0,
          onDestinationSelected: (index) => _navigateToIndex(context, index),
          onLogout: () async {
            await authProvider.signOut();
            if (!mounted) return;
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          },
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSummaryCard('Total Expenses', '\$${expenseProvider.totalExpenses.toStringAsFixed(2)}'),
                  _buildSummaryCard('Remaining Budget', '\$${expenseProvider.remainingBudget.toStringAsFixed(2)}'),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  elevation: 4,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded),
                    SizedBox(width: 8),
                    Text(
                      'Log Expense',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: expenseProvider.getCategoryExpenses().length,
                  itemBuilder: (context, index) {
                    final data = expenseProvider.getCategoryExpenses()[index];
                    return ListTile(
                      title: Text(data['category']),
                      trailing: Text('\$${data['amount'].toStringAsFixed(2)}'),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    Widget target;
    switch (index) {
      case 1:
        target = const AddExpenseScreen();
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

  Widget _buildSummaryCard(String title, String value) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 16)),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}