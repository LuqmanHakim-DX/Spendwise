import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';
import 'analytics_screen.dart';
import 'budget_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/exit_confirmation_scope.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final expenses = context.watch<ExpenseProvider>().expenses;
    final dailyExpenses = ExpenseProvider.filterExpensesForDay(expenses, _selectedDate);
    final dailyTotal = dailyExpenses.fold(0.0, (sum, expense) => sum + expense.amount);

    return ExitConfirmationScope(
      child: Scaffold(
        appBar: AppBar(title: const Text('Calendar')),
        drawer: AppDrawer(
          currentIndex: 2,
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
              Card(
                child: TableCalendar(
                  firstDay: DateTime.utc(2024, 1, 1),
                  lastDay: DateTime.utc(2035, 12, 31),
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDate = selectedDay;
                    });
                  },
                  eventLoader: (day) => ExpenseProvider.filterExpensesForDay(expenses, day),
                  calendarStyle: const CalendarStyle(
                    markerDecoration: BoxDecoration(color: Colors.indigo, shape: BoxShape.circle),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Expenses for ${_selectedDate.toLocal().toString().split(' ')[0]}',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Total: \$${dailyTotal.toStringAsFixed(2)}'),
                      const SizedBox(height: 12),
                      if (dailyExpenses.isEmpty)
                        const Text('No expenses logged on this day.')
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: dailyExpenses.length,
                          separatorBuilder: (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final expense = dailyExpenses[index];
                            return ListTile(
                              title: Text(expense.title),
                              subtitle: Text(expense.category),
                              trailing: Text('\$${expense.amount.toStringAsFixed(2)}'),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}
