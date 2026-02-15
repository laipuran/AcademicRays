import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SettingsService {
  final _storage = const FlutterSecureStorage();

  static const _geminiApiKey = 'gemini_api_key';
  static const _mathpixAppId = 'mathpix_app_id';
  static const _mathpixAppKey = 'mathpix_app_key';

  Future<void> setGeminiApiKey(String key) async {
    await _storage.write(key: _geminiApiKey, value: key);
  }

  Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: _geminiApiKey);
  }

  Future<void> setMathpixKeys(String appId, String appKey) async {
    await _storage.write(key: _mathpixAppId, value: appId);
    await _storage.write(key: _mathpixAppKey, value: appKey);
  }

  Future<Map<String, String?>> getMathpixKeys() async {
    return {
      'appId': await _storage.read(key: _mathpixAppId),
      'appKey': await _storage.read(key: _mathpixAppKey),
    };
  }
}
