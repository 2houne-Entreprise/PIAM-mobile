import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class AdminDropdowns extends StatefulWidget {
  final Database db;
  final void Function({
    required int wilayaId,
    required int moughataaId,
    required int communeId,
    required int? localiteId,
  })
  onChanged;
  const AdminDropdowns({Key? key, required this.db, required this.onChanged})
    : super(key: key);

  @override
  State<AdminDropdowns> createState() => _AdminDropdownsState();
}

class _AdminDropdownsState extends State<AdminDropdowns> {
  int? selectedWilaya;
  int? selectedMoughataa;
  int? selectedCommune;
  int? selectedLocalite;

  List<Map<String, dynamic>> wilayas = [];
  List<Map<String, dynamic>> moughataas = [];
  List<Map<String, dynamic>> communes = [];
  List<Map<String, dynamic>> localites = [];

  @override
  void initState() {
    super.initState();
    _loadWilayas();
  }

  Future<void> _loadWilayas() async {
    final result = await widget.db.query('wilayas');
    setState(() {
      wilayas = result;
      selectedWilaya = null;
      selectedMoughataa = null;
      selectedCommune = null;
      selectedLocalite = null;
      moughataas = [];
      communes = [];
      localites = [];
    });
  }

  Future<void> _loadMoughataas(int wilayaId) async {
    final result = await widget.db.query(
      'moughatas',
      where: 'wilaya_id = ?',
      whereArgs: [wilayaId],
    );
    setState(() {
      moughataas = result;
      selectedMoughataa = null;
      selectedCommune = null;
      selectedLocalite = null;
      communes = [];
      localites = [];
    });
  }

  Future<void> _loadCommunes(int moughataaId) async {
    final result = await widget.db.query(
      'communes_ref',
      where: 'moughata_id = ?',
      whereArgs: [moughataaId],
    );
    setState(() {
      communes = result;
      selectedCommune = null;
      selectedLocalite = null;
      localites = [];
    });
  }

  Future<void> _loadLocalites(int communeId) async {
    final result = await widget.db.query(
      'localites_ref',
      where: 'commune_id = ?',
      whereArgs: [communeId],
    );
    setState(() {
      localites = result;
      selectedLocalite = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(labelText: 'Wilaya'),
          value: selectedWilaya,
          items: wilayas
              .map(
                (w) => DropdownMenuItem(
                  value: w['id'] as int,
                  child: Text(w['intitule'] ?? ''),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              setState(() => selectedWilaya = val);
              _loadMoughataas(val);
            }
          },
        ),
        if (moughataas.isNotEmpty)
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Moughataa'),
            value: selectedMoughataa,
            items: moughataas
                .map(
                  (m) => DropdownMenuItem(
                    value: m['id'] as int,
                    child: Text(m['intitule'] ?? ''),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedMoughataa = val);
                _loadCommunes(val);
              }
            },
          ),
        if (communes.isNotEmpty)
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Commune'),
            value: selectedCommune,
            items: communes
                .map(
                  (c) => DropdownMenuItem(
                    value: c['id'] as int,
                    child: Text(c['intitule'] ?? ''),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedCommune = val);
                _loadLocalites(val);
              }
            },
          ),
        if (localites.isNotEmpty)
          DropdownButtonFormField<int>(
            decoration: const InputDecoration(labelText: 'Localité'),
            value: selectedLocalite,
            items: localites
                .map(
                  (l) => DropdownMenuItem(
                    value: l['id'] as int,
                    child: Text(l['intitule'] ?? ''),
                  ),
                )
                .toList(),
            onChanged: (val) {
              setState(() => selectedLocalite = val);
              widget.onChanged(
                wilayaId: selectedWilaya!,
                moughataaId: selectedMoughataa!,
                communeId: selectedCommune!,
                localiteId: val,
              );
            },
          ),
      ],
    );
  }
}
