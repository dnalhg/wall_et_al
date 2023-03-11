import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final Function onExpand;
  final Function getExpansionState;

  const FilterBar({super.key, required this.onExpand, required this.getExpansionState});

  @override
  State<StatefulWidget> createState() => _FilterBarState();

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

  final List<_TimeFilterGranularity> _menuItems = [
    _TimeFilterGranularity.Week,
    _TimeFilterGranularity.Month,
    _TimeFilterGranularity.Year,
  ];

  _TimeFilterGranularity _selectedTimeGranularity = _TimeFilterGranularity.Month;
  DateTime _currentTimePeriod = DateTime.now();

  void _selectNewTimeGranularity(_TimeFilterGranularity granularity) {
    setState(() {
      _selectedTimeGranularity = granularity;
      _currentTimePeriod = DateTime.now();
    });
  }

  void _incremenetCurrentTimePeriod(bool forwards) {
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
    setState(() {
      _currentTimePeriod = newTimePeriod;
    });
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
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _incremenetCurrentTimePeriod(false),
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
            child: Text(_getDisplayedTimePeriod(), style: const TextStyle(fontSize: 18)),
          )
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => _incremenetCurrentTimePeriod(true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          child: Container(
            height: _isExpanded() ? 210 : 90,
            decoration: const BoxDecoration(
              color: Colors.transparent,
            ),
            padding: const EdgeInsets.only(top: 10),
            child: AnimatedContainer(
              duration: _animationTime,
              height: _isExpanded() ? 200 : 80,
              color: Colors.blueGrey,
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
              height: 20,
              width: 80,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.all(Radius.circular(8.0)),
              ),
              child: Icon(
                _isExpanded() ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }

}