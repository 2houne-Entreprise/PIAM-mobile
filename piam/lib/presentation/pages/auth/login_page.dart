import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:piam/config/app_strings.dart';
import 'package:piam/config/app_theme.dart';
import 'package:piam/presentation/bloc/auth/auth_bloc.dart';
import 'package:piam/presentation/bloc/auth/auth_event.dart';
import 'package:piam/presentation/bloc/auth/auth_state.dart';
import 'package:piam/utils/validators.dart';

/// Page de connexion
class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        LoginEvent(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          } else if (state is DateTimeError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Espace supérieur
                SizedBox(height: MediaQuery.of(context).size.height * 0.08),

                // Logo/Titre
                Text(
                  AppStrings.loginTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),

                const SizedBox(height: 8),

                // Sous-titre
                Text(
                  AppStrings.loginSubtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),

                const SizedBox(height: 48),

                // Formulaire
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: AppStrings.emailLabel,
                          prefixIcon: const Icon(Icons.email_outlined),
                          hintText: 'exemple@email.com',
                        ),
                        validator: AppValidators.validateEmail,
                      ),

                      const SizedBox(height: 16),

                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: AppStrings.passwordLabel,
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: AppValidators.validatePassword,
                      ),

                      const SizedBox(height: 8),

                      // Mot de passe oublié
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implémenter récupération mot de passe
                          },
                          child: const Text(AppStrings.forgotPassword),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bouton connexion
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isLoading =
                              state is AuthLoading ||
                              state is DateTimeVerifying;

                          return ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text(AppStrings.loginButton),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Informations de date/heure
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.warningColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warningColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '⚠️ Vérifiez que votre date et heure système sont correctes',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
