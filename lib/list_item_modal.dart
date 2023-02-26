import 'package:flutter/material.dart';
import 'package:wall_et_al/constants.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:wall_et_al/database.dart';


class ListItemModal extends StatefulWidget {
  final Function(String, Color, IconData) onAddItem;
  final CategoryEntry? category;

  ListItemModal({super.key, required this.onAddItem, this.category});

  @override
  _ListItemModalState createState() => _ListItemModalState();
}

class _ListItemModalState extends State<ListItemModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late Color _selectedColor;
  late IconData _icon;
  bool _isButtonEnabled = false;

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
    _textController.addListener(_onTextChanged);
    _selectedColor = widget.category?.color ?? Colors.blue;
    _icon = widget.category?.icon ?? _icons.first;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isButtonEnabled = _textController.text.isNotEmpty;
    });
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
    return AlertDialog(
      title: Text(widget.category != null ? 'Edit Item' : 'Add Item'),
      content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                IconButton(
                  onPressed: _selectColor,
                  icon: Icon(Icons.color_lens_rounded),
                  color: _selectedColor,
                ),
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      labelText: 'Text',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
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
            )
          ])),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: !_isButtonEnabled
              ? null
              : () => {
                    if (_formKey.currentState!.validate()) {_submit()}
                  },
          child: Text(widget.category != null ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
