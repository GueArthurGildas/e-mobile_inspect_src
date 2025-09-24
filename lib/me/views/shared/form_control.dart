import 'package:flutter/material.dart';
import 'package:e_Inspection_APP/me/views/shared/app_dropdown_search.dart';
import 'package:e_Inspection_APP/me/views/shared/file_manager.dart';

enum ControlType {
  label,
  text,
  dropdown,
  dropdownSearch,
  date,
  time,
  switchTile,
  textarea,
  button,
  file
  // controlsField,
}

class DropdownOption {
  final int id;
  final String libelle;

  DropdownOption({required this.id, required this.libelle});
}

class FormControl {
  final ControlType type;
  final String name;
  final String label;
  final String? hint;
  final String? suffixText;
  final List<DropdownOption>? options;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool required;
  final bool asyncSearch;
  final SearchQuery? asyncSearchQuery;
  final void Function(dynamic)? onChanged;
  final dynamic initialValue;
  final List<FormControl>? fields;
  final List<LocalFileItem> fileItems;
  final List<DropdownItem> searchDropdownItems;
  final TextStyle? style;
  final Widget? separator;
  final Widget? child;
  final bool visible;

  FormControl({
    required this.type,
    required this.name,
    required this.label,
    this.visible = true,
    this.hint,
    this.suffixText,
    this.options,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.required = false,
    this.onChanged,
    this.initialValue,
    this.fields,
    this.fileItems = const [],
    this.searchDropdownItems = const [],
    this.asyncSearch = false,
    this.asyncSearchQuery,
    this.style,
    this.separator,
    this.child
  });
}
