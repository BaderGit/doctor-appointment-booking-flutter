import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class StorageHelper {
  StorageHelper._();

  static StorageHelper storageHelper = StorageHelper._();

  // Cloudinary credentials loaded from environment variables:
  String? cloudName = dotenv.env["CLOUDINARY_CLOUD_NAME"];
  String? apiKey = dotenv.env["CLOUDINARY_API_KEY"];
  String? apiSecret = dotenv.env["CLOUDINARY_API_SECRET"];

  // Uploads an image file to Cloudinary
  Future<String?> uploadImage(File imageFile) async {
    try {
      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'imageHost'
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      // Send the upload request
      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        return jsonResponse['secure_url'] ?? jsonResponse['url'];
      } else {
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
