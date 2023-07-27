import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ExcludeCategories with ChangeNotifier {
  Set<int> _excludeCategories = {};

  Set<int> get excludeCategories => _excludeCategories;

  set excludeCategories(Set<int> value) {
    _excludeCategories = value;
    notifyListeners();
  }
}

class TimeFilter with ChangeNotifier {
  String _timeFilter = getDefaultTimeFilterString();

  String get timeFilter => _timeFilter;

  set timeFilter(String value) {
    _timeFilter = value;
    notifyListeners();
  }

  static String getDefaultTimeFilterString() {
    DateTime currentTimePeriod = DateTime.now();
    int startTime = DateTime(currentTimePeriod.year, currentTimePeriod.month, 1)
        .millisecondsSinceEpoch;
    int endYear =
        currentTimePeriod.year + currentTimePeriod.month == 12 ? 1 : 0;
    int endMonth =
        currentTimePeriod.month == 12 ? 1 : currentTimePeriod.month + 1;
    int endTime = DateTime(endYear, endMonth, 1).millisecondsSinceEpoch;
    return "$startTime-$endTime";
  }
}

class ExpenseTotal with ChangeNotifier {
  double _expenseTotal = 0;

  double get expenseTotal => _expenseTotal;

  set expenseTotal(double value) {
    _expenseTotal = value;
    notifyListeners();
  }
}
