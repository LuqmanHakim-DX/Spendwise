import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  double amount;
  DateTime startDate;
  DateTime endDate;

  Budget({
    required this.amount,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      amount: json['amount'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
    );
  }

  factory Budget.fromFirestore(Map<String, dynamic> data) {
    return Budget(
      amount: (data['amount'] as num?)?.toDouble() ?? 0,
      startDate: _parseDate(data['startDate']),
      endDate: _parseDate(data['endDate']),
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.parse(value);
    }
    return DateTime.now();
  }
}