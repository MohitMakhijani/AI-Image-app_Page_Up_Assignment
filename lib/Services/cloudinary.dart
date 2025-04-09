import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CloudinaryUploader {
  final String cloudName = 'dnyyjglof';
  final String apiKey = '924149635432459';
  final String apiSecret =
      'fsWrEW7VquuMQMS3rSxnqdqAwKk'; // ⚠️ Unsafe to hardcode this in production

  Future<String?> uploadImage(File imageFile, {String? apiUrl}) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Generate the signature string
    final signatureString = 'timestamp=$timestamp$apiSecret';

    // Create SHA1 hash of the signature
    final signature = sha1.convert(utf8.encode(signatureString)).toString();

    final uri = Uri.parse(
        apiUrl ?? "https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['signature'] = signature
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      return data['secure_url'];
    } else {
      print("Upload failed: ${response.statusCode}");
      return null;
    }
  }

  Future<String?> uploadImageWithGenBackground(
      File imageFile, String prompt) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");

    final transformation =
        'w_1000,c_scale,q_auto,f_auto,fl_lossy,e_gen_background_replace:prompt_{$prompt}';

    // ✅ Include transformation in the string to sign
    final signatureString =
        'timestamp=$timestamp&transformation=$transformation$apiSecret';
    final signature = sha1.convert(utf8.encode(signatureString)).toString();

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['transformation'] = transformation
      ..fields['signature'] = signature
      ..fields['resource_type'] = 'auto'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      return data['secure_url'];
    } else {
      final responseBody = await response.stream.bytesToString();
      print("Upload failed: ${response.statusCode}, response: $responseBody");
      return null;
    }
  }

  Future<String?> uploadImageWithRemBackground(
      File imageFile, String prompt) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final uri =
        Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
    final transformation =
        'w_1000,c_scale,q_auto,f_auto,fl_lossy,e_background_removal/';

    // ✅ Include transformation in the string to sign
    final signatureString =
        'timestamp=$timestamp&transformation=$transformation$apiSecret';
    final signature = sha1.convert(utf8.encode(signatureString)).toString();

    final request = http.MultipartRequest('POST', uri)
      ..fields['api_key'] = apiKey
      ..fields['timestamp'] = timestamp.toString()
      ..fields['transformation'] = transformation
      ..fields['signature'] = signature
      ..fields['resource_type'] = 'auto'
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        filename: path.basename(imageFile.path),
      ));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = json.decode(responseBody);
      return data['secure_url'];
    } else {
      final responseBody = await response.stream.bytesToString();
      print("Upload failed: ${response.statusCode}, response: $responseBody");
      return null;
    }
  }

  Future<String?> removeBgAndSaveImage(File imageFile, String prompt) async {
    final apiKey = 'QApY6pqMX5qD6j7QVnNvujUz';
    final url = Uri.parse("https://api.remove.bg/v1.0/removebg");

    var request = http.MultipartRequest("POST", url)
      ..headers['X-Api-Key'] = apiKey
      ..files.add(await http.MultipartFile.fromPath(
        'image_file',
        imageFile.path,
        filename: basename(imageFile.path),
      ));

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final bytes = await response.stream.toBytes();

        // ✅ Save to local file
        final directory = await getTemporaryDirectory();
        final filePath =
            '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_no_bg.png';
        final savedFile = File(filePath);

        // ✅ Actually write the image bytes
        await savedFile.writeAsBytes(bytes);

        // ✅ Now upload the saved image to Cloudinary
        return uploadImage(savedFile);
      } else {
        final errorMsg = await response.stream.bytesToString();
        print("Failed to remove background: ${response.statusCode}, $errorMsg");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

  Future<String?> uploadImageWithBlurBackground(
      File imageFile, String promp) async {
    final uri = Uri.parse("http://192.168.1.42:5000/bokeh_effect");
    final request = http.MultipartRequest('POST', uri);
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final bytes = await response.stream.toBytes();

      // Save file temporarily
      final directory = await getTemporaryDirectory();
      final filePath = join(directory.path, "bokeh_result.jpg");
      final file = File(filePath);
      await file.writeAsBytes(bytes);
      return uploadImage(file);
    } else {
      print("Error: ${response.statusCode}");
      return '';
    }
  }

  Future<File?> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    return pickedFile != null ? File(pickedFile.path) : null;
  }
}
