import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:academic_rays_fe/services/ocr_service.dart';
import 'package:path/path.dart' as path;

void main() {
  test('GlmOcrService extraction test with local asset', () async {
    // 1. Load API KEY using flutter_dotenv to bypass dotenv initialization issues in test
    final envPath = path.join(Directory.current.path, '.env');
    String? apiKey;

    if (File(envPath).existsSync()) {
      final content = File(envPath).readAsStringSync();
      dotenv.loadFromString(envString: content);
      apiKey = dotenv.env['ZHIPU_API_KEY'];
    } else {
      fail('.env file not found.');
    }

    if (apiKey == null || apiKey.isEmpty) {
      fail('ZHIPU_API_KEY not found in .env');
    }

    // 2. Locate the test asset
    // Directory.current should be the root of academic_rays_fe when running flutter test
    final imagePath = path.join(Directory.current.path, 'test_assets', 'test_image4.jpg');
    final imageFile = File(imagePath);

    if (!imageFile.existsSync()) {
      fail('Test asset not found at $imagePath');
    }

    // 3. Initialize the service
    final ocrService = GlmOcrService(apiKey: apiKey);

    print('Starting GlmOcrService test for image: $imagePath');

    try {
      // 4. Perform OCR
      final result = await ocrService.extractText(imageFile);

      // 5. Verify and Output
      expect(result, isNotEmpty);
      print('--- OCR Result Start ---');
      print(result);
      print('--- OCR Result End ---');
    } catch (e) {
      fail('OCR request failed: $e');
    }
  }, timeout: const Timeout(Duration(minutes: 2)));
}
