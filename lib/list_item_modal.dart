import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:wall_et_al/database.dart';

class ListItemModal extends StatefulWidget {
  final Function(String, Color, IconData) onAddItem;
  final CategoryEntry? category;

  const ListItemModal({super.key, required this.onAddItem, this.category});

  @override
  State<ListItemModal> createState() => _ListItemModalState();
}

class _ListItemModalState extends State<ListItemModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _textController;
  late Color _selectedColor;
  Color? _colorPickerSelectedColor;
  late IconData _icon;
  bool _isButtonEnabled = false;
  bool _isDropdownVisible = true;

  final List<IconData> _icons = [
    Icons.local_atm,
    Icons.fastfood,
    Icons.local_gas_station,
    Icons.train,
    Icons.home,
    Icons.shopping_cart,
    Icons.beach_access,
    Icons.local_hospital,
    Icons.apple,
    Icons.fitness_center,
    Icons.card_giftcard,
    Icons.school,
    Icons.local_movies,
    Icons.laptop_chromebook,
  ];

  final List<Color> colorPalette = [
    const Color(0xffDF7861),
    const Color(0xffF9D657),
    const Color(0xff364F6B),
    const Color(0xff008891),
    const Color(0xff3FC1C9),
    const Color(0xffFC5185),
    const Color(0xff161D6F),
    const Color(0xff7FFF97),
    const Color(0xffFFD25A),
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.category?.name ?? '');
    _textController.addListener(_onTextChanged);
    _selectedColor = widget.category?.color ?? colorPalette[0];
    if (!colorPalette.contains(_selectedColor)) {
      _colorPickerSelectedColor = _selectedColor;
    }
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

  void _selectColor() async {
    setState(() {
      _isDropdownVisible = false;
    });
    Future.delayed(const Duration(milliseconds: 100))
        .then((value) => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Select a color'),
                  content: SingleChildScrollView(
                    child: ColorPicker(
                      pickerColor: _colorPickerSelectedColor ?? Colors.red,
                      onColorChanged: (Color color) {
                        setState(() {
                          _colorPickerSelectedColor = color;
                        });
                      },
                      labelTypes: const [],
                      pickerAreaHeightPercent: 0.8,
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('OK'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                        if (_colorPickerSelectedColor != null) {
                          setState(() {
                            _selectedColor = _colorPickerSelectedColor!;
                            _isDropdownVisible = true;
                          });
                        }
                      },
                    ),
                  ],
                );
              },
            ));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category != null ? 'Edit Item' : 'Add Item',
          style: Theme.of(context).textTheme.titleLarge),
      content: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: InputDecoration(
                      prefixIcon: _isDropdownVisible
                          ? DropdownButtonHideUnderline(
                              child: DropdownButton<Color>(
                              hint: Text(''),
                              value: _selectedColor,
                              onChanged: (Color? value) {
                                if (!colorPalette.contains(value)) {
                                  _selectColor();
                                } else {
                                  setState(() => _selectedColor = value!);
                                }
                              },
                              items: colorPalette
                                  .map<DropdownMenuItem<Color>>((Color value) {
                                return DropdownMenuItem<Color>(
                                  value: value,
                                  child: Container(
                                    width: 20,
                                    height: 20,
                                    color: value,
                                  ),
                                );
                              }).toList()
                                ..add(DropdownMenuItem(
                                  onTap: _selectColor,
                                  value: _colorPickerSelectedColor,
                                  child: Icon(Icons.color_lens,
                                      color: _colorPickerSelectedColor),
                                )),
                            ))
                          : Text(''),
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
            const SizedBox(height: 16),
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
          child: Text('Cancel', style: Theme.of(context).textTheme.labelLarge),
        ),
        TextButton(
          onPressed: !_isButtonEnabled
              ? null
              : () => {
                    if (_formKey.currentState!.validate()) {_submit()}
                  },
          child: Text(widget.category != null ? 'Save' : 'Add',
              style: Theme.of(context).textTheme.labelLarge),
        ),
      ],
    );
  }
}
