import 'package:flutter/material.dart';
import 'package:wall_et_al/database.dart';

class TagsPage extends StatefulWidget {
  final int? expenseId;
  final List<TagEntry> selectedTags;

  const TagsPage(
      {super.key, required this.expenseId, required this.selectedTags});

  @override
  _TagsPageState createState() => _TagsPageState();
}

class _TagsPageState extends State<TagsPage> {
  List<TagEntry> newTags = [];
  Map<TagEntry, bool> mostUpToDateSelectedTags = {};

  @override
  void initState() {
    super.initState();
    newTags =
        widget.selectedTags.where((element) => element.id == null).toList();
    mostUpToDateSelectedTags = {for (var tag in widget.selectedTags) tag: true};
  }

  Future<Set<TagEntry>> getTagsForExpense(int expenseId) async {
    var tags = await ExpenseDatabase.instance.getTagsForExpense(expenseId);
    return tags.toSet();
  }

  void _editTag(TagEntry key) {
    TextEditingController textEditingController =
        TextEditingController(text: key.tagName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Tag'),
          content: TextField(
            controller: textEditingController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: Theme.of(context).textTheme.bodyLarge),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Done', style: Theme.of(context).textTheme.bodyLarge),
              onPressed: () async {
                if (textEditingController.text.isNotEmpty &&
                    textEditingController.text.trim().toLowerCase() !=
                        key.tagName) {
                  var newTagEntry =
                      TagEntry(tagName: textEditingController.text, id: key.id);
                  // If the tag came from the DB do a DB update
                  if (newTagEntry.id != null) {
                    await ExpenseDatabase.instance.updateTag(newTagEntry);
                  }

                  // Otherwise update in place
                  setState(() {
                    var oldTagIndex = newTags.indexOf(key);
                    if (oldTagIndex != -1) {
                      newTags[oldTagIndex] = newTagEntry;
                    }

                    // Maybe reload the future here
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTag() {
    TextEditingController textEditingController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Tag'),
          content: TextField(
            controller: textEditingController,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: Theme.of(context).textTheme.bodyLarge),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Done', style: Theme.of(context).textTheme.bodyLarge),
              onPressed: () async {
                // If editing existing expense: only create new tag in DB if they end up selecting it
                // If creating new expense: only create new tag in DB if they end up saving the expense
                if (textEditingController.text.isNotEmpty) {
                  var newTag = TagEntry(tagName: textEditingController.text);
                  var existingTags = await ExpenseDatabase.instance.getTags();
                  var maybeExistingTag = existingTags.firstWhere(
                      (element) => element.tagName == newTag.tagName,
                      orElse: () => newTag);

                  // This tag name already exists in the DB, no point in writing it again
                  if (maybeExistingTag != newTag) {
                    Navigator.of(context).pop();
                    return;
                  }

                  setState(() {
                    if (!newTags.contains(newTag)) {
                      newTags.add(newTag);
                    }
                    mostUpToDateSelectedTags[newTag] = true;
                  });
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Future<List<TagEntry>> tagsList = ExpenseDatabase.instance.getTags();
    Future<Set<TagEntry>> selectedTags;
    if (widget.expenseId != null) {
      selectedTags = getTagsForExpense(widget.expenseId!);
    } else {
      selectedTags = Future.value({});
    }

    return FutureBuilder<dynamic>(
        future: Future.wait([tagsList, selectedTags]),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

          List<TagEntry> tags = newTags;
          Set<TagEntry> wasSelected = mostUpToDateSelectedTags.entries
              .where((element) => element.value)
              .map((e) => e.key)
              .toSet();
          if (snapshot.hasData) {
            List<dynamic> data = snapshot.data;
            if (data.isNotEmpty) {
              tags = snapshot.data![0] + newTags;
            }
            if (data.length >= 2) {
              wasSelected = snapshot.data[1]!;

                wasSelected.forEach((element) {
                  if (mostUpToDateSelectedTags[element] == null) {
                    mostUpToDateSelectedTags[element] = false;
                  }
                });

              mostUpToDateSelectedTags.forEach((key, value) {
                if (!value && wasSelected.contains(key)) {
                  wasSelected.remove(key);
                } else if (value) {
                  wasSelected.add(key);
                }
              });
            }
          }

          return Scaffold(
            appBar: AppBar(
              title: Text('Edit tags'),
              leading: IconButton(
                icon: Icon(Icons.close),
                onPressed: () =>
                    Navigator.of(context).pop(mostUpToDateSelectedTags),
              ),
            ),
            body:


            ListView.builder(
              itemCount: tags.length + 1,
              itemBuilder: (context, index) {
                if (index == tags.length) {
                  return ListTile(
                    title: TextButton(
                      onPressed: () => _addTag(),
                      child: Text('Add Tag', style: Theme.of(context).textTheme.bodyLarge),
                    ),
                  );
                }

                return Dismissible(
                  key: Key(tags[index].tagName),
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12.0),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  confirmDismiss: (direction) async {
                    if (widget.expenseId != null && tags[index].id != null) {
                      await ExpenseDatabase.instance.deleteTag(tags[index].id!);
                    }
                    setState(() {
                      newTags.remove(tags[index]);
                      print(mostUpToDateSelectedTags);
                      mostUpToDateSelectedTags.remove(tags[index]);
                      print(mostUpToDateSelectedTags);
                    });
                    return true;
                  },
                  child: ListTile(
                    onTap: () => _editTag(tags[index]),
                    leading: Checkbox(
                      value: wasSelected.contains(tags[index]),
                      onChanged: (newValue) {
                        setState(() {
                          if (newValue != null) {
                            mostUpToDateSelectedTags[tags[index]] = newValue;
                          }
                        });
                      },
                    ),
                    title: Text(tags[index].tagName),
                  ),
                );
              },
            ),
          );
        });
  }
}
