import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchableDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final T? selectedItem;
  final String label;

  const SearchableDropdown({
    super.key,
    required this.items,
    required this.itemAsString,
    required this.onChanged,
    this.selectedItem,
    required this.label,
  });

  @override
  State<SearchableDropdown<T>> createState() => _SearchableDropdownState<T>();
}

class _SearchableDropdownState<T> extends State<SearchableDropdown<T>> {
  final TextEditingController _controller = TextEditingController();
  List<T> filteredItems = [];
  bool isDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
    if (widget.selectedItem != null) {
      _controller.text = widget.itemAsString(widget.selectedItem!);
    }
  }

  void _filter(String input) {
    setState(() {
      filteredItems = widget.items
          .where((item) => widget
          .itemAsString(item)
          .toLowerCase()
          .contains(input.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label),
        const SizedBox(height: 4),
        TextField(
          controller: _controller,
          onChanged: (value) {
            _filter(value);
            setState(() => isDropdownOpen = true);
          },
          onTap: () => setState(() => isDropdownOpen = true),
          decoration: InputDecoration(
            border: OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down),
              onPressed: () {
                setState(() => isDropdownOpen = !isDropdownOpen);
              },
            ),
          ),
        ),
        if (isDropdownOpen)
          Container(
            height: 150,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(6),
                color: Colors.white),
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return ListTile(
                  title: Text(widget.itemAsString(item)),
                  onTap: () {
                    _controller.text = widget.itemAsString(item);
                    widget.onChanged(item);
                    setState(() => isDropdownOpen = false);
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}