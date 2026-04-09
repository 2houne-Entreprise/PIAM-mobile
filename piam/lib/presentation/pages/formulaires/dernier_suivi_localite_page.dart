import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/widgets/app_form_fields.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';

/// Formulaire — Dernier Suivi Localité
///
/// Ce formulaire suit le pattern recommandé pour tous les formulaires PIAM :
///   1. [initState] → n'initialise que les controllers
///   2. [_onLocalisationLoaded] → appelé par [FormHeaderWidget] quand la
///      localité est connue → charge les données depuis SQLite
///   3. [_save] → valide + sauvegarde via [DatabaseService.upsertQuestionnaire]
///   4. Les données persistent : quitter et revenir affiche les dernières valeurs
class DernierSuiviLocalitePage extends StatefulWidget {
  final String formulaireId;

  const DernierSuiviLocalitePage({Key? key, required this.formulaireId})
      : super(key: key);

  @override
  State<DernierSuiviLocalitePage> createState() =>
      _DernierSuiviLocalitePageState();
}

class _DernierSuiviLocalitePageState
    extends State<DernierSuiviLocalitePage> {
  // ── Clés et état ─────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSaved = false; // true après un enregistrement réussi

  // Données de localisation (renseignées par FormHeaderWidget)
  int? _localiteId;
  dynamic _userId;

  // ── Controllers (un par champ de saisie) ─────────────────────────────────

  // Date
  final _dateController = TextEditingController();

  // Données générales
  final _nbMenagesEnquetesController = TextEditingController();
  final _nbTotalLatrinesController = TextEditingController();
  final _nbLatrinesAmelioreesCtr = TextEditingController();
  final _nbLatrinesNonAmelioreesCtr = TextEditingController();

  // Gestion
  final _nbLatrinesAmelioreesHygieniqueCtr = TextEditingController();
  final _nbLatrinesAmelioreesParageesCtr = TextEditingController();
  final _nbLatrinesNonFonctionellesCtr = TextEditingController();

  // État
  final _nbLatrinesEndommaggersCtr = TextEditingController();
  final _nbMenagesUtilisantVoisinCtr = TextEditingController();
  final _nbMenagesDALCtr = TextEditingController();

  // Réalisations
  final _nbNouvellesLatrinesCtr = TextEditingController();
  final _nbLatrinesAutofinanceesCtr = TextEditingController();
  final _nbLatrinesAideExterieureCtr = TextEditingController();
  final _nbLatrinesFinanceesCommunauteCtr = TextEditingController();

  // Investissement
  final _montantInvestiMenagesCtr = TextEditingController();

  // DLM
  final _nbLatrinesDLMCtr = TextEditingController();
  final _nbDlmEauSavonCtr = TextEditingController();
  final _nbDlmEauSansSavonCtr = TextEditingController();
  final _nbMenagesSansDLMCtr = TextEditingController();

  // ── Cycle de vie ──────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Libérer tous les controllers pour éviter les fuites mémoire
    _dateController.dispose();
    _nbMenagesEnquetesController.dispose();
    _nbTotalLatrinesController.dispose();
    _nbLatrinesAmelioreesCtr.dispose();
    _nbLatrinesNonAmelioreesCtr.dispose();
    _nbLatrinesAmelioreesHygieniqueCtr.dispose();
    _nbLatrinesAmelioreesParageesCtr.dispose();
    _nbLatrinesNonFonctionellesCtr.dispose();
    _nbLatrinesEndommaggersCtr.dispose();
    _nbMenagesUtilisantVoisinCtr.dispose();
    _nbMenagesDALCtr.dispose();
    _nbNouvellesLatrinesCtr.dispose();
    _nbLatrinesAutofinanceesCtr.dispose();
    _nbLatrinesAideExterieureCtr.dispose();
    _nbLatrinesFinanceesCommunauteCtr.dispose();
    _montantInvestiMenagesCtr.dispose();
    _nbLatrinesDLMCtr.dispose();
    _nbDlmEauSavonCtr.dispose();
    _nbDlmEauSansSavonCtr.dispose();
    _nbMenagesSansDLMCtr.dispose();
    super.dispose();
  }

  // ── Chargement des données sauvegardées ───────────────────────────────────

  /// Appelé par [FormHeaderWidget] dès que la localité est connue.
  /// C'est ici qu'on charge les données depuis SQLite pour pré-remplir
  /// les champs du formulaire.
  void _onLocalisationLoaded(int? localiteId, dynamic userId) {
    setState(() {
      _localiteId = localiteId;
      _userId = userId;
    });
    if (localiteId != null) {
      _loadSavedData(localiteId);
    }
  }

  /// Lit les données depuis SQLite et remplit les controllers.
  Future<void> _loadSavedData(int localiteId) async {
    final db = DatabaseService();
    final data = await db.getQuestionnaire(
      type: 'dernier_suivi_localite',
      localiteId: localiteId,
    );

    if (data == null || !mounted) return;

    // Remplir les controllers avec les valeurs sauvegardées
    _dateController.text = data['dateActivite'] ?? '';
    _nbMenagesEnquetesController.text = data['nbMenagesEnquetes']?.toString() ?? '';
    _nbTotalLatrinesController.text = data['nbTotalLatrines']?.toString() ?? '';
    _nbLatrinesAmelioreesCtr.text = data['nbLatrinesAmeliorees']?.toString() ?? '';
    _nbLatrinesNonAmelioreesCtr.text = data['nbLatrinesNonAmeliorees']?.toString() ?? '';
    _nbLatrinesAmelioreesHygieniqueCtr.text = data['nbLatrinesAmelioreesHygienique']?.toString() ?? '';
    _nbLatrinesAmelioreesParageesCtr.text = data['nbLatrinesAmelioreesPartagees']?.toString() ?? '';
    _nbLatrinesNonFonctionellesCtr.text = data['nbLatrinesNonFonctionnelles']?.toString() ?? '';
    _nbLatrinesEndommaggersCtr.text = data['nbLatrinesEndommagees']?.toString() ?? '';
    _nbMenagesUtilisantVoisinCtr.text = data['nbMenagesUtilisantVoisin']?.toString() ?? '';
    _nbMenagesDALCtr.text = data['nbMenagesDAL']?.toString() ?? '';
    _nbNouvellesLatrinesCtr.text = data['nbNouvellesLatrinesConstruites']?.toString() ?? '';
    _nbLatrinesAutofinanceesCtr.text = data['nbLatrinesAutofinancees']?.toString() ?? '';
    _nbLatrinesAideExterieureCtr.text = data['nbLatrinesAideExterieure']?.toString() ?? '';
    _nbLatrinesFinanceesCommunauteCtr.text = data['nbLatrinesFinanceesCommunaute']?.toString() ?? '';
    _montantInvestiMenagesCtr.text = data['montantInvestiMenages']?.toString() ?? '';
    _nbLatrinesDLMCtr.text = data['nbLatrinesDLM']?.toString() ?? '';
    _nbDlmEauSavonCtr.text = data['nbDlmEauSavon']?.toString() ?? '';
    _nbDlmEauSansSavonCtr.text = data['nbDlmEauSansSavon']?.toString() ?? '';
    _nbMenagesSansDLMCtr.text = data['nbMenagesSansDLM']?.toString() ?? '';

    if (mounted) {
      setState(() => _isSaved = true);
    }
  }

  // ── Enregistrement ────────────────────────────────────────────────────────

  /// Valide le formulaire et sauvegarde les données dans SQLite.
  ///
  /// Utilise [upsertQuestionnaire] : une seule ligne en base par localité.
  /// Ne ferme PAS la page après enregistrement — les données restent visibles.
  Future<void> _save() async {
    // 1. Valider tous les champs
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs avant d\'enregistrer'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final db = DatabaseService();

      // 2. Construire la Map des données (types corrects)
      final dataMap = {
        'dateActivite': _dateController.text,
        'nbMenagesEnquetes': int.tryParse(_nbMenagesEnquetesController.text),
        'nbTotalLatrines': int.tryParse(_nbTotalLatrinesController.text),
        'nbLatrinesAmeliorees': int.tryParse(_nbLatrinesAmelioreesCtr.text),
        'nbLatrinesNonAmeliorees': int.tryParse(_nbLatrinesNonAmelioreesCtr.text),
        'nbLatrinesAmelioreesHygienique': int.tryParse(_nbLatrinesAmelioreesHygieniqueCtr.text),
        'nbLatrinesAmelioreesPartagees': int.tryParse(_nbLatrinesAmelioreesParageesCtr.text),
        'nbLatrinesNonFonctionnelles': int.tryParse(_nbLatrinesNonFonctionellesCtr.text),
        'nbLatrinesEndommagees': int.tryParse(_nbLatrinesEndommaggersCtr.text),
        'nbMenagesUtilisantVoisin': int.tryParse(_nbMenagesUtilisantVoisinCtr.text),
        'nbMenagesDAL': int.tryParse(_nbMenagesDALCtr.text),
        'nbNouvellesLatrinesConstruites': int.tryParse(_nbNouvellesLatrinesCtr.text),
        'nbLatrinesAutofinancees': int.tryParse(_nbLatrinesAutofinanceesCtr.text),
        'nbLatrinesAideExterieure': int.tryParse(_nbLatrinesAideExterieureCtr.text),
        'nbLatrinesFinanceesCommunaute': int.tryParse(_nbLatrinesFinanceesCommunauteCtr.text),
        'montantInvestiMenages': double.tryParse(
            _montantInvestiMenagesCtr.text.replaceAll(',', '.')),
        'nbLatrinesDLM': int.tryParse(_nbLatrinesDLMCtr.text),
        'nbDlmEauSavon': int.tryParse(_nbDlmEauSavonCtr.text),
        'nbDlmEauSansSavon': int.tryParse(_nbDlmEauSansSavonCtr.text),
        'nbMenagesSansDLM': int.tryParse(_nbMenagesSansDLMCtr.text),
      };

      // 3. Sauvegarder (ou mettre à jour) dans SQLite
      await db.upsertQuestionnaire(
        type: 'dernier_suivi_localite',
        localiteId: _localiteId,
        dataMap: dataMap,
        userId: _userId,
      );

      if (mounted) {
        setState(() => _isSaved = true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Données enregistrées avec succès'),
              ],
            ),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'enregistrement : $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Construction de l'interface ───────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Dernier Suivi Localité'),
        actions: [
          if (_isSaved)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: AppStatusBadge(
                label: 'Enregistré',
                color: AppTheme.successColor,
                icon: Icons.check_circle_outline,
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── En-tête (localisation) ────────────────────────────────────
            FormHeaderWidget(onDataLoaded: _onLocalisationLoaded),

            // ── Date de l'activité ────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                  title: 'Date de l\'activité',
                  icon: Icons.event_note,
                ),
                AppDateField(
                  label: 'Date de l\'activité',
                  controller: _dateController,
                  required: true,
                  lastDate: DateTime.now(),
                ),
              ],
            ),

            // ── Données générales ─────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                  title: 'Données générales',
                  icon: Icons.bar_chart,
                ),
                AppNumberField(
                  label: 'Nombre de ménages enquêtés',
                  controller: _nbMenagesEnquetesController,
                  required: true,
                ),
                AppNumberField(
                  label: 'Nombre total de latrines',
                  controller: _nbTotalLatrinesController,
                  required: true,
                ),
                AppNumberField(
                  label: 'Nombre de latrines améliorées',
                  controller: _nbLatrinesAmelioreesCtr,
                ),
                AppNumberField(
                  label: 'Nombre de latrines non améliorées',
                  controller: _nbLatrinesNonAmelioreesCtr,
                ),
              ],
            ),

            // ── Gestion ───────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(title: 'Gestion', icon: Icons.settings),
                AppNumberField(
                  label: 'Latrines améliorées de manière hygiénique',
                  controller: _nbLatrinesAmelioreesHygieniqueCtr,
                ),
                AppNumberField(
                  label: 'Latrines améliorées de manière équitable et partagée',
                  controller: _nbLatrinesAmelioreesParageesCtr,
                ),
                AppNumberField(
                  label: 'Latrines non fonctionnelles',
                  controller: _nbLatrinesNonFonctionellesCtr,
                ),
              ],
            ),

            // ── État ──────────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'État des latrines', icon: Icons.home_repair_service),
                AppNumberField(
                  label: 'Latrines endommagées (hivernage)',
                  controller: _nbLatrinesEndommaggersCtr,
                ),
                AppNumberField(
                  label: 'Ménages utilisant latrines des voisins',
                  controller: _nbMenagesUtilisantVoisinCtr,
                ),
                AppNumberField(
                  label: 'Ménages pratiquant la défécation à l\'air libre',
                  controller: _nbMenagesDALCtr,
                ),
              ],
            ),

            // ── Réalisations ──────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Réalisations', icon: Icons.construction),
                AppNumberField(
                  label: 'Nouvelles latrines construites',
                  controller: _nbNouvellesLatrinesCtr,
                ),
                AppNumberField(
                  label: 'Latrines autofinancées',
                  controller: _nbLatrinesAutofinanceesCtr,
                ),
                AppNumberField(
                  label: 'Latrines avec aide extérieure',
                  controller: _nbLatrinesAideExterieureCtr,
                ),
                AppNumberField(
                  label: 'Latrines financées par la communauté',
                  controller: _nbLatrinesFinanceesCommunauteCtr,
                ),
              ],
            ),

            // ── Investissement ────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                    title: 'Investissement', icon: Icons.attach_money),
                AppDecimalField(
                  label: 'Montant investi par les ménages (MRU)',
                  controller: _montantInvestiMenagesCtr,
                  prefixIcon: Icons.payments_outlined,
                ),
              ],
            ),

            // ── DLM ───────────────────────────────────────────────────────
            AppFormCard(
              children: [
                AppSectionTitle(
                  title: 'Dispositif de lavage des mains (DLM)',
                  icon: Icons.wash,
                ),
                AppNumberField(
                  label: 'Latrines avec DLM',
                  controller: _nbLatrinesDLMCtr,
                ),
                AppNumberField(
                  label: 'Dispositifs avec eau + savon',
                  controller: _nbDlmEauSavonCtr,
                ),
                AppNumberField(
                  label: 'Dispositifs avec eau sans savon',
                  controller: _nbDlmEauSansSavonCtr,
                ),
                AppNumberField(
                  label: 'Ménages sans DLM',
                  controller: _nbMenagesSansDLMCtr,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Bouton enregistrer ────────────────────────────────────────
            AppSubmitButton(
              label: 'Enregistrer',
              isLoading: _isLoading,
              onPressed: _save,
              icon: Icons.save_rounded,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
