import 'package:flutter/material.dart';
import 'package:test_app_divkit/me/views/shared/common.dart';

class DropdownItem {
  final dynamic id;
  final dynamic value;
  final String label;
  bool isSelected;

  DropdownItem({
    required this.value,
    required this.label,
    this.id,
    this.isSelected = false,
  });

  String get key => "$id-$label".hashCode.toString();
}

class AppSearchableDropdown extends FormField<DropdownItem> {
  AppSearchableDropdown({
    super.key,
    required List<DropdownItem> items,
    required Function(DropdownItem) onChanged,
    String? hintText,
    FormFieldValidator<DropdownItem>? validator,
    bool required = false
  }): super (
    validator: required ? (validator ?? (value) => value == null ? "Ce champ est requis" : null) : null,
    builder: (FormFieldState<DropdownItem> state) {
      DropdownItem? selectedItem = state.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 15.0,
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                  decoration: (selectedItem != null)
                      ? BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  )
                      : null,
                  child: Text(
                    selectedItem?.label ??
                        hintText ??
                        "Appuyez le bouton pour selectionner un element",
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.open_in_new_rounded),
                onPressed: () => Common.showBottomSheet(
                  state.context,
                  SearchableSheet(
                    items: items.map((e) {
                      if (e.key == selectedItem?.key) {
                        e.isSelected = true;
                      } else {
                        e.isSelected = false;
                      }

                      return e;
                    }).toList(),
                    onItemSelected: (item) {
                      selectedItem = item;
                      state.didChange(item);
                      onChanged(item);
                    },
                  ),
                ),
              ),
            ],
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Text(
                state.errorText ?? "",
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            )
        ],
      );
    }
  );
}


class SearchableSheet extends StatefulWidget {
  const SearchableSheet({
    super.key,
    required this.items,
    required this.onItemSelected,
  });

  final List<DropdownItem> items;
  final Function(DropdownItem) onItemSelected;

  @override
  State<SearchableSheet> createState() => _SearchableSheetState();
}

class _SearchableSheetState extends State<SearchableSheet> {
  final TextEditingController _controller = TextEditingController();
  late List<DropdownItem> _filteredItems;

  static const Color orangeColor = Color(0xFFFF6A00);

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
              (item) => item.label.toLowerCase().contains(query.toLowerCase()),
            )
            .toList();
      }
    });
  }

  void _selectItem(DropdownItem item) {
    widget.onItemSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      margin: EdgeInsets.only(top: 5.0),
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              onChanged: (query) => _filterItems(query),
              decoration: InputDecoration(
                hintText: "Rechercher un element",
                suffixIcon: Icon(Icons.search),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: orangeColor, width: 2),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredItems.isNotEmpty
                ? ListView.builder(
                    itemCount: _filteredItems.length,
                    itemBuilder: (context, index) {
                      final it = _filteredItems[index];
                      return ListTile(
                        title: Text(
                          it.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                        selected: it.isSelected,
                        trailing: Icon(
                          it.isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: it.isSelected ? orangeColor : Colors.grey,
                        ),
                        onTap: () {
                          if (!it.isSelected) {
                            it.isSelected = true;
                            _selectItem(it);
                            Navigator.pop(context);
                          }
                        },
                      );
                    },
                  )
                : Center(
                    child: Text("La recherche ne correspond a aucun element"),
                  ),
          ),
        ],
      ),
    );
  }
}
