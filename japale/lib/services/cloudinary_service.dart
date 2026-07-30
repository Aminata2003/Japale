import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service centralisé pour uploader des images sur Cloudinary.
class CloudinaryService {
  static const String cloudName = 'k8fvcsw5'; // à remplacer si besoin
  static const String uploadPreset = 'japale_unsigned';

  /// Upload une image locale sur Cloudinary et renvoie son URL publique.
  /// Renvoie `null` en cas d'échec (au lieu de lever une exception).
  static Future<String?> uploadImage(
    File image, {
    required String folder,
  }) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = folder
        ..files.add(await http.MultipartFile.fromPath('file', image.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode != 200) {
        print('Erreur Cloudinary (${response.statusCode}) : $responseBody');
        return null;
      }

      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return data['secure_url'] as String?;
    } catch (e) {
      print('Erreur upload Cloudinary : $e');
      return null;
    }
  }
}
