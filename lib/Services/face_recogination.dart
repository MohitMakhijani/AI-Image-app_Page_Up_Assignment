import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class EmbeddingApi {
  final String baseUrl = 'http://192.168.1.42:5000/get_embedding';

  Future<List<double>?> uploadImageFile(File imageFile) async {
    try {
      final mimeType = lookupMimeType(imageFile.path);
      if (mimeType == null) {
        print("Unable to determine MIME type for file: ${imageFile.path}");
        return null;
      }

      final mimeTypeData = mimeType.split('/');
      final request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.containsKey('embedding')) {
          final embedding = data['embedding'];
          if (embedding is List) {
            return embedding.map<double>((e) => e.toDouble()).toList();
          }
        }
        print("No embedding found in response.");
        return null;
      } else {
        print("Server Error: ${response.statusCode}, Body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Exception while uploading image: $e");
      return null;
    }
  }
}
