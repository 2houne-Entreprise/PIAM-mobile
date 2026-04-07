import 'package:flutter/material.dart';
import 'package:piam/presentation/widgets/form_header_widget.dart';
import 'package:piam/services/database_service.dart';

class DernierSuiviLocalitePage extends StatefulWidget {
  final String formulaireId;
  const DernierSuiviLocalitePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<DernierSuiviLocalitePage> createState() =>
      _DernierSuiviLocalitePageState();
}

class _DernierSuiviLocalitePageState extends State<DernierSuiviLocalitePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  int? _localiteId;
  dynamic _userId;
  DateTime? _dateActivite;

  // Données générales
  int? _nbMenagesEnquetes;
  int? _nbTotalLatrines;
  int? _nbLatrinesAmeliorees;
  int? _nbLatrinesNonAmeliorees;

  // Gestion
  int? _nbLatrinesAmelioreesHygienique;
  int? _nbLatrinesAmelioreesPartagees;
  int? _nbLatrinesNonFonctionnelles;

  // État
  int? _nbLatrinesEndommagees;
  int? _nbMenagesUtilisantVoisin;
  int? _nbMenagesDAL;

  // Réalisations
  int? _nbNouvellesLatrinesConstruites;
  int? _nbLatrinesAutofinancees;
  int? _nbLatrinesAideExterieure;
  int? _nbLatrinesFinanceesCommunaute;

  // Investissement
  double? _montantInvestiMenages;

  // DLM
  int? _nbLatrinesDLM;
  int? _nbDlmEauSavon;
  int? _nbDlmEauSansSavon;
  int? _nbMenagesSansDLM;

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _dateActivite ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (d != null) setState(() => _dateActivite = d);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final db = DatabaseService();
      final data = {
        'type': 'dernier_suivi_localite',
        'data_json': {
          'dateActivite': _dateActivite?.toIso8601String(),
          'nbMenagesEnquetes': _nbMenagesEnquetes,
          'nbTotalLatrines': _nbTotalLatrines,
          'nbLatrinesAmeliorees': _nbLatrinesAmeliorees,
          'nbLatrinesNonAmeliorees': _nbLatrinesNonAmeliorees,
          'nbLatrinesAmelioreesHygienique': _nbLatrinesAmelioreesHygienique,
          'nbLatrinesAmelioreesPartagees': _nbLatrinesAmelioreesPartagees,
          'nbLatrinesNonFonctionnelles': _nbLatrinesNonFonctionnelles,
          'nbLatrinesEndommagees': _nbLatrinesEndommagees,
          'nbMenagesUtilisantVoisin': _nbMenagesUtilisantVoisin,
          'nbMenagesDAL': _nbMenagesDAL,
          'nbNouvellesLatrinesConstruites': _nbNouvellesLatrinesConstruites,
          'nbLatrinesAutofinancees': _nbLatrinesAutofinancees,
          'nbLatrinesAideExterieure': _nbLatrinesAideExterieure,
          'nbLatrinesFinanceesCommunaute': _nbLatrinesFinanceesCommunaute,
          'montantInvestiMenages': _montantInvestiMenages,
          'nbLatrinesDLM': _nbLatrinesDLM,
          'nbDlmEauSavon': _nbDlmEauSavon,
          'nbDlmEauSansSavon': _nbDlmEauSansSavon,
          'nbMenagesSansDLM': _nbMenagesSansDLM,
        }.toString(),
        'date': DateTime.now().toIso8601String(),
        'user_id': _userId,
        'localite_id': _localiteId,
      };
      await db.insertQuestionnaire(data);
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dernier Suivi Localité enregistré avec succès'),
            backgroundColor: Color.fromARGB(255, 16, 185, 129),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dernier Suivi Localité')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FormHeaderWidget(
                    onDataLoaded: (localiteId, userId) {
                      setState(() {
                        _localiteId = localiteId;
                        _userId = userId;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Date
                  InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date de l’activité',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _dateActivite != null
                            ? '${_dateActivite!.day.toString().padLeft(2, '0')}/'
                                  '${_dateActivite!.month.toString().padLeft(2, '0')}/'
                                  '${_dateActivite!.year}'
                            : 'Sélectionner une date',
                        style: TextStyle(
                          color: _dateActivite != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Données générales
                  const Text(
                    'Données générales',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildNumberField(
                    'Nombre de ménages enquêtés',
                    (v) => _nbMenagesEnquetes = v,
                  ),
                  _buildNumberField(
                    'Nombre total de latrines',
                    (v) => _nbTotalLatrines = v,
                  ),
                  _buildNumberField(
                    'Nombre de latrines améliorées',
                    (v) => _nbLatrinesAmeliorees = v,
                  ),
                  _buildNumberField(
                    'Nombre de latrines non améliorées',
                    (v) => _nbLatrinesNonAmeliorees = v,
                  ),
                  const SizedBox(height: 16),
                  // Gestion
                  const Text(
                    'Gestion',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildNumberField(
                    'Nombre de latrines améliorées de manière hygiénique',
                    (v) => _nbLatrinesAmelioreesHygienique = v,
                  ),
                  _buildNumberField(
                    'Nombre de latrines améliorées de manière équitable et partagée',
                    (v) => _nbLatrinesAmelioreesPartagees = v,
                  ),
                  _buildNumberField(
                    'Nombre de latrines non fonctionnelles',
                    (v) => _nbLatrinesNonFonctionnelles = v,
                  ),
                  const SizedBox(height: 16),
                  // État
                  const Text(
                    'État',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildNumberField(
                    'Nombre de latrines endommagées (hivernage)',
                    (v) => _nbLatrinesEndommagees = v,
                  ),
                  _buildNumberField(
                    'Nombre de ménages utilisant latrines voisin',
                    (v) => _nbMenagesUtilisantVoisin = v,
                  ),
                  _buildNumberField(
                    'Nombre de ménages pratiquant la défécation à l’air libre',
                    (v) => _nbMenagesDAL = v,
                  ),
                  const SizedBox(height: 16),
                  // Réalisations
                  const Text(
                    'Réalisations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildNumberField(
                    'Nombre de nouvelles latrines construites',
                    (v) => _nbNouvellesLatrinesConstruites = v,
                  ),
                  _buildNumberField(
                    'Nombre de latrines autofinancées',
                    (v) => _nbLatrinesAutofinancees = v,
                  ),
                  _buildNumberField(
                    'Nombre de latrines avec aide extérieure',
                    (v) => _nbLatrinesAideExterieure = v,
                  ),
                  _buildNumberField(
                    'Nombre de latrines financées par la communauté',
                    (v) => _nbLatrinesFinanceesCommunaute = v,
                  ),
                  const SizedBox(height: 16),
                  // Investissement
                  const Text(
                    'Investissement',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildDecimalField(
                    'Montant investi par les ménages',
                    (v) => _montantInvestiMenages = v,
                  ),
                  const SizedBox(height: 16),
                  // DLM
                  const Text(
                    'DLM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildNumberField(
                    'Nombre de latrines avec DLM',
                    (v) => _nbLatrinesDLM = v,
                  ),
                  _buildNumberField(
                    'Nombre avec eau + savon',
                    (v) => _nbDlmEauSavon = v,
                  ),
                  _buildNumberField(
                    'Nombre avec eau sans savon',
                    (v) => _nbDlmEauSansSavon = v,
                  ),
                  _buildNumberField(
                    'Nombre de ménages sans DLM A FAIRE',
                    (v) => _nbMenagesSansDLM = v,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.send),
                      label: const Text('Envoyer'),
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildNumberField(String label, ValueChanged<int?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: TextInputType.number,
        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
        onChanged: (v) => onChanged(int.tryParse(v)),
      ),
    );
  }

  Widget _buildDecimalField(String label, ValueChanged<double?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
        onChanged: (v) => onChanged(double.tryParse(v.replaceAll(',', '.'))),
      ),
    );
  }
}
