import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _apiKey = 'acc_46a1017eca6775c';
  static const String _apiSecret = '2ac63fc0ecef7376808e2d93b3b92cfc';

  static Future<List<Map<String, dynamic>>> detectObjects(String imageUrl) async {
    final uri = Uri.parse(
      'https://api.imagga.com/v2/tags?image_url=${Uri.encodeComponent(imageUrl)}',
    );

    final headers = {
      'Authorization': 'Basic ${base64Encode(utf8.encode('$_apiKey:$_apiSecret'))}',
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tags = data['result']['tags'] as List<dynamic>;

        return tags
            .take(10)
            .map<Map<String, dynamic>>((tag) => {
                  'label': tag['tag']['en'],
                  'confidence': (tag['confidence'] as num).toDouble(),
                })
            .toList();
      } else {
        debugPrint("API error: ${response.body}");
        throw Exception('Tag detection failed');
      }
    } catch (e) {
      print("Exception: $e");
      throw Exception('Tag detection error: $e');
    }
  }
}
