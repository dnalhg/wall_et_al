import 'package:flutter/material.dart';
import 'package:wall_et_al/database.dart';

class CategoriesDropDown extends StatefulWidget {
  final int? categoryId;
  final Function onCategorySelection;

  const CategoriesDropDown({super.key, this.categoryId, required this.onCategorySelection});

  @override
  _CategoriesDropDownState createState() => _CategoriesDropDownState();
}

class _CategoriesDropDownState extends State<CategoriesDropDown> {
  late Future<List<CategoryEntry>> _categoryValues;
  int? initCategoryId;

  @override
  void initState() {
    super.initState();
    _categoryValues = _fetchDropdownValues();
    initCategoryId = widget.categoryId;
  }

  Future<List<CategoryEntry>> _fetchDropdownValues() async {
    return ExpenseDatabase.instance.getCategories();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _categoryValues,
      builder: (BuildContext context, AsyncSnapshot<List<CategoryEntry>> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return DropdownButtonFormField(
              value: snapshot.data?.map((e) => e.id).firstWhere((id) => id == initCategoryId, orElse: () => null),
              items: snapshot.data?.map((category) {
                return DropdownMenuItem(
                  value: category.id,
                  child: Text(category.name),
                );
              }).toList(),
              onChanged: (int? categoryId) {
                widget.onCategorySelection(categoryId);
              },
              decoration: InputDecoration(
                labelText: 'Category',
                labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
                border: InputBorder.none,
              ),
            );
          }
        } else {
          return const CircularProgressIndicator();
        }
      },
    );
  }
}