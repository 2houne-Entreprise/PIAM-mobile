import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'parametrage_screen.dart';

class LoginScreen extends StatefulWidget {
  static const String routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late String _dateTime;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    _dateTime =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) return;

    await _secureStorage.write(
      key: 'username',
      value: _usernameController.text.trim(),
    );
    await _secureStorage.write(
      key: 'password',
      value: _passwordController.text,
    );

    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(ParametrageScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion PIAM')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            const Text(
              'Suivi des latrines publiques',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Projet MHA Mauritanie - Version 1.0',
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              'Date et heure: $_dateTime',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '* Nom d’utilisateur',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      hintText: 'Saisir le nom d’utilisateur',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Le nom d’utilisateur est requis.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '* Mot de passe',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.lock),
                      hintText: 'Saisir le mot de passe',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Le mot de passe est requis.';
                      }
                      if (value.length < 4) {
                        return 'Le mot de passe doit contenir au moins 4 caractères.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _login,
                    child: const Text(
                      'SE CONNECTER',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      _usernameController.clear();
                      _passwordController.clear();
                    },
                    child: const Text(
                      'Réinitialiser',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
