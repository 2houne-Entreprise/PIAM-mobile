import 'package:equatable/equatable.dart';
import 'package:piam/data/models/data_models.dart';

/// Événements pour les formulaires
abstract class FormulaireEvent extends Equatable {
  const FormulaireEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les formulaires
class LoadFormulairesEvent extends FormulaireEvent {
  final String localiteId;

  const LoadFormulairesEvent({required this.localiteId});

  @override
  List<Object?> get props => [localiteId];
}

/// Charger un formulaire spécifique
class LoadFormulaireDetailEvent extends FormulaireEvent {
  final String formulaireId;

  const LoadFormulaireDetailEvent({required this.formulaireId});

  @override
  List<Object?> get props => [formulaireId];
}

/// Créer un nouveau formulaire
class CreateFormulaireEvent extends FormulaireEvent {
  final String type;
  final String localiteId;

  const CreateFormulaireEvent({required this.type, required this.localiteId});

  @override
  List<Object?> get props => [type, localiteId];
}

/// Sauvegarder un formulaire (en brouillon)
class SaveFormulaireEvent extends FormulaireEvent {
  final Formulaire formulaire;

  const SaveFormulaireEvent({required this.formulaire});

  @override
  List<Object?> get props => [formulaire];
}

/// Valider un formulaire
class ValidateFormulaireEvent extends FormulaireEvent {
  final String formulaireId;

  const ValidateFormulaireEvent({required this.formulaireId});

  @override
  List<Object?> get props => [formulaireId];
}

/// Envoyer un formulaire
class SubmitFormulaireEvent extends FormulaireEvent {
  final String formulaireId;

  const SubmitFormulaireEvent({required this.formulaireId});

  @override
  List<Object?> get props => [formulaireId];
}

/// Supprimer un formulaire
class DeleteFormulaireEvent extends FormulaireEvent {
  final String formulaireId;

  const DeleteFormulaireEvent({required this.formulaireId});

  @override
  List<Object?> get props => [formulaireId];
}

/// Ajouter une photo
class AddPhotoEvent extends FormulaireEvent {
  final String formulaireId;
  final Photo photo;

  const AddPhotoEvent({required this.formulaireId, required this.photo});

  @override
  List<Object?> get props => [formulaireId, photo];
}

/// Mettre à jour une réponse de champ
class UpdateReponseEvent extends FormulaireEvent {
  final String formulaireId;
  final String champId;
  final dynamic value;

  const UpdateReponseEvent({
    required this.formulaireId,
    required this.champId,
    required this.value,
  });

  @override
  List<Object?> get props => [formulaireId, champId, value];
}
