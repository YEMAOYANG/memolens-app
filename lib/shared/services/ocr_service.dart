import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
class OcrService {
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.chinese);
  static Future<String> recognize(String imagePath) async {
    final input = InputImage.fromFilePath(imagePath);
    final result = await _recognizer.processImage(input);
    return result.text;
  }
  static void dispose() => _recognizer.close();
}
