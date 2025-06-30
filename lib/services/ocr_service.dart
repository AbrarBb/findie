import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class OCRService {
  // Extract text from image using Google ML Kit
  Future<String?> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final textRecognizer = TextRecognizer();
      
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      await textRecognizer.close();
      
      return recognizedText.text.isNotEmpty ? recognizedText.text : null;
    } catch (e) {
      print('Error extracting text from image: $e');
      return null;
    }
  }

  // Extract text from multiple images
  Future<List<String>> extractTextFromImages(List<File> imageFiles) async {
    final extractedTexts = <String>[];

    for (final file in imageFiles) {
      final text = await extractTextFromImage(file);
      if (text != null && text.isNotEmpty) {
        extractedTexts.add(text);
      }
    }

    return extractedTexts;
  }

  // Generate tags from extracted text
  List<String> generateTagsFromText(String text) {
    if (text.isEmpty) return [];

    // Common keywords to look for
    final keywords = [
      'iPhone', 'Samsung', 'phone', 'mobile',
      'wallet', 'purse', 'bag', 'backpack',
      'keys', 'keychain', 'car key',
      'laptop', 'MacBook', 'computer',
      'headphones', 'earbuds', 'AirPods',
      'watch', 'smartwatch', 'Apple Watch',
      'glasses', 'sunglasses',
      'book', 'notebook', 'textbook',
      'card', 'ID', 'license', 'passport',
      'jewelry', 'ring', 'necklace', 'bracelet',
      'umbrella', 'jacket', 'coat',
      'water bottle', 'bottle',
      'charger', 'cable', 'adapter',
    ];

    final foundTags = <String>[];
    final lowerText = text.toLowerCase();

    for (final keyword in keywords) {
      if (lowerText.contains(keyword.toLowerCase())) {
        foundTags.add(keyword);
      }
    }

    // Extract colors
    final colors = [
      'red', 'blue', 'green', 'yellow', 'black', 'white',
      'gray', 'grey', 'brown', 'pink', 'purple', 'orange',
      'silver', 'gold', 'navy', 'maroon'
    ];

    for (final color in colors) {
      if (lowerText.contains(color)) {
        foundTags.add(color);
      }
    }

    // Extract brands
    final brands = [
      'Apple', 'Samsung', 'Google', 'Microsoft', 'Sony',
      'Nike', 'Adidas', 'Puma', 'Gucci', 'Louis Vuitton',
      'Coach', 'Prada', 'Rolex', 'Casio', 'Timex'
    ];

    for (final brand in brands) {
      if (text.contains(brand)) {
        foundTags.add(brand);
      }
    }

    return foundTags.take(10).toList(); // Limit to 10 tags
  }
}

// Provider for OCRService
final ocrServiceProvider = Provider<OCRService>((ref) => OCRService());