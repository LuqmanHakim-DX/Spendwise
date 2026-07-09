import 'package:flutter_test/flutter_test.dart';
import 'package:spendwise/models/budget.dart';
import 'package:spendwise/models/expense.dart';

void main() {
  test('Expense can round-trip through Firestore data', () {
    final expense = Expense(
      title: 'Lunch',
      amount: 12.5,
      category: 'Food',
      date: DateTime(2024, 1, 2, 12, 30),
      description: 'Team lunch',
    );

    final data = expense.toFirestore();
    final restored = Expense.fromFirestore(data, 'exp-1');

    expect(restored.title, 'Lunch');
    expect(restored.amount, 12.5);
    expect(restored.category, 'Food');
    expect(restored.description, 'Team lunch');
    expect(restored.id, 'exp-1');
  });

  test('Budget can round-trip through Firestore data', () {
    final budget = Budget(
      amount: 1000,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 31),
    );

    final data = budget.toFirestore();
    final restored = Budget.fromFirestore(data);

    expect(restored.amount, 1000);
    expect(restored.startDate, DateTime(2024, 1, 1));
    expect(restored.endDate, DateTime(2024, 1, 31));
  });
}
