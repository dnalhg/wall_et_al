import 'package:flutter/material.dart';
import 'package:wall_et_al/constants.dart';
import 'package:wall_et_al/database.dart';
import 'package:wall_et_al/list_item_modal.dart';
import 'package:wall_et_al/side_bar.dart';
import 'package:wall_et_al/wallet_app_bar.dart';


class AddCategoryPage extends StatefulWidget {
  const AddCategoryPage({super.key});

  @override
  _AddCategoryPageState createState() => _AddCategoryPageState();
}

class _AddCategoryPageState extends State<AddCategoryPage> {
  Future<List<CategoryEntry>>? _categoriesFuture;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _loadCategories();
  }

  Future<List<CategoryEntry>> _loadCategories() async {
    return await ExpenseDatabase.instance.getCategories();
  }

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
      body: FutureBuilder<List<CategoryEntry>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<CategoryEntry> _categories = snapshot.data!;

            return ListView.builder(
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
                        _removeCategory(_categories[index]);
                      },
                    )
                        : null,
                    onTap: _isEditing
                        ? () {
                      _openAddListItemModal((name, color, icon) {
                        _updateCategory(_categories[index]);
                      }, _categories[index]);
                    }
                        : null,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: () {
                _openAddListItemModal((name, color, icon) {
                  setState(() {
                    _addCategory(CategoryEntry(name: name, color: color, icon: icon));
                  });
                }, null);
              },
              tooltip: 'Add Task',
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  void _addCategory(CategoryEntry c) async {
    await ExpenseDatabase.instance.addCategory(c);
    setState(() {
      _categoriesFuture = _loadCategories();
      _isEditing = !_isEditing;
    });
  }

  void _removeCategory(CategoryEntry c) async {
    await ExpenseDatabase.instance.removeCategory(c);
    setState(() {
      _categoriesFuture = _loadCategories();
    });
  }

  void _handleEditPress() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _openAddListItemModal(
      Function(String, Color, IconData) onAddItem, CategoryEntry? category) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return ListItemModal(onAddItem: onAddItem, category: category);
        });
  }

  void _updateCategory(CategoryEntry category) {
    setState(() {
      ExpenseDatabase.instance.updateCategory(category);
      _categoriesFuture = _loadCategories();
      _isEditing = !_isEditing;
    });

  }
}
