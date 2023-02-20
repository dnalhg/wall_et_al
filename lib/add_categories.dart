import 'package:flutter/material.dart';
import 'package:wall_et_al/constants.dart';
import 'package:wall_et_al/list_item_modal.dart';
import 'package:wall_et_al/side_bar.dart';
import 'package:wall_et_al/wallet_app_bar.dart';

import 'category.dart';

class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  List<Category> _categories = [
    Category("hello", Colors.blue, Icons.shopping_cart)
  ];
  bool _isEditing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WalletAppBar(title: Constants.CATEGORIES_PAGE_TITlE, actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.check : Icons.edit),
          onPressed: _handleEditPress,
        ),
      ]),
      drawer: const SideBar(),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            return Card(
                child: ListTile(
              tileColor: _categories[index].color,
              leading: Icon(_categories[index].icon),
              title: Text(_categories[index].name),
              trailing: _isEditing
                  ? IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _removeTask(index);
                      },
                    )
                  : null,
              onTap: _isEditing
                  ? () {
                      _openAddListItemModal((name, color, icon) {
                        setState(() {
                          _categories[index] = Category(name, color, icon);
                          _isEditing = !_isEditing;
                        });
                      }, _categories[index]);
                    }
                  : null,
            ));
          }),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: () {
                _openAddListItemModal((name, color, icon) {
                  setState(() {
                    _categories.add(Category(name, color, icon));
                    _isEditing = !_isEditing;
                  });
                }, null);
              },
              tooltip: 'Add Task',
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  void _removeTask(int index) {
    setState(() {
      _categories.removeAt(index);
      _isEditing = !_isEditing;
    });
  }

  void _handleEditPress() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _openAddListItemModal(
      Function(String, Color, IconData) onAddItem, Category? category) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ListItemModal(onAddItem: onAddItem, category: category);
        });
  }
}
