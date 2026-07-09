import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/models/expense.dart';
import 'package:spendwise/providers/expense_provider.dart';

void main() {
  group('ExpenseProvider date filtering', () {
    test('returns only expenses for the selected day', () {
      final expenses = [
        Expense(
          title: 'Coffee',
          amount: 4.50,
          category: 'Food',
          date: DateTime(2026, 7, 8, 10, 30),
          description: '',
        ),
        Expense(
          title: 'Train',
          amount: 2.75,
          category: 'Transport',
          date: DateTime(2026, 7, 7, 18, 0),
          description: '',
        ),
        Expense(
          title: 'Dinner',
          amount: 19.99,
          category: 'Food',
          date: DateTime(2026, 7, 8, 20, 15),
          description: '',
        ),
      ];

      final filtered = ExpenseProvider.filterExpensesForDay(expenses, DateTime(2026, 7, 8));

      expect(filtered.length, 2);
      expect(filtered.map((expense) => expense.title).toList(), ['Coffee', 'Dinner']);
    });
  });
}
