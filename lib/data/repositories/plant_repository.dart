// repositories/plant_repository.dart
import 'dart:io';
import 'package:http/http.dart' as http;

class PlantRepository {
  final String baseUrl = 'http://10.0.2.2:5000/api';

  Future<Map<String, dynamic>> identifyPlant(File imageFile) async {
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$baseUrl/identify'));
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      var response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return {'success': true, 'data': responseData};
      } else {
        return {'success': false, 'error': 'Failed to identify plant'};
      }
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
