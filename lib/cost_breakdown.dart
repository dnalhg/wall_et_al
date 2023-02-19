import 'package:flutter/material.dart';

class CostBreakdown extends StatefulWidget {
  const CostBreakdown({super.key});

  @override
  State<CostBreakdown> createState() => _CostBreakdownState();
}

class _CostBreakdownState extends State<CostBreakdown>{
  @override
  Widget build (BuildContext context) {
    return Container(
      height: 500,
      margin: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(color: Colors.black12),
      child: const Center(child: Text("hello world")),
    );
  }
}
