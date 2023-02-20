import 'package:flutter/material.dart';
import 'package:wall_et_al/constants.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'category.dart';

class ListItemModal extends StatefulWidget {
  final Function(String, Color, IconData) onAddItem;
  final Category? category;

  ListItemModal({super.key, required this.onAddItem, this.category});

  @override
  _ListItemModalState createState() => _ListItemModalState();
}

class _ListItemModalState extends State<ListItemModal> {
  late TextEditingController _textController;
  late Color _selectedColor;
  late IconData _icon;

  final List<IconData> _icons = [
    Icons.shopping_cart,
    Icons.work,
    Icons.school,
    Icons.restaurant,
    Icons.directions_run,
    Icons.local_gas_station,
    Icons.hotel,
    Icons.local_movies,
    Icons.local_activity,
    Icons.music_note
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.category?.name ?? '');
    _selectedColor = widget.category?.color ?? Colors.blue;
    _icon = widget.category?.icon ?? _icons.first;
  }

  void _submit() {
    widget.onAddItem(_textController.value.text, _selectedColor, _icon);
    Navigator.of(context).pop();
  }

  void _selectColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: _selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  _selectedColor = color;
                });
              },
              showLabel: true,
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
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
    return Dialog(
      child: Container(
        padding: Constants.DEFAULT_EDGE_INSETS,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    _selectColor();
                  },
                  child: Container(
                    height: 36,
                    width: 36,
                    decoration: BoxDecoration(
                      color: _selectedColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                const SizedBox(height: 16, width: 16),
                Expanded(
                    child: TextFormField(
                      controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Enter Category Name',
                  ),
                )),
              ],
            ),
            SizedBox(height: 16.0),
            Text('Select an icon'),
            SizedBox(height: 8.0),
            Wrap(
              spacing: 8.0,
              children: _icons
                  .map((icon) => GestureDetector(
                        onTap: () {
                          setState(() {
                            _icon = icon;
                          });
                        },
                        child: Icon(
                          icon,
                          size: 32.0,
                          color: _icon == icon ? Colors.white : Colors.grey,
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('CANCEL'),
                ),
                SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _textController.value.text.isEmpty ? null : _submit,
                  child: Text('ADD'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
