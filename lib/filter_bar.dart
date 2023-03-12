import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final Function onExpand;
  final Function getExpansionState;
  final Function updateTimeFilter;

  const FilterBar({super.key, required this.onExpand, required this.getExpansionState, required this.updateTimeFilter});

  @override
  State<StatefulWidget> createState() => _FilterBarState();

  static String getDefaultTimeFilterString() {
    DateTime currentTimePeriod = DateTime.now();
    int startTime = DateTime(currentTimePeriod.year, currentTimePeriod.month, 1).millisecondsSinceEpoch;
    int endYear = currentTimePeriod.year + currentTimePeriod.month == 12 ? 1 : 0;
    int endMonth = currentTimePeriod.month == 12 ? 1 : currentTimePeriod.month + 1;
    int endTime = DateTime(endYear, endMonth, 1).millisecondsSinceEpoch;
    return "$startTime-$endTime";
  }

}

enum _TimeFilterGranularity {
  Week,
  Month,
  Year
}

Map<int, String> _MONTH_TO_STRING = {
  1 : "January" ,
  2 : "February" ,
  3 : "March" ,
  4 : "April" ,
  5 : "May" ,
  6 : "June" ,
  7 : "July" ,
  8 : "August" ,
  9 : "September" ,
  10 : "October",
  11 : "November",
  12 : "December",
};

class _FilterBarState extends State<FilterBar> {
  final Duration _animationTime = const Duration(milliseconds: 500);

  _TimeFilterGranularity _selectedTimeGranularity = _TimeFilterGranularity.Month;
  DateTime _currentTimePeriod = DateTime.now();

  final List<_TimeFilterGranularity> _menuItems = [
    _TimeFilterGranularity.Week,
    _TimeFilterGranularity.Month,
    _TimeFilterGranularity.Year,
  ];

  String _getCurrentTimePeriodAsFilterString() {
    int startTime;
    int endTime;
    switch (_selectedTimeGranularity) {
      case _TimeFilterGranularity.Week:
        int currWeekday = _currentTimePeriod.weekday;
        DateTime startOfCurrWeek = _currentTimePeriod.subtract(Duration(days: currWeekday - DateTime.monday));
        DateTime startOfCurrWeekStripped = DateTime(startOfCurrWeek.year, startOfCurrWeek.month, startOfCurrWeek.day);

        startTime = startOfCurrWeekStripped.millisecondsSinceEpoch;
        endTime = startOfCurrWeekStripped.add(const Duration(days: 7)).millisecondsSinceEpoch;
        break;
      case _TimeFilterGranularity.Month:
        startTime = DateTime(_currentTimePeriod.year, _currentTimePeriod.month, 1).millisecondsSinceEpoch;
        int endYear = _currentTimePeriod.year + (_currentTimePeriod.month == 12 ? 1 : 0);
        int endMonth = _currentTimePeriod.month == 12 ? 1 : _currentTimePeriod.month + 1;
        endTime = DateTime(endYear, endMonth, 1).millisecondsSinceEpoch;
        break;
      case _TimeFilterGranularity.Year:
        startTime = DateTime(_currentTimePeriod.year, 1, 1).millisecondsSinceEpoch;
        endTime = DateTime(_currentTimePeriod.year + 1, 1, 1).millisecondsSinceEpoch;
        break;
    }
    return "$startTime-$endTime";
  }

  void _updateTimePeriod(DateTime newTimePeriod, _TimeFilterGranularity newTimeGranularity) {
    setState(() {
      _selectedTimeGranularity = newTimeGranularity;
      _currentTimePeriod = newTimePeriod;
    });
    widget.updateTimeFilter(_getCurrentTimePeriodAsFilterString());
  }

  void _selectNewTimeGranularity(_TimeFilterGranularity granularity) {
    _updateTimePeriod(DateTime.now(), granularity);
  }

  void _incrementCurrentTimePeriod(bool forwards) {
    DateTime newTimePeriod;
    int offset = forwards ? 1 : -1;
    switch (_selectedTimeGranularity) {
      case _TimeFilterGranularity.Week:
        Duration oneWeek = const Duration(days: 7);
        newTimePeriod = forwards ? _currentTimePeriod.add(oneWeek) : _currentTimePeriod.subtract(oneWeek);
        break;
      case _TimeFilterGranularity.Month:
        int newMonth = _currentTimePeriod.month + offset;
        int year = _currentTimePeriod.year;
        if (newMonth % 13 == 0) {
          year = _currentTimePeriod.year + offset;
          newMonth = newMonth == 0 ? 12 : 1;
        }
        newTimePeriod = DateTime(year, newMonth);
        break;
      case _TimeFilterGranularity.Year:
        newTimePeriod = DateTime(_currentTimePeriod.year + offset);
        break;
    }
    _updateTimePeriod(newTimePeriod, _selectedTimeGranularity);
  }

  String _getDateString(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String _getDisplayedTimePeriod() {
    DateTime now = DateTime.now();
    switch (_selectedTimeGranularity) {
      case _TimeFilterGranularity.Week:
        int currWeekday = _currentTimePeriod.weekday;
        DateTime startOfNowWeek = DateTime.now().subtract(Duration(days: currWeekday - DateTime.monday));
        DateTime endOfNowWeek = DateTime.now().add(Duration(days: DateTime.sunday - currWeekday));
        if (_currentTimePeriod.compareTo(startOfNowWeek) >= 0 && _currentTimePeriod.compareTo(endOfNowWeek) <= 0) {
          return "This Week";
        }

        DateTime startOfCurrWeek = _currentTimePeriod.subtract(Duration(days: currWeekday - DateTime.monday));
        DateTime endOfCurrWeek = _currentTimePeriod.add(Duration(days: DateTime.sunday - currWeekday));
        return "${_getDateString(startOfCurrWeek)} - ${_getDateString(endOfCurrWeek)}";

      case _TimeFilterGranularity.Month:
        if (_currentTimePeriod.month == now.month && _currentTimePeriod.year == now.year) {
          return "This Month";
        }
        return "${_MONTH_TO_STRING[_currentTimePeriod.month]} ${_currentTimePeriod.year}";
      case _TimeFilterGranularity.Year:
        if (_currentTimePeriod.year == now.year) {
          return "This Year";
        }
        return "${_currentTimePeriod.year}";
    }
  }

  bool _isExpanded() => widget.getExpansionState();

  Widget _buildTimeFilter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => _incrementCurrentTimePeriod(false),
        ),
        PopupMenuButton<_TimeFilterGranularity>(
          itemBuilder: (BuildContext context) {
            return _menuItems.map((_TimeFilterGranularity item) {
              return PopupMenuItem<_TimeFilterGranularity>(
                value: item,
                child: Text("This ${item.name}", style: const TextStyle(fontSize: 18)),
              );
            }).toList();
          },
          onSelected: _selectNewTimeGranularity,
          offset: const Offset(0, -150), // set the offset to move the popup menu upwards
          child: Container(
            alignment: Alignment.center,
            width: 200,
            height: 50,
            child: Text(_getDisplayedTimePeriod(), style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
          )
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.onPrimary),
          onPressed: () => _incrementCurrentTimePeriod(true),
        ),
      ],
    );
  }

  static const double _toggleButtonHeight = 40;
  static const double _containerHeight = 70;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          child: Container(
            height: _isExpanded() ? 210 : _containerHeight + _toggleButtonHeight/2,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.only(top: _toggleButtonHeight/2),
            child: AnimatedContainer(
              duration: _animationTime,
              height: _isExpanded() ? 200 : _containerHeight,
              color: Theme.of(context).colorScheme.surface,
              child: _buildTimeFilter(context),
            ),
          ),
        ),
        Positioned(
          top: 0,
          child: GestureDetector(
            onTap: () => widget.onExpand(),
            child: AnimatedContainer(
              duration: _animationTime,
              height: _toggleButtonHeight,
              width: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.all(Radius.circular(_toggleButtonHeight/2)),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: _toggleButtonHeight/3),
                child: Icon(
                  _isExpanded() ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

}