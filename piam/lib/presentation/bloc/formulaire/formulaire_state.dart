import 'package:equatable/equatable.dart';
import 'package:piam/data/models/data_models.dart';

/// États pour les formulaires
abstract class FormulaireState extends Equatable {
  const FormulaireState();

  @override
  List<Object?> get props => [];
}

/// État initial
class FormulaireInitial extends FormulaireState {
  const FormulaireInitial();
}

/// État de chargement
class FormulaireLoading extends FormulaireState {
  const FormulaireLoading();
}

/// Formulaires chargés
class FormulairesLoaded extends FormulaireState {
  final List<Formulaire> formulaires;
  final int totalCount;
  final int completedCount;
  final int sentCount;

  const FormulairesLoaded({
    required this.formulaires,
    required this.totalCount,
    required this.completedCount,
    required this.sentCount,
  });

  @override
  List<Object?> get props => [
    formulaires,
    totalCount,
    completedCount,
    sentCount,
  ];
}

/// Détail d'un formulaire chargé
class FormulaireDetailLoaded extends FormulaireState {
  final Formulaire formulaire;

  const FormulaireDetailLoaded({required this.formulaire});

  @override
  List<Object?> get props => [formulaire];
}

/// Formulaire créé
class FormulaireCreated extends FormulaireState {
  final Formulaire formulaire;

  const FormulaireCreated({required this.formulaire});

  @override
  List<Object?> get props => [formulaire];
}

/// Formulaire sauvegardé
class FormulaireSaved extends FormulaireState {
  final Formulaire formulaire;

  const FormulaireSaved({required this.formulaire});

  @override
  List<Object?> get props => [formulaire];
}

/// Formulaire validé
class FormulaireValidated extends FormulaireState {
  final Formulaire formulaire;

  const FormulaireValidated({required this.formulaire});

  @override
  List<Object?> get props => [formulaire];
}

/// Formulaire envoyé
class FormulaireSubmitted extends FormulaireState {
  final Formulaire formulaire;

  const FormulaireSubmitted({required this.formulaire});

  @override
  List<Object?> get props => [formulaire];
}

/// Photo ajoutée
class PhotoAdded extends FormulaireState {
  final String formulaireId;
  final Photo photo;

  const PhotoAdded({required this.formulaireId, required this.photo});

  @override
  List<Object?> get props => [formulaireId, photo];
}

/// Réponse mise à jour
class ReponseUpdated extends FormulaireState {
  final String formulaireId;
  final String champId;
  final dynamic value;

  const ReponseUpdated({
    required this.formulaireId,
    required this.champId,
    required this.value,
  });

  @override
  List<Object?> get props => [formulaireId, champId, value];
}

/// Erreur
class FormulaireError extends FormulaireState {
  final String message;
  final String? code;

  const FormulaireError(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}
