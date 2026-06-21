import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/expense.dart';
import '../models/budget.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  Budget? _budget;

  List<Expense> get expenses => _expenses;
  Budget? get budget => _budget;

  double get totalExpenses => _expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get remainingBudget => (_budget?.amount ?? 0) - totalExpenses;

  ExpenseProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = prefs.getStringList('expenses') ?? [];
    _expenses = expensesJson.map((e) => Expense.fromJson(jsonDecode(e))).toList();

    final budgetJson = prefs.getString('budget');
    if (budgetJson != null) {
      _budget = Budget.fromJson(jsonDecode(budgetJson));
    }
    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    final prefs = await SharedPreferences.getInstance();
    final expensesJson = _expenses.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('expenses', expensesJson);
  }

  Future<void> _saveBudget() async {
    final prefs = await SharedPreferences.getInstance();
    if (_budget != null) {
      await prefs.setString('budget', jsonEncode(_budget!.toJson()));
    } else {
      await prefs.remove('budget');
    }
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> setBudget(Budget budget) async {
    _budget = budget;
    await _saveBudget();
    notifyListeners();
  }

  List<Map<String, dynamic>> getCategoryExpenses() {
    Map<String, double> categoryTotals = {};
    for (var expense in _expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals.entries.map((e) => {'category': e.key, 'amount': e.value}).toList();
  }
}