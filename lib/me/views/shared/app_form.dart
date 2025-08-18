import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:test_app_divkit/me/views/shared/file_manager.dart';
import 'package:test_app_divkit/me/views/shared/form_control.dart';

import 'app_dropdown_search.dart';
import 'common.dart';

class AppForm extends StatefulWidget {
  final List<FormControl> controls;
  final GlobalKey<FormState> formKey;
  final List<Widget>? children;

  const AppForm({
    super.key,
    required this.controls,
    required this.formKey,
    this.children,
  });

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  final Map<String, dynamic> formData = {};

  @override
  void initState() {
    super.initState();

    // seed formData once
    for (var control in widget.controls) {
      switch (control.type) {
        case ControlType.date:
        case ControlType.time:
          formData[control.name] = control.initialValue;
          break;
        default:
          if (control.controller != null) {
            formData[control.name] = control.controller!.text;
          } else if (control.initialValue != null) {
            formData[control.name] = control.initialValue;
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: widget.formKey,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(16),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            ...widget.controls.map((control) {
              if (!control.visible) {
                return const SizedBox.shrink();
              }

              late Widget field;

              switch (control.type) {
                case ControlType.label:
                  field = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      control.separator ?? const SizedBox.shrink(),
                      Text(control.label, style: control.style),
                    ],
                  );
                  break;

                case ControlType.text:
                  String? validator(String? val, RegExp? regExp) {
                    final text = (val ?? '').trim();

                    if (control.required && text.isEmpty) {
                      return "Ce champ est requis";
                    }

                    if (text.isNotEmpty &&
                        regExp != null &&
                        !regExp.hasMatch(text)) {
                      return "La saisie est incorrecte";
                    }

                    return null;
                  }

                  final regExp = control.pattern != null
                      ? RegExp(control.pattern!)
                      : null;
                  formData[control.name] = control.controller?.text;
                  field = TextFormField(
                    controller: control.controller,
                    keyboardType: control.keyboardType,
                    decoration: InputDecoration(
                      labelText: control.label,
                      suffixText: control.suffixText,
                      hintText: control.hint,
                    ),
                    validator: (val) => validator(val, regExp),
                    onChanged: (val) => formData[control.name] = val,
                    textInputAction: TextInputAction.next,
                  );
                  break;

                case ControlType.textarea:
                  formData[control.name] = control.controller?.text;
                  field = TextFormField(
                    controller: control.controller,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      alignLabelWithHint: true,
                    ).copyWith(labelText: control.label),
                    onChanged: (val) => formData[control.name] = val,
                    validator: control.required
                        ? (val) => (val == null || val.isEmpty)
                              ? "Ce champ est requis"
                              : null
                        : null,
                  );
                  break;

                case ControlType.dropdown:
                  final current =
                      (formData[control.name] as String?) ??
                      control.initialValue;
                  field = DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: current,
                    decoration: InputDecoration(label: Text(control.label)),
                    items: control.options!
                        .map(
                          (e) => DropdownMenuItem(
                            value: e.id.toString(),
                            child: Text(
                              e.libelle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        formData[control.name] = val;
                      });
                      control.onChanged?.call(val);
                    },
                    validator: control.required
                        ? (val) => (val == null || val.isEmpty)
                              ? "Ce champ est requis"
                              : null
                        : null,
                  );
                  break;

                case ControlType.dropdownSearch:
                  field = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6.0),
                      Text(control.label),
                      AppSearchableDropdown(
                        hintText: control.hint,
                        items: control.searchDropdownItems,
                        onChanged: (item) {
                          setState(() {
                            formData[control.name] = item;
                          });
                          control.onChanged?.call(item);
                        },
                        asyncSearch: control.asyncSearch,
                        asyncSearchQuery: control.asyncSearchQuery,
                        required: control.required,
                      ),
                    ],
                  );
                  break;

                case ControlType.date:
                  final current =
                      (formData[control.name] as DateTime?) ??
                      control.initialValue;
                  field = FormField<DateTime>(
                    // ensure unique key
                    key: ValueKey('date_${control.name}'),
                    initialValue: current,
                    validator: control.required
                        ? (val) => val == null ? "Ce champ est requis" : null
                        : null,
                    autovalidateMode: AutovalidateMode.always,
                    builder: (FormFieldState<DateTime> state) {
                      return InkWell(
                        onTap: () async {
                          final pickedDate = await Common.pickDate(context);
                          if (pickedDate != null) {
                            state.didChange(pickedDate);
                            state.validate();
                            setState(() {
                              formData[control.name] = pickedDate;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: control.label,
                            errorText: state.errorText,
                          ),
                          child: Text(
                            state.value != null
                                ? DateFormat.yMMMMd(
                                    'fr_FR',
                                  ).format(state.value!)
                                : "Choisir une date",
                          ),
                        ),
                      );
                    },
                  );
                  break;

                case ControlType.time:
                  final current =
                      (formData[control.name] as TimeOfDay?) ??
                      control.initialValue;
                  field = InkWell(
                    onTap: () async {
                      final pickedTime = await Common.pickTime(context);
                      if (pickedTime != null) {
                        setState(() {
                          formData[control.name] = pickedTime;
                        });
                      }
                    },
                    child: InputDecorator(
                      decoration: InputDecoration(labelText: control.label),
                      child: Text(
                        current != null
                            ? current.format(context)
                            : "Choisir une heure",
                      ),
                    ),
                  );
                  break;

                case ControlType.switchTile:
                  bool extractBool(dynamic value) {
                    if (value is Map) return value['present'] ?? false;
                    if (value is bool) return value;
                    return false;
                  }

                  final currentValue = formData[control.name];
                  final switchIsOn = extractBool(currentValue)
                      ? true
                      : extractBool(control.initialValue);

                  field = SwitchListTile(
                    value: switchIsOn,
                    activeColor: Colors.orange,
                    title: Text(control.label),
                    onChanged: (val) {
                      setState(() {
                        final currentDataForControl = formData[control.name];
                        if (currentDataForControl is Map) {
                          formData[control.name] = {
                            ...currentDataForControl,
                            'present': val,
                          };
                        } else {
                          formData[control.name] = val;
                        }
                      });
                      control.onChanged?.call(val);
                    },
                  );
                  break;

                case ControlType.button:
                  field = control.visible
                      ? (control.child ?? const SizedBox.shrink())
                      : const SizedBox.shrink();
                  break;

                case ControlType.file:
                  field = const FileManagerScreen();
                  break;
              }

              return Padding(
                key: ValueKey(control.name), // stable key per field
                padding: const EdgeInsets.only(bottom: 20),
                child: field,
              );
            }),

            if (widget.children != null) ...widget.children!,

            Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  if (widget.formKey.currentState!.validate()) {
                    Navigator.pop(context, formData);
                  }
                },
                icon: const Icon(Icons.save, color: Colors.white),
                label: const Text(
                  "Enregistrer",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF6A00),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
