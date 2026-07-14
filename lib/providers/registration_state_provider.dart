import 'package:flutter/foundation.dart';

class RegistrationStateProvider extends ChangeNotifier {
  bool _inProgress = false;

  bool get inProgress => _inProgress;

  void start() {
    _inProgress = true;
    notifyListeners();
  }

  void end() {
    _inProgress = false;
    notifyListeners();
  }
}