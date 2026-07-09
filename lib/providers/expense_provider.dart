import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/budget.dart';
import '../models/expense.dart';

class ExpenseProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  StreamSubscription<User?>? _authSubscription;

  List<Expense> _expenses = [];
  Budget? _budget;
  String? _userId;

  List<Expense> get expenses => _expenses;
  Budget? get budget => _budget;

  double get totalExpenses => _expenses.fold(0, (sum, expense) => sum + expense.amount);
  double get remainingBudget => (_budget?.amount ?? 0) - totalExpenses;

  ExpenseProvider() {
    _authSubscription = _auth.authStateChanges().listen(_handleAuthChanged);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleAuthChanged(User? user) async {
    _userId = user?.uid;
    if (_userId == null) {
      _expenses = [];
      _budget = null;
      notifyListeners();
      return;
    }

    await _loadData();
  }

  Future<void> _loadData() async {
    if (_userId == null) {
      return;
    }

    final snapshot = await _firestore.collection('users').doc(_userId).get();
    final data = snapshot.data();

    _expenses = [];
    _budget = null;

    if (data != null && data['expenses'] is List) {
      final expensesData = data['expenses'] as List<dynamic>;
      _expenses = expensesData
          .map((item) => Expense.fromFirestore(Map<String, dynamic>.from(item as Map), null))
          .toList();
    }

    if (data != null && data['budget'] is Map) {
      _budget = Budget.fromFirestore(Map<String, dynamic>.from(data['budget'] as Map));
    }

    notifyListeners();
  }

  Future<void> _saveExpenses() async {
    if (_userId == null) {
      return;
    }

    await _firestore.collection('users').doc(_userId).set(
      {'expenses': _expenses.map((expense) => expense.toFirestore()).toList()},
      SetOptions(merge: true),
    );
  }

  Future<void> _saveBudget() async {
    if (_userId == null) {
      return;
    }

    final userDoc = _firestore.collection('users').doc(_userId);
    if (_budget != null) {
      await userDoc.set({'budget': _budget!.toFirestore()}, SetOptions(merge: true));
    } else {
      await userDoc.update({'budget': FieldValue.delete()});
    }
  }

  Future<void> addExpense(Expense expense) async {
    _expenses.add(expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> deleteExpense(Expense expense) async {
    _expenses.remove(expense);
    await _saveExpenses();
    notifyListeners();
  }

  Future<void> setBudget(Budget budget) async {
    _budget = budget;
    await _saveBudget();
    notifyListeners();
  }

  List<Map<String, dynamic>> getCategoryExpenses() {
    final categoryTotals = <String, double>{};
    for (var expense in _expenses) {
      categoryTotals[expense.category] = (categoryTotals[expense.category] ?? 0) + expense.amount;
    }
    return categoryTotals.entries.map((e) => {'category': e.key, 'amount': e.value}).toList();
  }

  static List<Expense> filterExpensesForDay(List<Expense> expenses, DateTime day) {
    final targetDay = DateTime(day.year, day.month, day.day);
    return expenses.where((expense) {
      final expenseDay = DateTime(expense.date.year, expense.date.month, expense.date.day);
      return expenseDay == targetDay;
    }).toList();
  }
}