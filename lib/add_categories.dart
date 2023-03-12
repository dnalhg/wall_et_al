import 'package:flutter/material.dart';
import 'package:wall_et_al/constants.dart';
import 'package:wall_et_al/database.dart';
import 'package:wall_et_al/list_item_modal.dart';
import 'package:wall_et_al/side_bar.dart';
import 'package:wall_et_al/wallet_app_bar.dart';


class AddCategoryPage extends StatefulWidget {
  bool isChoosing;

  AddCategoryPage({super.key, required this.isChoosing});

  @override
  State<AddCategoryPage> createState() => _AddCategoryPageState();
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

  void _handleTileTap(BuildContext context, CategoryEntry entry) {
    if (_isEditing) {
      if (entry.id == ExpenseDatabase.nullCategory.id) {
        return;
      }
      _openAddListItemModal((name, color, icon) {
        _updateCategory(entry);
      }, entry);
    } else if (widget.isChoosing) {
      Navigator.of(context).pop(entry);
    }
    return;
  }

  Widget? _buildCategoryDeletionButton(CategoryEntry entry) {
    if (_isEditing) {
      if (entry.id == ExpenseDatabase.nullCategory.id) {
        return null;
      }

      return IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          _removeCategory(entry);
        },
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WalletAppBar(title: Constants.CATEGORIES_PAGE_TITlE, actions: [
        IconButton(
          icon: Icon(_isEditing ? Icons.check : Icons.edit),
          onPressed: _handleEditPress,
        ),
      ], showMenuButton: !widget.isChoosing),
      drawer: const SideBar(),
      body: FutureBuilder<List<CategoryEntry>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final List<CategoryEntry> categories = snapshot.data!;

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    tileColor: categories[index].color,
                    leading: Icon(categories[index].icon),
                    title: Text(categories[index].name),
                    trailing: _buildCategoryDeletionButton(categories[index]),
                    onTap: () => _handleTileTap(context, categories[index]),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              onPressed: () {
                _openAddListItemModal((name, color, icon) {
                  setState(() {
                    _addCategory(CategoryEntry(name: name, color: color, icon: icon));
                  });
                }, null);
              },
              child: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary),
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
