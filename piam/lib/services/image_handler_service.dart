import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service professionnel pour la gestion des photos.
/// Gère la capture, la compression et le stockage local permanent.
class ImageHandlerService {
  final ImagePicker _picker = ImagePicker();

  /// Prend une photo avec l'appareil photo et la stocke durablement.
  /// Retourne le chemin local du fichier sauvegardé.
  Future<String?> takePhoto({bool fromGallery = false}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
        maxWidth: 1200, // Compression raisonnable pour le terrain
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile == null) return null;

      if (kIsWeb) {
        // Sur le Web, on garde le chemin fourni par le browser (blob)
        // Note: Sur le Web, la persistence locale est limitée, la sync doit être immédiate.
        return pickedFile.path;
      } else {
        // Sur Mobile, on déplace le fichier du dossier temporaire vers le dossier permanent
        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String photosDir = path.join(appDocDir.path, 'questionnaires_photos');
        
        // Créer le dossier s'il n'existe pas
        final Directory dir = Directory(photosDir);
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        // Créer un nom de fichier unique
        final String fileName = 'IMG_${DateTime.now().millisecondsSinceEpoch}${path.extension(pickedFile.path)}';
        final String permanentPath = path.join(photosDir, fileName);

        // Copier le fichier
        final File localFile = await File(pickedFile.path).copy(permanentPath);
        
        debugPrint('[ImageHandler] Photo sauvegardée localement : ${localFile.path}');
        return localFile.path;
      }
    } catch (e) {
      debugPrint('[ImageHandler] Erreur lors de la capture : $e');
      return null;
    }
  }

  /// Vérifie si un chemin est un fichier local existant.
  Future<bool> exists(String? localPath) async {
    if (localPath == null || localPath.isEmpty) return false;
    if (kIsWeb) return true; // On suppose que le blob est valide pour la session
    return await File(localPath).exists();
  }
}
