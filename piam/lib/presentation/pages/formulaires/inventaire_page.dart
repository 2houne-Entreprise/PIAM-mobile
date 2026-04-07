import 'package:flutter/material.dart';

class InventairePage extends StatefulWidget {
  final String formulaireId;
  const InventairePage({Key? key, required this.formulaireId})
    : super(key: key);

  @override
  State<InventairePage> createState() => _InventairePageState();
}

class _InventairePageState extends State<InventairePage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Informations
  String? _nomInfrastructure;
  String? _typeInfrastructure;

  // Eau
  bool? _accesEau;
  String? _sourceEau;
  double? _distanceSource;

  // Assainissement
  bool? _accesLatrines;
  int? _nbBlocs;
  int? _nbCabines;
  int? _nbCabinesFonctionnelles;
  String? _photoPath;
  bool? _besoinConstruction;
  int? _nbBlocsConstruire;
  int? _nbCabinesConstruire;

  // DLM
  bool? _presenceDLM;
  bool? _dlmEauSavon;
  bool? _dlmFonctionnel;

  // Photo (à adapter selon votre logique de prise de photo)
  Future<void> _pickPhoto() async {
    setState(() {
      _photoPath = 'photo_path.jpg'; // Placeholder
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Inventaire envoyé'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventaire')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'Informations',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Nom de l’infrastructure',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _nomInfrastructure = v,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Type d’infrastructure',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _typeInfrastructure = v,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Eau',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Accès à l’eau : Oui'),
                          value: true,
                          groupValue: _accesEau,
                          onChanged: (v) => setState(() => _accesEau = v),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Non'),
                          value: false,
                          groupValue: _accesEau,
                          onChanged: (v) => setState(() => _accesEau = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Source d’eau',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => _sourceEau = v,
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Distance à la source (m)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => _distanceSource = double.tryParse(
                      v.replaceAll(',', '.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Assainissement',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Accès à des latrines : Oui'),
                          value: true,
                          groupValue: _accesLatrines,
                          onChanged: (v) => setState(() => _accesLatrines = v),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<bool>(
                          title: const Text('Non'),
                          value: false,
                          groupValue: _accesLatrines,
                          onChanged: (v) => setState(() => _accesLatrines = v),
                        ),
                      ),
                    ],
                  ),
                  if (_accesLatrines == true) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre de blocs',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _nbBlocs = int.tryParse(v),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre de cabines',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _nbCabines = int.tryParse(v),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre de cabines fonctionnelles',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) =>
                          _nbCabinesFonctionnelles = int.tryParse(v),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Prendre une photo'),
                            onPressed: _pickPhoto,
                          ),
                        ),
                        if (_photoPath != null)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ],
                  if (_accesLatrines == false) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: const Text('Besoin de construction'),
                            value: _besoinConstruction ?? false,
                            onChanged: (v) =>
                                setState(() => _besoinConstruction = v),
                          ),
                        ),
                      ],
                    ),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre de blocs à construire',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _nbBlocsConstruire = int.tryParse(v),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre de cabines à construire',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => _nbCabinesConstruire = int.tryParse(v),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'DLM',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  CheckboxListTile(
                    title: const Text('Présence DLM'),
                    value: _presenceDLM ?? false,
                    onChanged: (v) => setState(() => _presenceDLM = v),
                  ),
                  CheckboxListTile(
                    title: const Text('DLM avec eau + savon'),
                    value: _dlmEauSavon ?? false,
                    onChanged: (v) => setState(() => _dlmEauSavon = v),
                  ),
                  CheckboxListTile(
                    title: const Text('DLM fonctionnel'),
                    value: _dlmFonctionnel ?? false,
                    onChanged: (v) => setState(() => _dlmFonctionnel = v),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.send),
                    label: const Text('Envoyer'),
                    onPressed: _submit,
                  ),
                ],
              ),
            ),
    );
  }
}
