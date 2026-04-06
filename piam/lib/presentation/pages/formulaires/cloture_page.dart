import 'package:flutter/material.dart';
import 'package:piam/config/app_theme.dart';

/// Formulaire 8 – Clôture du chantier
class CloturePage extends StatefulWidget {
  final String formulaireId;

  const CloturePage({Key? key, required this.formulaireId}) : super(key: key);

  @override
  State<CloturePage> createState() => _CloturePageState();
}

class _CloturePageState extends State<CloturePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  DateTime? _dateReceptionProvisoire;
  DateTime? _dateReceptionDefinitive;
  DateTime? _dateLeveeReserves;

  final _pvReceptionController = TextEditingController();
  final _reservesController = TextEditingController();
  final _remarquesFinalesController = TextEditingController();

  bool _leveeReserves = false;
  bool _signatureEntreprise = false;
  bool _signatureMaitreOuvrage = false;
  bool _signatureControleur = false;
  bool _dossierComplet = false;

  @override
  void dispose() {
    _pvReceptionController.dispose();
    _reservesController.dispose();
    _remarquesFinalesController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime? initial) => showDatePicker(
    context: context,
    initialDate: initial ?? DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2030),
  );

  String _formatDate(DateTime? d) {
    if (d == null) return 'Sélectionner';
    return '${d.day.toString().padLeft(2, '0')}/'
        '${d.month.toString().padLeft(2, '0')}/'
        '${d.year}';
  }

  Future<void> _saveFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clôture enregistrée'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _submitFormulaire() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Clôture soumise pour validation'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clôture du chantier'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildInfoBanner(
                    'Renseignez les informations de clôture et réception du chantier',
                  ),
                  const SizedBox(height: 20),

                  // ── Section A : Réceptions ────────────────────────────────
                  _buildSectionTitle('A. Dates de réception'),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final d = await _pickDate(_dateReceptionProvisoire);
                      if (d != null)
                        setState(() => _dateReceptionProvisoire = d);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Réception provisoire',
                        prefixIcon: Icon(Icons.event),
                      ),
                      child: Text(
                        _formatDate(_dateReceptionProvisoire),
                        style: TextStyle(
                          color: _dateReceptionProvisoire != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  InkWell(
                    onTap: () async {
                      final d = await _pickDate(_dateReceptionDefinitive);
                      if (d != null)
                        setState(() => _dateReceptionDefinitive = d);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Réception définitive',
                        prefixIcon: Icon(Icons.event_available),
                      ),
                      child: Text(
                        _formatDate(_dateReceptionDefinitive),
                        style: TextStyle(
                          color: _dateReceptionDefinitive != null
                              ? Colors.black87
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section B : PV de réception ───────────────────────────
                  _buildSectionTitle('B. Procès-verbal de réception'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _pvReceptionController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'Contenu du procès-verbal de réception...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Section C : Réserves ──────────────────────────────────
                  _buildSectionTitle('C. Réserves émises'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _reservesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Lister les réserves émises lors de la réception...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    title: const Text('Levée des réserves effectuée'),
                    value: _leveeReserves,
                    onChanged: (v) => setState(() => _leveeReserves = v),
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_leveeReserves) ...[
                    InkWell(
                      onTap: () async {
                        final d = await _pickDate(_dateLeveeReserves);
                        if (d != null) setState(() => _dateLeveeReserves = d);
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date de levée des réserves',
                          prefixIcon: Icon(Icons.check_circle_outline),
                        ),
                        child: Text(
                          _formatDate(_dateLeveeReserves),
                          style: TextStyle(
                            color: _dateLeveeReserves != null
                                ? Colors.black87
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 8),

                  // ── Section D : Signatures ────────────────────────────────
                  _buildSectionTitle('D. Signatures des parties'),
                  const SizedBox(height: 8),

                  CheckboxListTile(
                    title: const Text('Entreprise'),
                    value: _signatureEntreprise,
                    onChanged: (v) => setState(() => _signatureEntreprise = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Maître d\'ouvrage'),
                    value: _signatureMaitreOuvrage,
                    onChanged: (v) =>
                        setState(() => _signatureMaitreOuvrage = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  CheckboxListTile(
                    title: const Text('Bureau de contrôle'),
                    value: _signatureControleur,
                    onChanged: (v) => setState(() => _signatureControleur = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 12),

                  SwitchListTile(
                    title: const Text('Dossier de clôture complet'),
                    value: _dossierComplet,
                    onChanged: (v) => setState(() => _dossierComplet = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 20),

                  // ── Remarques finales ─────────────────────────────────────
                  _buildSectionTitle('Remarques finales'),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _remarquesFinalesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText:
                          'Remarques finales sur la clôture du chantier...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Enregistrer'),
                          onPressed: _saveFormulaire,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.send),
                          label: const Text('Soumettre'),
                          onPressed: _submitFormulaire,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoBanner(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.colorBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.colorBlue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.colorBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.colorBlue, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: AppTheme.colorBlue,
      ),
    );
  }
}
