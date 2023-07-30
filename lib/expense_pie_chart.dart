import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'database.dart';

class ExpensePieChart extends StatefulWidget {
  final List<ExpenseEntry> expenses;
  final List<CategoryEntry> categories;
  const ExpensePieChart(
      {super.key, required this.expenses, required this.categories});

  @override
  State<StatefulWidget> createState() => PieChartState();
}

class PieChartState extends State<ExpensePieChart> {
  int touchedIndex = -1;

  Widget buildLegend(
      Map<int, double> sumsByCategory, Map<int, CategoryEntry> categoriesById) {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Wrap(
          direction: Axis.horizontal,
          children: sumsByCategory.keys.map((e) {
            return Row(
              mainAxisSize: MainAxisSize
                  .min, // to make the row's width as small as possible
              children: <Widget>[
                Container(
                  width: 20.0,
                  height: 20.0,
                  color: categoriesById[e]?.color,
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(categoriesById[e]?.name ?? ''),
                ),
              ],
            );
          }).toList(),
        ));
  }

  @override
  Widget build(BuildContext context) {
    // group expenses by category
    Map<int, double> sumsByCategory = {};
    for (var expense in widget.expenses) {
      sumsByCategory.update(
          expense.categoryId ?? 1, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    Map<int, CategoryEntry> categoriesById = {};
    for (var category in widget.categories) {
      categoriesById[category.id ?? 1] = category;
    }

    return AspectRatio(
        aspectRatio: 1.0,
        child: Column(
          children: [
            buildLegend(sumsByCategory, categoriesById),
            Expanded(
              child: Row(
                children: <Widget>[
                  const SizedBox(
                    height: 18,
                  ),
                  Expanded(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: PieChart(
                        PieChartData(
                          pieTouchData: PieTouchData(
                            touchCallback:
                                (FlTouchEvent event, pieTouchResponse) {
                              setState(() {
                                if (!event.isInterestedForInteractions ||
                                    pieTouchResponse == null ||
                                    pieTouchResponse.touchedSection == null) {
                                  touchedIndex = -1;
                                  return;
                                }
                                touchedIndex = pieTouchResponse
                                    .touchedSection!.touchedSectionIndex;
                              });
                            },
                          ),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          sectionsSpace: 0,
                          centerSpaceRadius: 100,
                          sections:
                              showingSections(sumsByCategory, categoriesById),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 28,
                  ),
                ],
              ),
            )
          ],
        ));
  }

  List<PieChartSectionData> showingSections(
      Map<int, double> sumsByCategory, Map<int, CategoryEntry> categoriesById) {
    var totalExpenditure = sumsByCategory.values
        .fold(0.0, (previousValue, element) => previousValue + element);
    List<PieChartSectionData> pieSections = [];
    var categoriesToShow = sumsByCategory.keys.toList();

    for (int i = 0; i < sumsByCategory.length; i++) {
      final isTouched = i == touchedIndex;
      final radius = isTouched ? 45.0 : 40.0;
      final amount = sumsByCategory[categoriesToShow[i]] ?? 0;
      final pct = totalExpenditure == 0 ? 0 : amount / totalExpenditure;
      final title = isTouched
          ? '${categoriesById[categoriesToShow[i]]?.name}\n\$${amount.toStringAsFixed(2)}\n${(100 * pct).toStringAsFixed(0)}%'
          : '';
      pieSections.add(PieChartSectionData(
          color: categoriesById[categoriesToShow[i]]?.color,
          value: pct * 360,
          title: title,
          titlePositionPercentageOffset: -2.3,
          radius: radius,
          titleStyle: Theme.of(context).textTheme.titleMedium));
    }
    return pieSections;
  }
}
