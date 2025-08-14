import 'package:flutter/cupertino.dart';

class StepSixController {
  StepSixController();

  final Map<String, TextEditingController> _controllers = {};

  void setController(String key, String? value) {
    _controllers.putIfAbsent(key, () => TextEditingController(text: value));
  }

  TextEditingController? getController(String key) => _controllers[key];
}