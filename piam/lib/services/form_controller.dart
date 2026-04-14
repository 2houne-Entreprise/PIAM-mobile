import '../models/form.dart';
import 'form_sync_service.dart';
import 'form_resume_service.dart';
import 'dashboard_service.dart';
import 'form_service.dart';

class FormController {
  final FormSyncService syncService;
  final FormResumeService resumeService;
  final DashboardService dashboardService;
  final FormService formService;

  FormController({
    required this.syncService,
    required this.resumeService,
    required this.dashboardService,
    required this.formService,
  });

  // Appelé à chaque modification de champ
  Future<void> onFieldChange(FormModel form) async {
    await syncService.saveOrUpdateForm(form);
  }

  // Pour la reprise d'un formulaire
  Future<FormModel?> loadForm(int id) async {
    return await resumeService.loadForm(id);
  }

  // Pour afficher le dashboard
  Future<Map<String, int>> getDashboardStats() async {
    return await dashboardService.getStats();
  }

  // Pour lister les formulaires utilisateur
  Future<List<FormModel>> getUserForms() async {
    return await formService.getForms();
  }
}
