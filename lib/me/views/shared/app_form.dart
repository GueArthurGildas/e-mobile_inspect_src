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

    for (var control in widget.controls) {
      switch (control.type) {
        case ControlType.date:
          formData[control.name] = control.initialValue;
          break;
        case ControlType.time:
          formData[control.name] = control.initialValue;
          break;
        // case ControlType.switchTile:
        //   formData[control.name] = control.initialValue ?? false;
        //   break;
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
    return Form(
      key: widget.formKey,
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16),
        children: [
          ...widget.controls.map((control) {
            Widget field;

            switch (control.type) {
              case ControlType.label:
                field = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    control.separator ?? SizedBox.shrink(),
                    Text(control.label, style: control.style),
                  ],
                );

              case ControlType.text:
                formData[control.name] = control.controller?.text;
                field = TextFormField(
                  controller: control.controller,
                  decoration: InputDecoration(
                    labelText: control.label,
                    suffixText: control.suffixText,
                    hintText: control.hint,
                  ),
                  validator: control.required
                      ? (val) => (val == null || val.isEmpty)
                            ? "Ce champ est requis"
                            : null
                      : null,
                  onChanged: (val) {
                    formData[control.name] = val;
                  },
                );
                break;

              case ControlType.textarea:
                formData[control.name] = control.controller?.text;
                field = TextFormField(
                  controller: control.controller,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: control.label,
                    alignLabelWithHint: true,
                  ),
                  onChanged: (val) {
                    formData[control.name] = val;
                  },
                  validator: control.required
                      ? (val) => (val == null || val.isEmpty)
                            ? "Ce champ est requis"
                            : null
                      : null,
                );
                break;

              case ControlType.dropdown:
                formData[control.name] = control.initialValue;
                field = DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: control.initialValue,
                  decoration: InputDecoration(labelText: control.label),
                  items: control.options!
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id.toString(),
                          child: Text(e.libelle, maxLines: 1, overflow: TextOverflow.ellipsis,),
                        ),
                      )
                      .toList(),
                  onChanged: (val) {
                    formData[control.name] = val;
                    if (control.onChanged != null) control.onChanged!(val);
                  },
                  validator: control.required
                      ? (val) => val == null || val.isEmpty
                            ? "Ce champ est requis"
                            : null
                      : null,
                );
                break;

              case ControlType.dropdownSearch:
                field = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 5.0,
                  children: [
                    const SizedBox(height: 6.0,),
                    Text(control.label),
                    AppSearchableDropdown(
                      hintText: control.hint,
                      items: control.searchDropdownItems,
                      onChanged: (item) {
                        formData[control.name] = item;
                        control.onChanged!(item);
                      },
                      required: control.required,
                    )
                  ],
                );
                break;

              case ControlType.date:
                field = FormField<DateTime>(
                  initialValue: control.initialValue,
                  // DateTime.now(),
                  onSaved: (value) {
                    if (value != null) {
                      setState(() {
                        formData[control.name] = value;
                      });
                    }
                  },
                  validator: control.required
                      ? (val) => val == null ? "Ce champ est requis" : null
                      : null,
                  builder: (FormFieldState<DateTime> state) {
                    return InkWell(
                      onTap: () async {
                        final pickedDate = await Common.pickDate(context);
                        if (pickedDate != null) {
                          state.didChange(pickedDate);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: control.label,
                          errorText: state.errorText,
                        ),
                        child: Text(
                          state.value != null
                              ? DateFormat.yMMMMd('fr_FR').format(state.value!)
                              : "Choisir une date",
                        ),
                      ),
                    );
                  },
                );
                break;

              case ControlType.time:
                final time =
                    control.initialValue ??
                    formData[control.name] as TimeOfDay?;
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
                      time != null ? time.format(context) : "Choisir une heure",
                    ),
                  ),
                );
                break;

              case ControlType.switchTile:
                dynamic currentValue = formData[control.name];
                bool switchIsOn;

                if (currentValue is Map) {
                  switchIsOn = currentValue['present'] ?? false;
                } else if (currentValue is bool) {
                  switchIsOn = currentValue;
                } else {
                  switchIsOn = (control.initialValue is Map)
                      ? (control.initialValue['present'] ?? false)
                      : (control.initialValue ?? false);
                }

                field = SwitchListTile(
                  value: switchIsOn,
                  activeColor: Colors.orange,
                  title: Text(control.label),
                  onChanged: (val) {
                    setState(() {
                      var currentDataForControl = formData[control.name];
                      if (currentDataForControl is Map) {
                        formData[control.name] = Map<String, dynamic>.from({
                          ...currentDataForControl,
                          'present': val,
                        });
                      } else {
                        formData[control.name] = val;
                      }
                    });
                    if (control.onChanged != null) control.onChanged!(val);
                  },
                );
                break;

              case ControlType.button:
                field = control.visible
                    ? control.child ?? SizedBox.shrink()
                    : SizedBox.shrink();

              case ControlType.file:
                field = FileManagerScreen();

              // case ControlType.controlsField:
              //   field = Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(
              //         control.label,
              //         style: const TextStyle(fontWeight: FontWeight.w600),
              //       ),
              //       const SizedBox(height: 10),
              //       ...?control.fields?.map(
              //         (nestedField) => Padding(
              //           padding: const EdgeInsets.only(top: 8.0),
              //           child: TextFormField(
              //             controller: nestedField.controller,
              //             decoration: InputDecoration(
              //               labelText: nestedField.label,
              //               suffixText: nestedField.suffixText,
              //               hintText: nestedField.hint,
              //             ),
              //             validator: nestedField.required
              //                 ? (val) => (val == null || val.isEmpty)
              //                       ? "Ce champ est requis"
              //                       : null
              //                 : null,
              //           ),
              //         ),
              //       ),
              //     ],
              //   );
              //   break;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: field,
            );
          }),

          if (widget.children != null) ...widget.children!,

          Padding(
            padding: EdgeInsets.only(top: 25.0),
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
    );
  }
}
