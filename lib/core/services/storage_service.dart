import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class StorageService {
  // Crea un preset di upload "unsigned" dalla dashboard Cloudinary
  static const String cloudName = 'dskf6wstr';
  static const String uploadPreset = 'menu_plaza';

  // Caricamento immagine su Cloudinary
  // Restituisce {'url': secure_url, 'path': public_id}
  Future<Map<String, String>> uploadMenuImage(
    Uint8List bytes,
    String fileName, {
    Function(double)? onProgress,
  }) async {
    // Valida configurazione: lancia solo se non configurata
    if (cloudName.isEmpty ||
        uploadPreset.isEmpty ||
        cloudName == 'YOUR_CLOUD_NAME' ||
        uploadPreset == 'YOUR_UNSIGNED_UPLOAD_PRESET') {
      throw Exception(
        'Configura Cloudinary: imposta cloudName e uploadPreset in StorageService',
      );
    }

    // Notare: il package http non espone facilmente progress events.
    // Aggiorniamo progress a 0 prima e a 1 alla fine per mostrare stato al UI.
    onProgress?.call(0.0);

    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final url = (data['secure_url'] ?? data['url']) as String?;
      final publicId = data['public_id'] as String?;
      if (url == null || publicId == null) {
        throw Exception('Risposta Cloudinary non valida');
      }
      onProgress?.call(1.0);
      return {'url': url, 'path': publicId};
    } else {
      throw Exception(
        'Upload Cloudinary fallito: ${response.statusCode} ${response.body}',
      );
    }
  }

  // La cancellazione su Cloudinary richiede credenziali sicure (API Secret) lato server.
  // Da client non è consigliato. Qui facciamo no-op.
  Future<void> deleteImageByPath(String path) async {
    // Opzione: segnare per la pulizia server-side o lasciare l'immagine su Cloudinary.
    // In alternativa, potremmo supportare solo la sostituzione (nuovo upload) senza delete.
    return;
  }
}
