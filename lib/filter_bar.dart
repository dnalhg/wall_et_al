import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FilterBar extends StatefulWidget {
  final Function onExpand;
  final Function getExpansionState;

  const FilterBar({super.key, required this.onExpand, required this.getExpansionState});

  @override
  State<StatefulWidget> createState() => _FilterBarState();

}

class _FilterBarState extends State<FilterBar> {
  final Duration _animationTime = const Duration(milliseconds: 500);

  bool _isExpanded() => widget.getExpansionState();

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