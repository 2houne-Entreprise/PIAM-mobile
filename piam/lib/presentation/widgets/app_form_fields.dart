import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piam/config/app_theme.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TITRE DE SECTION
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Affiche un titre de section avec une barre colorée à gauche.
///
/// Usage :
/// ```dart
/// AppSectionTitle(title: 'Données générales', icon: Icons.bar_chart)
/// ```
class AppSectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final Color? color;

  const AppSectionTitle({
    Key? key,
    required this.title,
    this.icon,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      child: Row(
        children: [
          Container(width: 4, height: 22,
              decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          if (icon != null) ...[
            Icon(icon, size: 18, color: c),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: c,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CARTE DE FORMULAIRE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Carte blanche avec ombre légère pour grouper les champs d'une section.
///
/// Usage :
/// ```dart
/// AppFormCard(
///   children: [AppTextField(...), AppNumberField(...)],
/// )
/// ```
class AppFormCard extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;

  const AppFormCard({Key? key, required this.children, this.padding})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHAMP TEXTE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Champ de texte standardisé avec label, validation et icône optionnelle.
///
/// Usage :
/// ```dart
/// AppTextField(
///   label: 'Nom de l\'entreprise',
///   controller: _nomEntrepriseController,
///   required: true,
/// )
/// ```
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final bool readOnly;
  final int maxLines;
  final IconData? prefixIcon;
  final String? hint;
  final TextInputType keyboardType;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const AppTextField({
    Key? key,
    required this.label,
    required this.controller,
    this.required = false,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.onTap,
    this.validator,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        maxLines: maxLines,
        onTap: onTap,
        keyboardType: keyboardType,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
        ),
        validator: validator ??
            (required
                ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
                : null),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHAMP NUMÉRIQUE (entier)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Champ numérique entier. Affiche un clavier numérique et valide le format.
///
/// Usage :
/// ```dart
/// AppNumberField(
///   label: 'Nombre de ménages',
///   controller: _nbMenagesController,
///   required: true,
/// )
/// ```
class AppNumberField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final IconData? prefixIcon;
  final String? hint;
  final void Function(String)? onChanged;

  const AppNumberField({
    Key? key,
    required this.label,
    required this.controller,
    this.required = false,
    this.prefixIcon,
    this.hint,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint ?? '0',
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20)
              : const Icon(Icons.tag, size: 20),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
            : null,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHAMP NUMÉRIQUE DÉCIMAL
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Champ numérique décimal (ex: montant, coordonnées GPS).
class AppDecimalField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final IconData? prefixIcon;
  final void Function(String)? onChanged;

  const AppDecimalField({
    Key? key,
    required this.label,
    required this.controller,
    this.required = false,
    this.prefixIcon,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d+[,.]?\d{0,2}')),
        ],
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: '0.00',
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20)
              : const Icon(Icons.attach_money, size: 20),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
            : null,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHAMP DATE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Sélecteur de date. Affiche un calendrier au tap, et accepte des bornes min/max.
///
/// Usage :
/// ```dart
/// AppDateField(
///   label: 'Date de l\'activité',
///   controller: _dateController,
///   required: true,
///   onDateSelected: (date) => setState(() => _selectedDate = date),
/// )
/// ```
class AppDateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onDateSelected;
  final void Function(String)? onChanged;

  const AppDateField({
    Key? key,
    required this.label,
    required this.controller,
    this.required = false,
    this.firstDate,
    this.lastDate,
    this.onDateSelected,
    this.onChanged,
  }) : super(key: key);

  Future<void> _pick(BuildContext context) async {
    // Parse la date courante si déjà saisie
    DateTime initial = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split('/');
        if (parts.length == 3) {
          initial = DateTime(
            int.parse(parts[2]),
            int.parse(parts[1]),
            int.parse(parts[0]),
          );
        }
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: firstDate ?? DateTime(2020),
      lastDate: lastDate ?? DateTime(2030),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      final formatted =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      controller.text = formatted;
      onDateSelected?.call(picked);
      onChanged?.call(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: () => _pick(context),
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: 'JJ/MM/AAAA',
          prefixIcon: const Icon(Icons.calendar_today, size: 20),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => controller.clear(),
                )
              : null,
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null
            : null,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CHAMP DROPDOWN GÉNÉRIQUE
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Dropdown typé générique avec validation optionnelle.
///
/// Usage :
/// ```dart
/// AppDropdownField<bool>(
///   label: 'Accès à l\'eau ?',
///   value: _accesEau,
///   items: const [
///     DropdownMenuItem(value: true, child: Text('Oui')),
///     DropdownMenuItem(value: false, child: Text('Non')),
///   ],
///   onChanged: (v) => setState(() => _accesEau = v),
///   required: true,
/// )
/// ```
class AppDropdownField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?) onChanged;
  final bool required;
  final bool enabled;
  final IconData? prefixIcon;

  const AppDropdownField({
    Key? key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.required = false,
    this.enabled = true,
    this.prefixIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        items: items,
        onChanged: enabled ? onChanged : null,
        isExpanded: true,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20) : null,
          filled: !enabled,
          fillColor: enabled ? null : Colors.grey[100],
        ),
        validator: required
            ? (v) => v == null ? 'Champ requis' : null
            : null,
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BOUTON D'ENREGISTREMENT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Bouton "Enregistrer" pleine largeur avec indicateur de chargement intégré.
///
/// Usage :
/// ```dart
/// AppSubmitButton(
///   label: 'Enregistrer',
///   isLoading: _isLoading,
///   onPressed: _save,
/// )
/// ```
class AppSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final Color? color;
  final IconData icon;

  const AppSubmitButton({
    Key? key,
    this.label = 'Enregistrer',
    required this.isLoading,
    required this.onPressed,
    this.color,
    this.icon = Icons.save_rounded,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bg = color ?? AppTheme.successColor;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BANNIÈRE D'INFO
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Affiche une bannière d'information colorée en haut de formulaire.
class AppInfoBanner extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const AppInfoBanner({
    Key? key,
    required this.message,
    this.color = AppTheme.primaryColor,
    this.icon = Icons.info_outline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// BADGE DE STATUT
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Un petit badge coloré pour indiquer le statut d'un formulaire.
/// Ex: "Enregistré", "Non rempli", "Synchronisé"
class AppStatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const AppStatusBadge({
    Key? key,
    required this.label,
    required this.color,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
