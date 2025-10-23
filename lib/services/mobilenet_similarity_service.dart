// import 'dart:io';
// import 'dart:math' as math;
// import 'package:image/image.dart' as img;
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:http/http.dart' as http;

// class MobileNetSimilarityService {
//   final PetService _petService = PetService();
//   final Map<String, ImageFeatures> _featureCache = {};
//   bool _isModelLoaded = false;

//   Future<void> initializeModel() async {
//     try {
//       print('Initializing image similarity service...');
//       _isModelLoaded = true;
//       print('Image similarity service initialized successfully');
//     } catch (e) {
//       print('Error initializing service: $e');
//       _isModelLoaded = false;
//       rethrow;
//     }
//   }

//   Future<List<SimilarPetResult>> searchSimilarPets(File imageFile) async {
//     try {
//       if (!_isModelLoaded) {
//         await initializeModel();
//       }

//       print('Extracting features from uploaded image...');
      
//       final uploadedFeatures = await _extractImageFeatures(imageFile);
      
//       print('Getting pets from database...');
      
//       final allPets = await _petService.getAllPetsOnce();
      
//       print('Found ${allPets.length} pets in database');
      
//       List<SimilarPetResult> results = [];
      
//       for (int i = 0; i < allPets.length; i++) {
//         final pet = allPets[i];
        
//         if (pet.imageUrl.isNotEmpty) {
//           try {
//             print('Processing pet ${i + 1}/${allPets.length}: ${pet.name}');
            
//             final similarity = await _calculatePetSimilarity(uploadedFeatures, pet);
            
//             if (similarity.similarityScore > 0.1) {
//               results.add(similarity);
//             }
//           } catch (e) {
//             print('Error processing pet ${pet.id}: $e');
//           }
//         }
//       }
      
//       print('Found ${results.length} similar pets');
      
//       results.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));
      
//       return results.take(20).toList();
      
//     } catch (e) {
//       print('Error in similarity search: $e');
//       rethrow;
//     }
//   }

//   Future<ImageFeatures> _extractImageFeatures(File imageFile) async {
//     try {
//       final imageBytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(imageBytes);
      
//       if (image == null) {
//         throw Exception('Could not decode image');
//       }

//       // Extract various features
//       final colorHistogram = _extractColorHistogram(image);
//       final dominantColors = _extractDominantColors(image);
//       final textureFeatures = _extractTextureFeatures(image);
//       final shapeFeatures = _extractShapeFeatures(image);
      
//       return ImageFeatures(
//         colorHistogram: colorHistogram,
//         dominantColors: dominantColors,
//         textureFeatures: textureFeatures,
//         shapeFeatures: shapeFeatures,
//       );
      
//     } catch (e) {
//       print('Error extracting image features: $e');
//       rethrow;
//     }
//   }

//   List<double> _extractColorHistogram(img.Image image) {
//     // Resize for faster processing
//     final resized = img.copyResize(image, width: 64, height: 64);
    
//     // Create color histogram (16 bins per channel)
//     List<int> rHist = List.filled(16, 0);
//     List<int> gHist = List.filled(16, 0);
//     List<int> bHist = List.filled(16, 0);
    
//     int totalPixels = resized.width * resized.height;
    
//     for (int y = 0; y < resized.height; y++) {
//       for (int x = 0; x < resized.width; x++) {
//         final pixel = resized.getPixel(x, y);
        
//         // Extract RGB values
//         final r = pixel.r.toInt();
//         final g = pixel.g.toInt();
//         final b = pixel.b.toInt();
        
//         rHist[(r * 16) ~/ 256]++;
//         gHist[(g * 16) ~/ 256]++;
//         bHist[(b * 16) ~/ 256]++;
//       }
//     }
    
//     // Normalize and combine histograms
//     List<double> features = [];
//     features.addAll(rHist.map((count) => count / totalPixels));
//     features.addAll(gHist.map((count) => count / totalPixels));
//     features.addAll(bHist.map((count) => count / totalPixels));
    
//     return features;
//   }

//   List<ColorInfo> _extractDominantColors(img.Image image) {
//     final resized = img.copyResize(image, width: 32, height: 32);
//     Map<String, ColorCount> colorCounts = {};
    
//     for (int y = 0; y < resized.height; y++) {
//       for (int x = 0; x < resized.width; x++) {
//         final pixel = resized.getPixel(x, y);
        
//         final r = pixel.r.toInt();
//         final g = pixel.g.toInt();
//         final b = pixel.b.toInt();
        
//         // Group similar colors
//         final rGroup = (r ~/ 32) * 32;
//         final gGroup = (g ~/ 32) * 32;
//         final bGroup = (b ~/ 32) * 32;
        
//         final key = '$rGroup-$gGroup-$bGroup';
//         if (colorCounts.containsKey(key)) {
//           colorCounts[key]!.count++;
//         } else {
//           colorCounts[key] = ColorCount(1, rGroup, gGroup, bGroup);
//         }
//       }
//     }
    
//     // Get top 5 colors
//     final sortedColors = colorCounts.values.toList()
//       ..sort((a, b) => b.count.compareTo(a.count));
    
//     return sortedColors.take(5).map((cc) => ColorInfo(
//       red: cc.r.toDouble(),
//       green: cc.g.toDouble(),
//       blue: cc.b.toDouble(),
//       score: cc.count / (resized.width * resized.height),
//     )).toList();
//   }

//   List<double> _extractTextureFeatures(img.Image image) {
//     // Convert to grayscale for texture analysis
//     final gray = img.grayscale(image);
//     final resized = img.copyResize(gray, width: 32, height: 32);
    
//     List<double> features = [];
    
//     // Calculate texture features
//     double variance = 0.0;
//     double mean = 0.0;
//     int totalPixels = resized.width * resized.height;
    
//     // Calculate mean
//     for (int y = 0; y < resized.height; y++) {
//       for (int x = 0; x < resized.width; x++) {
//         final pixel = resized.getPixel(x, y);
//         mean += pixel.r; // In grayscale, r=g=b
//       }
//     }
//     mean /= totalPixels;
    
//     // Calculate variance
//     for (int y = 0; y < resized.height; y++) {
//       for (int x = 0; x < resized.width; x++) {
//         final pixel = resized.getPixel(x, y);
//         variance += math.pow(pixel.r - mean, 2);
//       }
//     }
//     variance /= totalPixels;
    
//     features.add(mean / 255.0); // Normalized mean
//     features.add(math.sqrt(variance) / 255.0); // Normalized standard deviation
    
//     return features;
//   }

//   List<double> _extractShapeFeatures(img.Image image) {
//     // Simple edge detection for shape features
//     final gray = img.grayscale(image);
//     final resized = img.copyResize(gray, width: 32, height: 32);
    
//     List<double> features = [];
//     int edgeCount = 0;
    
//     // Simple edge detection
//     for (int y = 1; y < resized.height - 1; y++) {
//       for (int x = 1; x < resized.width - 1; x++) {
//         final center = resized.getPixel(x, y).r;
//         final right = resized.getPixel(x + 1, y).r;
//         final bottom = resized.getPixel(x, y + 1).r;
        
//         final gradientX = (center - right).abs();
//         final gradientY = (center - bottom).abs();
        
//         if (gradientX > 30 || gradientY > 30) {
//           edgeCount++;
//         }
//       }
//     }
    
//     features.add(edgeCount / (resized.width * resized.height)); // Edge density
    
//     return features;
//   }

//   Future<SimilarPetResult> _calculatePetSimilarity(
//     ImageFeatures uploadedFeatures, 
//     PetModel pet
//   ) async {
//     try {
//       ImageFeatures petFeatures;
      
//       if (_featureCache.containsKey(pet.id)) {
//         petFeatures = _featureCache[pet.id]!;
//       } else {
//         petFeatures = await _extractPetImageFeatures(pet);
//         if (!petFeatures.isEmpty) {
//           _featureCache[pet.id!] = petFeatures;
//         }
//       }

//       if (petFeatures.isEmpty) {
//         return SimilarPetResult(
//           pet: pet,
//           similarityScore: 0.0,
//           matchedFeatures: [],
//         );
//       }

//       // Calculate different similarity metrics
//       final colorSim = _calculateHistogramSimilarity(
//         uploadedFeatures.colorHistogram, 
//         petFeatures.colorHistogram
//       );
      
//       final dominantColorSim = _calculateDominantColorSimilarity(
//         uploadedFeatures.dominantColors, 
//         petFeatures.dominantColors
//       );
      
//       final textureSim = _calculateVectorSimilarity(
//         uploadedFeatures.textureFeatures, 
//         petFeatures.textureFeatures
//       );
      
//       final shapeSim = _calculateVectorSimilarity(
//         uploadedFeatures.shapeFeatures, 
//         petFeatures.shapeFeatures
//       );
      
//       // Weighted overall score
//       final overallScore = (colorSim * 0.4) + 
//                           (dominantColorSim * 0.3) + 
//                           (textureSim * 0.2) +
//                           (shapeSim * 0.1);

//       final matchedFeatures = _getMatchedFeatures(pet, overallScore);

//       return SimilarPetResult(
//         pet: pet,
//         similarityScore: overallScore,
//         matchedFeatures: matchedFeatures,
//       );

//     } catch (e) {
//       print('Error calculating similarity for pet ${pet.id}: $e');
//       return SimilarPetResult(
//         pet: pet,
//         similarityScore: 0.0,
//         matchedFeatures: [],
//       );
//     }
//   }

//   Future<ImageFeatures> _extractPetImageFeatures(PetModel pet) async {
//     try {
//       print('Downloading image for pet: ${pet.name}');
      
//       final response = await http.get(Uri.parse(pet.imageUrl));
      
//       if (response.statusCode != 200) {
//         throw Exception('Failed to download image: ${response.statusCode}');
//       }
      
//       final tempDir = Directory.systemTemp;
//       final tempFile = File('${tempDir.path}/temp_${pet.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
//       await tempFile.writeAsBytes(response.bodyBytes);
      
//       final features = await _extractImageFeatures(tempFile);
      
//       try {
//         await tempFile.delete();
//       } catch (e) {
//         print('Could not delete temp file: $e');
//       }
      
//       return features;
      
//     } catch (e) {
//       print('Error extracting features for pet ${pet.id}: $e');
//       return ImageFeatures.empty();
//     }
//   }

//   double _calculateHistogramSimilarity(List<double> hist1, List<double> hist2) {
//     if (hist1.length != hist2.length || hist1.isEmpty) {
//       return 0.0;
//     }

//     // Use histogram intersection
//     double intersection = 0.0;
//     for (int i = 0; i < hist1.length; i++) {
//       intersection += math.min(hist1[i], hist2[i]);
//     }
    
//     return intersection;
//   }

//   double _calculateDominantColorSimilarity(List<ColorInfo> colors1, List<ColorInfo> colors2) {
//     if (colors1.isEmpty || colors2.isEmpty) {
//       return 0.0;
//     }

//     double totalSimilarity = 0.0;
//     int comparisons = 0;

//     for (var color1 in colors1.take(3)) {
//       for (var color2 in colors2.take(3)) {
//         final distance = _calculateColorDistance(color1, color2);
//         final similarity = 1.0 - (distance / 441.67); // Max distance in RGB space
//         totalSimilarity += similarity.clamp(0.0, 1.0);
//         comparisons++;
//       }
//     }

//     return comparisons > 0 ? totalSimilarity / comparisons : 0.0;
//   }

//   double _calculateColorDistance(ColorInfo color1, ColorInfo color2) {
//     final dr = color1.red - color2.red;
//     final dg = color1.green - color2.green;
//     final db = color1.blue - color2.blue;
//     return math.sqrt(dr * dr + dg * dg + db * db);
//   }

//   double _calculateVectorSimilarity(List<double> vec1, List<double> vec2) {
//     if (vec1.length != vec2.length || vec1.isEmpty) {
//       return 0.0;
//     }

//     double dotProduct = 0.0;
//     double norm1 = 0.0;
//     double norm2 = 0.0;

//     for (int i = 0; i < vec1.length; i++) {
//       dotProduct += vec1[i] * vec2[i];
//       norm1 += vec1[i] * vec1[i];
//       norm2 += vec2[i] * vec2[i];
//     }

//     if (norm1 == 0.0 || norm2 == 0.0) {
//       return 0.0;
//     }

//         return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
//   }

//   List<String> _getMatchedFeatures(PetModel pet, double similarity) {
//     List<String> features = [];

//     if (similarity > 0.8) {
//       features.add('Very high similarity');
//     } else if (similarity > 0.6) {
//       features.add('High similarity');
//     } else if (similarity > 0.4) {
//       features.add('Moderate similarity');
//     } else if (similarity > 0.2) {
//       features.add('Low similarity');
//     }

//     features.add('Breed: ${pet.breed}');
//     features.add('Color: ${pet.color}');

//     if (pet.status == 'lost') {
//       features.add('Lost pet');
//     } else if (pet.status == 'found') {
//       features.add('Found pet');
//     }

//     return features;
//   }

//   void clearCache() {
//     _featureCache.clear();
//   }

//   void dispose() {
//     _featureCache.clear();
//   }
// }

// // Data models for image features
// class ImageFeatures {
//   final List<double> colorHistogram;
//   final List<ColorInfo> dominantColors;
//   final List<double> textureFeatures;
//   final List<double> shapeFeatures;

//   ImageFeatures({
//     required this.colorHistogram,
//     required this.dominantColors,
//     required this.textureFeatures,
//     required this.shapeFeatures,
//   });

//   bool get isEmpty =>
//       colorHistogram.isEmpty &&
//       dominantColors.isEmpty &&
//       textureFeatures.isEmpty &&
//       shapeFeatures.isEmpty;

//   static ImageFeatures empty() {
//     return ImageFeatures(
//       colorHistogram: [],
//       dominantColors: [],
//       textureFeatures: [],
//       shapeFeatures: [],
//     );
//   }
// }

// class ColorInfo {
//   final double red;
//   final double green;
//   final double blue;
//   final double score;

//   ColorInfo({
//     required this.red,
//     required this.green,
//     required this.blue,
//     required this.score,
//   });
// }

// class ColorCount {
//   int count;
//   final int r;
//   final int g;
//   final int b;

//   ColorCount(this.count, this.r, this.g, this.b);
// }

// class SimilarPetResult {
//   final PetModel pet;
//   final double similarityScore;
//   final List<String> matchedFeatures;

//   SimilarPetResult({
//     required this.pet,
//     required this.similarityScore,
//     required this.matchedFeatures,
//   });
// }



// // import 'dart:io';
// // import 'dart:math' as math;
// // import 'dart:typed_data';
// // import 'package:flutter/services.dart';
// // import 'package:tflite_flutter/tflite_flutter.dart';
// // import 'package:image/image.dart' as img;
// // import 'package:pettrack/models/pet_model.dart';
// // import 'package:pettrack/services/pet_service.dart';
// // import 'package:http/http.dart' as http;

// // class MobileNetSimilarityService {
// //   static const String _modelPath = 'assets/models/1.tflite';

// //   Interpreter? _interpreter;
// //   final PetService _petService = PetService();
// //   bool _isModelLoaded = false;

// //   final Map<String, List<double>> _featureCache = {};

// //   static const int inputSize = 224;
// //   static const int outputSize = 1000;

// //   Future<void> initializeModel() async {
// //     try {
// //       print('Loading MobileNet V2 model...');

// //       _interpreter = await Interpreter.fromAsset(_modelPath);
// //       _isModelLoaded = true;
// //       print('MobileNet V2 model loaded successfully');

// //       await _warmUpModel();
// //     } catch (e) {
// //       print('Error loading MobileNet V2 model: $e');
// //       _isModelLoaded = false;
// //       rethrow;
// //     }
// //   }

// //   Future<void> _warmUpModel() async {
// //     try {
// //       final dummyInput = Float32List(1 * inputSize * inputSize * 3);
// //       final inputTensor = dummyInput.reshape([1, inputSize, inputSize, 3]);
// //       final dummyOutput = Float32List(1 * outputSize);
// //       final outputTensor = dummyOutput.reshape([1, outputSize]);

// //       _interpreter!.run(inputTensor, outputTensor);
// //       print('Model warmed up successfully');
// //     } catch (e) {
// //       print('Error warming up model: $e');
// //     }
// //   }

// //   Future<List<SimilarPetResult>> searchSimilarPets(File imageFile) async {
// //     try {
// //       if (!_isModelLoaded) {
// //         await initializeModel();
// //       }

// //       print('Extracting features from uploaded image...');

// //       final uploadedFeatures = await _extractImageFeatures(imageFile);

// //       if (uploadedFeatures.isEmpty) {
// //         throw Exception('Could not extract features from uploaded image');
// //       }

// //       print('Getting pets from database...');

// //       final allPets = await _petService.getAllPetsOnce();

// //       print('Found ${allPets.length} pets in database');

// //       List<SimilarPetResult> results = [];

// //       for (int i = 0; i < allPets.length; i++) {
// //         final pet = allPets[i];

// //         if (pet.imageUrl.isNotEmpty) {
// //           try {
// //             print('Processing pet ${i + 1}/${allPets.length}: ${pet.name}');

// //             final similarity =
// //                 await _calculatePetSimilarity(uploadedFeatures, pet);

// //             if (similarity.similarityScore > 0.1) {
// //               results.add(similarity);
// //             }
// //           } catch (e) {
// //             print('Error processing pet ${pet.id}: $e');
// //           }
// //         }
// //       }

// //       print('Found ${results.length} similar pets');

// //       results.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));

// //       return results.take(20).toList();
// //     } catch (e) {
// //       print('Error in similarity search: $e');
// //       rethrow;
// //     }
// //   }

// //   Future<List<double>> _extractImageFeatures(File imageFile) async {
// //     try {
// //       final imageBytes = await imageFile.readAsBytes();
// //       final image = img.decodeImage(imageBytes);

// //       if (image == null) {
// //         throw Exception('Could not decode image');
// //       }

// //       final preprocessed = _preprocessImage(image);

// //       final output = Float32List(outputSize);
// //       final outputTensor = output.reshape([1, outputSize]);

// //       _interpreter!.run(preprocessed, outputTensor);

// //       return output.toList();
// //     } catch (e) {
// //       print('Error extracting image features: $e');
// //       rethrow;
// //     }
// //   }

// //   Float32List _preprocessImage(img.Image image) {
// //     // Resize image to 224x224
// //     final resized = img.copyResize(image, width: inputSize, height: inputSize);

// //     final input = Float32List(1 * inputSize * inputSize * 3);
// //     int pixelIndex = 0;

// //     for (int y = 0; y < inputSize; y++) {
// //       for (int x = 0; x < inputSize; x++) {
// //         final pixel = resized.getPixel(x, y);

// //         // Use the correct API for image package v3.3.0
// //         final r = (pixel.r / 127.5) - 1.0;
// //         final g = (pixel.g / 127.5) - 1.0;
// //         final b = (pixel.b / 127.5) - 1.0;

// //         input[pixelIndex++] = r;
// //         input[pixelIndex++] = g;
// //         input[pixelIndex++] = b;
// //       }
// //     }

// //     return input.reshape([1, inputSize, inputSize, 3]);
// //   }

// //   Future<SimilarPetResult> _calculatePetSimilarity(
// //       List<double> uploadedFeatures, PetModel pet) async {
// //     try {
// //       List<double> petFeatures;

// //       if (_featureCache.containsKey(pet.id)) {
// //         petFeatures = _featureCache[pet.id]!;
// //       } else {
// //         petFeatures = await _extractPetImageFeatures(pet);
// //         if (petFeatures.isNotEmpty) {
// //           _featureCache[pet.id!] = petFeatures;
// //         }
// //       }

// //       if (petFeatures.isEmpty) {
// //         return SimilarPetResult(
// //           pet: pet,
// //           similarityScore: 0.0,
// //           matchedFeatures: [],
// //         );
// //       }

// //       final similarity =
// //           _calculateCosineSimilarity(uploadedFeatures, petFeatures);

// //       final matchedFeatures = _getMatchedFeatures(pet, similarity);

// //       return SimilarPetResult(
// //         pet: pet,
// //         similarityScore: similarity,
// //         matchedFeatures: matchedFeatures,
// //       );
// //     } catch (e) {
// //       print('Error calculating similarity for pet ${pet.id}: $e');
// //       return SimilarPetResult(
// //         pet: pet,
// //         similarityScore: 0.0,
// //         matchedFeatures: [],
// //       );
// //     }
// //   }

// //   Future<List<double>> _extractPetImageFeatures(PetModel pet) async {
// //     try {
// //       print('Downloading image for pet: ${pet.name}');

// //       final response = await http.get(Uri.parse(pet.imageUrl));

// //       if (response.statusCode != 200) {
// //         throw Exception('Failed to download image: ${response.statusCode}');
// //       }

// //       final tempDir = Directory.systemTemp;
// //       final tempFile = File(
// //           '${tempDir.path}/temp_${pet.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
// //       await tempFile.writeAsBytes(response.bodyBytes);

// //       final features = await _extractImageFeatures(tempFile);

// //       try {
// //         await tempFile.delete();
// //       } catch (e) {
// //         print('Could not delete temp file: $e');
// //       }

// //       return features;
// //     } catch (e) {
// //       print('Error extracting features for pet ${pet.id}: $e');
// //       return [];
// //     }
// //   }

// //   double _calculateCosineSimilarity(
// //       List<double> features1, List<double> features2) {
// //     if (features1.length != features2.length || features1.isEmpty) {
// //       return 0.0;
// //     }

// //     double dotProduct = 0.0;
// //     double norm1 = 0.0;
// //     double norm2 = 0.0;

// //     for (int i = 0; i < features1.length; i++) {
// //       dotProduct += features1[i] * features2[i];
// //       norm1 += features1[i] * features1[i];
// //       norm2 += features2[i] * features2[i];
// //     }

// //     if (norm1 == 0.0 || norm2 == 0.0) {
// //       return 0.0;
// //     }

// //     final similarity = dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));

// //     return ((similarity + 1.0) / 2.0).clamp(0.0, 1.0);
// //   }

// //   List<String> _getMatchedFeatures(PetModel pet, double similarity) {
// //     List<String> features = [];

// //     if (similarity > 0.8) {
// //       features.add('Very high similarity');
// //     } else if (similarity > 0.6) {
// //       features.add('High similarity');
// //     } else if (similarity > 0.4) {
// //       features.add('Moderate similarity');
// //     } else if (similarity > 0.2) {
// //       features.add('Low similarity');
// //     }

// //     features.add('Breed: ${pet.breed}');
// //     features.add('Color: ${pet.color}');

// //     if (pet.status == 'lost') {
// //       features.add('Lost pet');
// //     } else if (pet.status == 'found') {
// //       features.add('Found pet');
// //     }

// //     return features;
// //   }

// //   void clearCache() {
// //     _featureCache.clear();
// //   }

// //   void dispose() {
// //     _interpreter?.close();
// //     _featureCache.clear();
// //   }
// // }

// // class SimilarPetResult {
// //   final PetModel pet;
// //   final double similarityScore;
// //   final List<String> matchedFeatures;

// //   SimilarPetResult({
// //     required this.pet,
// //     required this.similarityScore,
// //     required this.matchedFeatures,
// //   });
// // }
import 'dart:io';
import 'dart:math' as math;
import 'package:image/image.dart' as img;
import 'package:pettrack/models/pet_model.dart';
import 'package:pettrack/models/lost_found_pet_model.dart';
import 'package:pettrack/services/pet_service.dart';
import 'package:pettrack/services/lost_found_pet_service.dart';
import 'package:http/http.dart' as http;

class MobileNetSimilarityService {
  final PetService _petService = PetService();
  final LostFoundPetService _lostFoundPetService = LostFoundPetService();
  final Map<String, ImageFeatures> _featureCache = {};
  bool _isModelLoaded = false;

  Future<void> initializeModel() async {
    try {
      print('Initializing image similarity service...');
      _isModelLoaded = true;
      print('Image similarity service initialized successfully');
    } catch (e) {
      print('Error initializing service: $e');
      _isModelLoaded = false;
      rethrow;
    }
  }

  Future<List<SimilarPetResult>> searchSimilarPets(File imageFile) async {
    try {
      if (!_isModelLoaded) {
        await initializeModel();
      }

      print('Extracting features from uploaded image...');
      
      final uploadedFeatures = await _extractImageFeatures(imageFile);
      
      print('Getting pets from database...');
      
      // Get pets from both collections
      final ownedPets = await _petService.getAllPetsOnce();
      final lostFoundPets = await _lostFoundPetService.getAllLostFoundPetsOnce();
      
      print('Found ${ownedPets.length} owned pets and ${lostFoundPets.length} lost/found pets in database');
      
      List<SimilarPetResult> results = [];
      
      // Process owned pets
      for (int i = 0; i < ownedPets.length; i++) {
        final pet = ownedPets[i];
        
        if (pet.imageUrl.isNotEmpty) {
          try {
            print('Processing owned pet ${i + 1}/${ownedPets.length}: ${pet.name}');
            
            final similarity = await _calculateOwnedPetSimilarity(uploadedFeatures, pet);
            
            if (similarity.similarityScore > 0.1) {
              results.add(similarity);
            }
          } catch (e) {
            print('Error processing owned pet ${pet.id}: $e');
          }
        }
      }
      
      // Process lost/found pets
      for (int i = 0; i < lostFoundPets.length; i++) {
        final pet = lostFoundPets[i];
        
        if (pet.imageUrl.isNotEmpty) {
          try {
            print('Processing lost/found pet ${i + 1}/${lostFoundPets.length}: ${pet.name}');
            
            final similarity = await _calculateLostFoundPetSimilarity(uploadedFeatures, pet);
            
            if (similarity.similarityScore > 0.1) {
              results.add(similarity);
            }
          } catch (e) {
            print('Error processing lost/found pet ${pet.id}: $e');
          }
        }
      }
      
      print('Found ${results.length} similar pets');
      
      results.sort((a, b) => b.similarityScore.compareTo(a.similarityScore));
      
      return results.take(20).toList();
      
    } catch (e) {
      print('Error in similarity search: $e');
      rethrow;
    }
  }

  Future<ImageFeatures> _extractImageFeatures(File imageFile) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final image = img.decodeImage(imageBytes);
      
      if (image == null) {
        throw Exception('Could not decode image');
      }

      // Extract various features
      final colorHistogram = _extractColorHistogram(image);
      final dominantColors = _extractDominantColors(image);
      final textureFeatures = _extractTextureFeatures(image);
      final shapeFeatures = _extractShapeFeatures(image);
      
      return ImageFeatures(
        colorHistogram: colorHistogram,
        dominantColors: dominantColors,
        textureFeatures: textureFeatures,
        shapeFeatures: shapeFeatures,
      );
      
    } catch (e) {
      print('Error extracting image features: $e');
      rethrow;
    }
  }

  List<double> _extractColorHistogram(img.Image image) {
    // Resize for faster processing
    final resized = img.copyResize(image, width: 64, height: 64);
    
    // Create color histogram (16 bins per channel)
    List<int> rHist = List.filled(16, 0);
    List<int> gHist = List.filled(16, 0);
    List<int> bHist = List.filled(16, 0);
    
    int totalPixels = resized.width * resized.height;
    
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        
        // Extract RGB values
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        rHist[(r * 16) ~/ 256]++;
        gHist[(g * 16) ~/ 256]++;
        bHist[(b * 16) ~/ 256]++;
      }
    }
    
    // Normalize and combine histograms
    List<double> features = [];
    features.addAll(rHist.map((count) => count / totalPixels));
    features.addAll(gHist.map((count) => count / totalPixels));
    features.addAll(bHist.map((count) => count / totalPixels));
    
    return features;
  }

  List<ColorInfo> _extractDominantColors(img.Image image) {
    final resized = img.copyResize(image, width: 32, height: 32);
    Map<String, ColorCount> colorCounts = {};
    
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        
        final r = pixel.r.toInt();
        final g = pixel.g.toInt();
        final b = pixel.b.toInt();
        
        // Group similar colors
        final rGroup = (r ~/ 32) * 32;
        final gGroup = (g ~/ 32) * 32;
        final bGroup = (b ~/ 32) * 32;
        
        final key = '$rGroup-$gGroup-$bGroup';
        if (colorCounts.containsKey(key)) {
          colorCounts[key]!.count++;
        } else {
          colorCounts[key] = ColorCount(1, rGroup, gGroup, bGroup);
        }
      }
    }
    
    // Get top 5 colors
    final sortedColors = colorCounts.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    
    return sortedColors.take(5).map((cc) => ColorInfo(
      red: cc.r.toDouble(),
      green: cc.g.toDouble(),
      blue: cc.b.toDouble(),
      score: cc.count / (resized.width * resized.height),
    )).toList();
  }

  List<double> _extractTextureFeatures(img.Image image) {
    // Convert to grayscale for texture analysis
    final gray = img.grayscale(image);
    final resized = img.copyResize(gray, width: 32, height: 32);
    
    List<double> features = [];
    
    // Calculate texture features
    double variance = 0.0;
    double mean = 0.0;
    int totalPixels = resized.width * resized.height;
    
    // Calculate mean
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        mean += pixel.r; // In grayscale, r=g=b
      }
    }
    mean /= totalPixels;
    
    // Calculate variance
    for (int y = 0; y < resized.height; y++) {
      for (int x = 0; x < resized.width; x++) {
        final pixel = resized.getPixel(x, y);
        variance += math.pow(pixel.r - mean, 2);
      }
    }
    variance /= totalPixels;
    
    features.add(mean / 255.0); // Normalized mean
    features.add(math.sqrt(variance) / 255.0); // Normalized standard deviation
    
    return features;
  }

  List<double> _extractShapeFeatures(img.Image image) {
    // Simple edge detection for shape features
    final gray = img.grayscale(image);
    final resized = img.copyResize(gray, width: 32, height: 32);
    
    List<double> features = [];
    int edgeCount = 0;
    
    // Simple edge detection
    for (int y = 1; y < resized.height - 1; y++) {
      for (int x = 1; x < resized.width - 1; x++) {
        final center = resized.getPixel(x, y).r;
        final right = resized.getPixel(x + 1, y).r;
        final bottom = resized.getPixel(x, y + 1).r;
        
        final gradientX = (center - right).abs();
        final gradientY = (center - bottom).abs();
        
        if (gradientX > 30 || gradientY > 30) {
          edgeCount++;
        }
      }
    }
    
    features.add(edgeCount / (resized.width * resized.height)); // Edge density
    
    return features;
  }

  // NEW: Separate method for owned pets
  Future<SimilarPetResult> _calculateOwnedPetSimilarity(
    ImageFeatures uploadedFeatures, 
    PetModel pet
  ) async {
    try {
      ImageFeatures petFeatures;
      
      final cacheKey = 'owned_${pet.id}';
      if (_featureCache.containsKey(cacheKey)) {
        petFeatures = _featureCache[cacheKey]!;
      } else {
        petFeatures = await _extractOwnedPetImageFeatures(pet);
        if (!petFeatures.isEmpty) {
          _featureCache[cacheKey] = petFeatures;
        }
      }

      if (petFeatures.isEmpty) {
        return SimilarPetResult(
          pet: pet,
          lostFoundPet: null,
          similarityScore: 0.0,
          matchedFeatures: [],
          petType: 'owned',
        );
      }

      final overallScore = _calculateSimilarityScore(uploadedFeatures, petFeatures);
      final matchedFeatures = _getOwnedPetMatchedFeatures(pet, overallScore);

      return SimilarPetResult(
        pet: pet,
        lostFoundPet: null,
        similarityScore: overallScore,
        matchedFeatures: matchedFeatures,
        petType: 'owned',
      );

    } catch (e) {
      print('Error calculating similarity for owned pet ${pet.id}: $e');
      return SimilarPetResult(
        pet: pet,
        lostFoundPet: null,
        similarityScore: 0.0,
        matchedFeatures: [],
        petType: 'owned',
      );
    }
  }

  // NEW: Separate method for lost/found pets
  Future<SimilarPetResult> _calculateLostFoundPetSimilarity(
    ImageFeatures uploadedFeatures, 
    LostFoundPetModel pet
  ) async {
    try {
      ImageFeatures petFeatures;
      
      final cacheKey = 'lostfound_${pet.id}';
      if (_featureCache.containsKey(cacheKey)) {
        petFeatures = _featureCache[cacheKey]!;
      } else {
        petFeatures = await _extractLostFoundPetImageFeatures(pet);
        if (!petFeatures.isEmpty) {
          _featureCache[cacheKey] = petFeatures;
        }
      }

      if (petFeatures.isEmpty) {
        return SimilarPetResult(
          pet: null,
          lostFoundPet: pet,
          similarityScore: 0.0,
          matchedFeatures: [],
          petType: pet.status,
        );
      }

      final overallScore = _calculateSimilarityScore(uploadedFeatures, petFeatures);
      final matchedFeatures = _getLostFoundPetMatchedFeatures(pet, overallScore);

      return SimilarPetResult(
        pet: null,
        lostFoundPet: pet,
        similarityScore: overallScore,
        matchedFeatures: matchedFeatures,
        petType: pet.status,
      );

    } catch (e) {
      print('Error calculating similarity for lost/found pet ${pet.id}: $e');
      return SimilarPetResult(
        pet: null,
        lostFoundPet: pet,
        similarityScore: 0.0,
        matchedFeatures: [],
        petType: pet.status,
      );
    }
  }

  double _calculateSimilarityScore(ImageFeatures features1, ImageFeatures features2) {
    // Calculate different similarity metrics
    final colorSim = _calculateHistogramSimilarity(
      features1.colorHistogram, 
      features2.colorHistogram
    );
    
    final dominantColorSim = _calculateDominantColorSimilarity(
      features1.dominantColors, 
      features2.dominantColors
    );
    
    final textureSim = _calculateVectorSimilarity(
      features1.textureFeatures, 
      features2.textureFeatures
    );
    
    final shapeSim = _calculateVectorSimilarity(
      features1.shapeFeatures, 
      features2.shapeFeatures
    );
    
    // Weighted overall score
    return (colorSim * 0.4) + 
           (dominantColorSim * 0.3) + 
           (textureSim * 0.2) +
           (shapeSim * 0.1);
  }

  Future<ImageFeatures> _extractOwnedPetImageFeatures(PetModel pet) async {
    try {
      print('Downloading image for owned pet: ${pet.name}');
      
      final response = await http.get(Uri.parse(pet.imageUrl));
      
      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }
      
      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_owned_${pet.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);
      
      final features = await _extractImageFeatures(tempFile);
      
            try {
        await tempFile.delete();
      } catch (e) {
        print('Could not delete temp file: $e');
      }

      return features;
    } catch (e) {
      print('Error extracting features for owned pet ${pet.id}: $e');
      return ImageFeatures.empty();
    }
  }

  Future<ImageFeatures> _extractLostFoundPetImageFeatures(
      LostFoundPetModel pet) async {
    try {
      print('Downloading image for lost/found pet: ${pet.name}');

      final response = await http.get(Uri.parse(pet.imageUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download image: ${response.statusCode}');
      }

      final tempDir = Directory.systemTemp;
      final tempFile = File(
          '${tempDir.path}/temp_lostfound_${pet.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(response.bodyBytes);

      final features = await _extractImageFeatures(tempFile);

      try {
        await tempFile.delete();
      } catch (e) {
        print('Could not delete temp file: $e');
      }

      return features;
    } catch (e) {
      print('Error extracting features for lost/found pet ${pet.id}: $e');
      return ImageFeatures.empty();
    }
  }

  double _calculateHistogramSimilarity(List<double> hist1, List<double> hist2) {
    if (hist1.length != hist2.length || hist1.isEmpty) {
      return 0.0;
    }

    // Use histogram intersection
    double intersection = 0.0;
    for (int i = 0; i < hist1.length; i++) {
      intersection += math.min(hist1[i], hist2[i]);
    }

    return intersection;
  }

  double _calculateDominantColorSimilarity(
      List<ColorInfo> colors1, List<ColorInfo> colors2) {
    if (colors1.isEmpty || colors2.isEmpty) {
      return 0.0;
    }

    double totalSimilarity = 0.0;
    int comparisons = 0;

    for (var color1 in colors1.take(3)) {
      for (var color2 in colors2.take(3)) {
        final distance = _calculateColorDistance(color1, color2);
        final similarity =
            1.0 - (distance / 441.67); // Max distance in RGB space
        totalSimilarity += similarity.clamp(0.0, 1.0);
        comparisons++;
      }
    }

    return comparisons > 0 ? totalSimilarity / comparisons : 0.0;
  }

  double _calculateColorDistance(ColorInfo color1, ColorInfo color2) {
    final dr = color1.red - color2.red;
    final dg = color1.green - color2.green;
    final db = color1.blue - color2.blue;
    return math.sqrt(dr * dr + dg * dg + db * db);
  }

  double _calculateVectorSimilarity(List<double> vec1, List<double> vec2) {
    if (vec1.length != vec2.length || vec1.isEmpty) {
      return 0.0;
    }

    double dotProduct = 0.0;
    double norm1 = 0.0;
    double norm2 = 0.0;

    for (int i = 0; i < vec1.length; i++) {
      dotProduct += vec1[i] * vec2[i];
      norm1 += vec1[i] * vec1[i];
      norm2 += vec2[i] * vec2[i];
    }

    if (norm1 == 0.0 || norm2 == 0.0) {
      return 0.0;
    }

    return dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));
  }

  List<String> _getOwnedPetMatchedFeatures(PetModel pet, double similarity) {
    List<String> features = [];

    if (similarity > 0.8) {
      features.add('Very high similarity');
    } else if (similarity > 0.6) {
      features.add('High similarity');
    } else if (similarity > 0.4) {
      features.add('Moderate similarity');
    } else if (similarity > 0.2) {
      features.add('Low similarity');
    }

    features.add('Breed: ${pet.breed}');
    features.add('Color: ${pet.color}');

    if (pet.age.isNotEmpty) {
      features.add('Age: ${pet.age}');
    }

    if (pet.weight.isNotEmpty) {
      features.add('Weight: ${pet.weight}');
    }

    if (pet.isLost) {
      features.add('Currently lost');
    } else {
      features.add('Owned pet');
    }

    return features;
  }

  List<String> _getLostFoundPetMatchedFeatures(
      LostFoundPetModel pet, double similarity) {
    List<String> features = [];

    if (similarity > 0.8) {
      features.add('Very high similarity');
    } else if (similarity > 0.6) {
      features.add('High similarity');
    } else if (similarity > 0.4) {
      features.add('Moderate similarity');
    } else if (similarity > 0.2) {
      features.add('Low similarity');
    }

    features.add('Breed: ${pet.breed}');
    features.add('Color: ${pet.color}');

    if (pet.petType != null) {
      features.add('Type: ${pet.petType}');
    }

    if (pet.size != null) {
      features.add('Size: ${pet.size}');
    }

    if (pet.status == 'lost') {
      features.add('Lost pet');
    } else if (pet.status == 'found') {
      features.add('Found pet');
    }

    return features;
  }

  void clearCache() {
    _featureCache.clear();
  }

  void dispose() {
    _featureCache.clear();
  }
}

// Updated data models for image features
class ImageFeatures {
  final List<double> colorHistogram;
  final List<ColorInfo> dominantColors;
  final List<double> textureFeatures;
  final List<double> shapeFeatures;

  ImageFeatures({
    required this.colorHistogram,
    required this.dominantColors,
    required this.textureFeatures,
    required this.shapeFeatures,
  });

  bool get isEmpty =>
      colorHistogram.isEmpty &&
      dominantColors.isEmpty &&
      textureFeatures.isEmpty &&
      shapeFeatures.isEmpty;

  static ImageFeatures empty() {
    return ImageFeatures(
      colorHistogram: [],
      dominantColors: [],
      textureFeatures: [],
      shapeFeatures: [],
    );
  }
}

class ColorInfo {
  final double red;
  final double green;
  final double blue;
  final double score;

  ColorInfo({
    required this.red,
    required this.green,
    required this.blue,
    required this.score,
  });
}

class ColorCount {
  int count;
  final int r;
  final int g;
  final int b;

  ColorCount(this.count, this.r, this.g, this.b);
}

// Updated SimilarPetResult to handle both types
class SimilarPetResult {
  final PetModel? pet; // For owned pets
  final LostFoundPetModel? lostFoundPet; // For lost/found pets
  final double similarityScore;
  final List<String> matchedFeatures;
  final String petType; // 'owned', 'lost', or 'found'

  SimilarPetResult({
    this.pet,
    this.lostFoundPet,
    required this.similarityScore,
    required this.matchedFeatures,
    required this.petType,
  });

  // Helper getters for common properties
  String get name => pet?.name ?? lostFoundPet?.name ?? '';
  String get breed => pet?.breed ?? lostFoundPet?.breed ?? '';
  String get color => pet?.color ?? lostFoundPet?.color ?? '';
  String get imageUrl => pet?.imageUrl ?? lostFoundPet?.imageUrl ?? '';
  String get id => pet?.id ?? lostFoundPet?.id ?? '';

  // Check if this is an owned pet
  bool get isOwnedPet => pet != null;

  // Check if this is a lost/found pet
  bool get isLostFoundPet => lostFoundPet != null;
}
