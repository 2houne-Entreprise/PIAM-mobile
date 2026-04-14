import 'package:flutter/material.dart';
import '../../models/form.dart';
import '../../services/form_controller.dart';

class FormProvider extends ChangeNotifier {
  final FormController formController;
  FormModel? _currentForm;
  Map<String, int> _dashboardStats = {};
  List<FormModel> _userForms = [];
  bool _loading = false;

  FormProvider({required this.formController});

  FormModel? get currentForm => _currentForm;
  Map<String, int> get dashboardStats => _dashboardStats;
  List<FormModel> get userForms => _userForms;
  bool get loading => _loading;

  // Charger un formulaire pour édition/reprise
  Future<void> loadForm(int id) async {
    _loading = true;
    notifyListeners();
    _currentForm = await formController.loadForm(id);
    _loading = false;
    notifyListeners();
  }

  // Sauvegarder à chaque modification de champ
  Future<void> updateForm(FormModel form) async {
    _currentForm = form;
    await formController.onFieldChange(form);
    notifyListeners();
  }

  // Charger les stats dashboard
  Future<void> fetchDashboardStats() async {
    _dashboardStats = await formController.getDashboardStats();
    notifyListeners();
  }

  // Lister les formulaires utilisateur
  Future<void> fetchUserForms() async {
    _userForms = await formController.getUserForms();
    notifyListeners();
  }
}
