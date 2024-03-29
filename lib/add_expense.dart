import 'package:flutter/material.dart';
import 'package:wall_et_al/add_categories.dart';
import 'package:wall_et_al/routes.dart';

import 'add_tags.dart';
import 'calculator.dart';
import 'database.dart';

class AddExpenseRoute extends StatefulWidget {
  final ExpenseEntry? entry;

  const AddExpenseRoute({super.key, this.entry});

  @override
  State<AddExpenseRoute> createState() => _AddExpenseState();
}

class _AddExpenseState extends State<AddExpenseRoute> {
  late Calculator _calculator;
  late TextEditingController _descriptionController;
  late Future<CategoryEntry> _category;
  late DateTime _displayedDate;
  late TimeOfDay _displayedTime;
  late Future<List<TagEntry>> _selectedTags;
  Function? _getFinalAmount;
  String _displayedAmount = "0";

  Future<CategoryEntry> _initCategory() async {
    return (await ExpenseDatabase.instance.getCategories()).firstWhere(
        (CategoryEntry e) => e.id == widget.entry?.categoryId,
        orElse: () => ExpenseDatabase.nullCategory);
  }

  Future<List<TagEntry>> _initTags() async {
    if (widget.entry != null && widget.entry!.id != null ) {
      return ExpenseDatabase.instance.getTagsForExpense(widget.entry!.id!);
    } else {
      return Future.value([]);
    }
  }

  @override
  void initState() {
    _calculator = Calculator(
      onButtonPressed: _setDisplayedAmount,
      getFinalAmountCallback: (Function callback) => _getFinalAmount = callback,
      entry: widget.entry,
    );
    _category = _initCategory();
    _selectedTags = _initTags();
    _descriptionController =
        TextEditingController(text: widget.entry?.description);
    _displayedDate = DateTime.fromMillisecondsSinceEpoch(
        widget.entry?.msSinceEpoch ?? DateTime.now().millisecondsSinceEpoch);
    _displayedTime = TimeOfDay.fromDateTime(_displayedDate);
    super.initState();
  }

  void _setDisplayedAmount(String amount) {
    setState(() {
      _displayedAmount = amount;
    });
  }

  void _raiseError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _getDescription() {
    return _descriptionController.value.text;
  }

  int _getDisplayedDateTimeInMs() {
    return DateTime(_displayedDate.year, _displayedDate.month,
            _displayedDate.day, _displayedTime.hour, _displayedTime.minute)
        .millisecondsSinceEpoch;
  }

  Future<ExpenseEntry> _createExpense(double finalAmount, {int? id}) async {
    return ExpenseEntry(
      id: id,
      amount: finalAmount,
      msSinceEpoch: _getDisplayedDateTimeInMs(),
      description: _getDescription(),
      categoryId: (await _category).id,
    );
  }

  Future<void>? _saveExpense() {
    double finalAmount = _getFinalAmount == null ? 0.0 : _getFinalAmount!();
    if (finalAmount.isNaN) {
      _raiseError("Invalid amount entered");
      return null;
    }

    if (widget.entry == null) {
      return Future.delayed(Duration.zero, () async {
        // Try insert 5 times with retries
        ExpenseEntry e = await _createExpense(finalAmount);
        int status = await ExpenseDatabase.instance.insertExpense(e);

        if (status == 0) {
          _raiseError("Could not add expense to database");
          return;
        }

        var tagFutures = (await _selectedTags)
            .map((e) => ExpenseDatabase().insertTag(status, e))
            .toList();
        var statuses = await Future.wait(tagFutures);
        if (statuses.any((element) => element == 0)) {
          _raiseError("Wasn't able to add all the tags");
        }
      });
    } else {
      return Future.delayed(Duration.zero, () async {
        ExpenseEntry oldEntry = widget.entry!;
        ExpenseEntry newEntry =
            await _createExpense(finalAmount, id: oldEntry.id);
        int status = 0;
        if (oldEntry != newEntry) {
          status = await ExpenseDatabase.instance.updateExpense(newEntry);
          if (status == 0) {
            _raiseError("Could not add expense to database");
          }
        }

        var selectedTagsResolved = await _selectedTags;

        var oldTags =
            await ExpenseDatabase.instance.getTagsForExpense(newEntry.id!);
        var tagsToRemove = oldTags.toSet().difference(selectedTagsResolved.toSet());

        var deletionFutures = tagsToRemove
            .where((element) => element.id != null) .map((e) => ExpenseDatabase.instance
                .deleteTagFromExpense(newEntry.id!, e.id!))
            .toList();
        var insertionFutures = selectedTagsResolved.map((e) => ExpenseDatabase.instance.insertTag(newEntry.id!, e)).toList();
        Future.wait(deletionFutures + insertionFutures);
        return;
      });
    }
  }

  void _handleCategoryPicker(BuildContext context) {
    _resetFocus();
    pushWithSlideUp(context, AddCategoryPage(chosen: _category),
        onFinish: (value) {
      if (value != null) {
        setState(() {
          _category = Future.value(value ?? ExpenseDatabase.nullCategory);
        });
      }
    });
  }

  void _handleTagPicker(BuildContext context) async {
    _resetFocus();

    var tags = await _selectedTags;

    pushWithSlideUp(context,
        TagsPage(expenseId: widget.entry?.id, selectedTags: tags),
        onFinish: (Map<TagEntry, bool> tagsFromWidget) {
      var tags = tagsFromWidget.entries
          .where((element) => element.value)
          .map((e) => e.key)
          .toList();
      tags.sort((a, b) => a.tagName.compareTo(b.tagName));
      setState(() {
        _selectedTags = Future.value(tags);
      });
    });
  }

  Future<void> _handleDatePicker() async {
    _resetFocus();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _displayedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _displayedDate) {
      setState(() {
        _displayedDate = picked;
      });
    }
  }

  Future<void> _handleTimePicker() async {
    _resetFocus();
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _displayedTime,
    );
    if (picked != null && picked != _displayedTime) {
      setState(() {
        _displayedTime = picked;
      });
    }
  }

  static String _twoDigits(int n) {
    if (n >= 10) return "$n";
    return "0$n";
  }

  Widget _getCategoryName(BuildContext context) {
    return IntrinsicWidth(
        child: ActionChip(
            backgroundColor: Theme.of(context).colorScheme.primary,
            onPressed: () => _handleCategoryPicker(context),
            label: FutureBuilder(
                future: _category,
                builder: (BuildContext context,
                    AsyncSnapshot<CategoryEntry> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    String text;
                    IconData icon = Icons.cancel_outlined;

                    if (snapshot.hasError) {
                      text = 'Error: ${snapshot.error}';
                    } else if (!snapshot.hasData) {
                      text = 'Error: no data';
                    } else {
                      CategoryEntry entry = snapshot.data!;
                      icon = entry.icon;
                      text = entry.name;
                    }
                    return Row(children: [
                      Icon(icon,
                          size: 14,
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer),
                      Padding(padding: EdgeInsets.only(left: 5)),
                      Text(text,
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 14))
                    ]);
                  } else {
                    return Text('',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                            fontSize: 14));
                  }
                })));
  }

  Widget tagsWidget(BuildContext context) {
    return FutureBuilder(future: _selectedTags, builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      }

      var resolvedTags = snapshot.data!;

      return ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: resolvedTags.length + 1, // plus one for 'Add Tag' chip
        itemBuilder: (context, index) {
          if (index == resolvedTags.length) {
            // add the 'Add Tag' chip at the end of the list
            return GestureDetector(
              onTap: () async {
                _handleTagPicker(context);
              },
              child: Chip(
                backgroundColor: Theme.of(context).colorScheme.primary,
                label: Text('Add tag',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontSize: 14)),
              ),
            );
          } else {
            return Chip(
              backgroundColor: Theme.of(context).colorScheme.primary,
              label: Text(resolvedTags[index].tagName,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                      fontSize: 14)),
              onDeleted: () {
                setState(() {
                  resolvedTags.removeAt(index);
                  _selectedTags = Future.value(resolvedTags);
                });
              },
              deleteIcon: Icon(Icons.delete,
                  size: 14,
                  color: Theme.of(context).colorScheme.onPrimaryContainer),
            );
          }
        },
        separatorBuilder: (BuildContext context, int index) {
          return Padding(padding: EdgeInsets.only(right: 3));
        },
      );
    }
    );
  }

  Widget _currentAmountDisplay(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Positioned(
            top: 50,
            right: 20,
            child: FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                _displayedAmount,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 58,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Positioned(
              left: 0,
              bottom: 65,
              child: Row(
                children: [
                  SizedBox(
                    width: 175,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                              fontSize: 14),
                        ),
                        Padding(padding: EdgeInsets.all(3)),
                        SizedBox(height: 35, child: _getCategoryName(context)),
                      ],
                    ),
                  ),
                  SizedBox(
                      width: 175,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'Tags',
                              style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onPrimaryContainer,
                                  fontSize: 14),
                            ),
                            Padding(padding: EdgeInsets.all(3)),
                            SizedBox(height: 35, child: tagsWidget(context))
                          ]))
                ],
              )),
          Positioned(
            left: 0,
            bottom: 150,
            child: InkWell(
              onTap: _handleDatePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.calendar_today,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    '${_twoDigits(_displayedDate.day)}-${_twoDigits(_displayedDate.month)}-${_displayedDate.year}',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 120,
            bottom: 150,
            child: InkWell(
              onTap: _handleTimePicker,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.timelapse,
                      color: Theme.of(context).colorScheme.onPrimaryContainer),
                  const SizedBox(width: 8),
                  Text(
                    '${_twoDigits(_displayedTime.hour)}:${_twoDigits(_displayedTime.minute)}',
                    style: TextStyle(
                        color:
                            Theme.of(context).colorScheme.onPrimaryContainer),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 0,
            right: 0,
            child: TextFormField(
              maxLines: 1,
              showCursor: true,
              decoration: InputDecoration(
                labelText: 'Description',
                floatingLabelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 19),
                labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontSize: 17),
                // enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontSize: 17),
              controller: _descriptionController,
            ),
          ),
        ],
      ),
    );
  }

  void _resetFocus() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _resetFocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (widget.entry != null) ...[
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  ExpenseDatabase.instance.removeExpense(widget.entry!);
                  Navigator.of(context).pop();
                },
              )
            ],
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () async {
                Future<void>? saveComplete = _saveExpense();
                if (saveComplete != null) {
                  Navigator.of(context).pop(saveComplete);
                }
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(child: _currentAmountDisplay(context)),
            Expanded(child: _calculator),
          ],
        ),
      ),
    );
  }
}
