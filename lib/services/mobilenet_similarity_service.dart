// import 'dart:io';
// import 'dart:math' as math;
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:http/http.dart' as http;

// class MobileNetSimilarityService {
//   static const String _modelPath = 'assets/models/1.tflite';

//   Interpreter? _interpreter;
//   final PetService _petService = PetService();
//   bool _isModelLoaded = false;

//   final Map<String, List<double>> _featureCache = {};

//   static const int inputSize = 224;
//   static const int outputSize = 1000;

//   Future<void> initializeModel() async {
//     try {
//       print('Loading MobileNet V2 model...');

//       _interpreter = await Interpreter.fromAsset(_modelPath);
//       _isModelLoaded = true;
//       print('MobileNet V2 model loaded successfully');

//       await _warmUpModel();
//     } catch (e) {
//       print('Error loading MobileNet V2 model: $e');
//       _isModelLoaded = false;
//       rethrow;
//     }
//   }

//   Future<void> _warmUpModel() async {
//     try {
//       final dummyInput = Float32List(1 * inputSize * inputSize * 3);
//       final inputTensor = dummyInput.reshape([1, inputSize, inputSize, 3]);
//       final dummyOutput = Float32List(1 * outputSize);
//       final outputTensor = dummyOutput.reshape([1, outputSize]);

//       _interpreter!.run(inputTensor, outputTensor);
//       print('Model warmed up successfully');
//     } catch (e) {
//       print('Error warming up model: $e');
//     }
//   }

//   Future<List<SimilarPetResult>> searchSimilarPets(File imageFile) async {
//     try {
//       if (!_isModelLoaded) {
//         await initializeModel();
//       }

//       print('Extracting features from uploaded image...');

//       final uploadedFeatures = await _extractImageFeatures(imageFile);

//       if (uploadedFeatures.isEmpty) {
//         throw Exception('Could not extract features from uploaded image');
//       }

//       print('Getting pets from database...');

//       final allPets = await _petService.getAllPetsOnce();

//       print('Found ${allPets.length} pets in database');

//       List<SimilarPetResult> results = [];

//       for (int i = 0; i < allPets.length; i++) {
//         final pet = allPets[i];

//         if (pet.imageUrl.isNotEmpty) {
//           try {
//             print('Processing pet ${i + 1}/${allPets.length}: ${pet.name}');

//             final similarity =
//                 await _calculatePetSimilarity(uploadedFeatures, pet);

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

//   Future<List<double>> _extractImageFeatures(File imageFile) async {
//     try {
//       final imageBytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(imageBytes);

//       if (image == null) {
//         throw Exception('Could not decode image');
//       }

//       final preprocessed = _preprocessImage(image);

//       final output = Float32List(outputSize);
//       final outputTensor = output.reshape([1, outputSize]);

//       _interpreter!.run(preprocessed, outputTensor);

//       return output.toList();
//     } catch (e) {
//       print('Error extracting image features: $e');
//       rethrow;
//     }
//   }

//   Float32List _preprocessImage(img.Image image) {
//     // Resize image to 224x224
//     final resized = img.copyResize(image, width: inputSize, height: inputSize);

//     final input = Float32List(1 * inputSize * inputSize * 3);
//     int pixelIndex = 0;

//     for (int y = 0; y < inputSize; y++) {
//       for (int x = 0; x < inputSize; x++) {
//         final pixel = resized.getPixel(x, y);

//         // Use the correct API for image package v3.3.0
//         final r = (pixel.r / 127.5) - 1.0;
//         final g = (pixel.g / 127.5) - 1.0;
//         final b = (pixel.b / 127.5) - 1.0;

//         input[pixelIndex++] = r;
//         input[pixelIndex++] = g;
//         input[pixelIndex++] = b;
//       }
//     }

//     return input.reshape([1, inputSize, inputSize, 3]);
//   }

//   Future<SimilarPetResult> _calculatePetSimilarity(
//       List<double> uploadedFeatures, PetModel pet) async {
//     try {
//       List<double> petFeatures;

//       if (_featureCache.containsKey(pet.id)) {
//         petFeatures = _featureCache[pet.id]!;
//       } else {
//         petFeatures = await _extractPetImageFeatures(pet);
//         if (petFeatures.isNotEmpty) {
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

//       final similarity =
//           _calculateCosineSimilarity(uploadedFeatures, petFeatures);

//       final matchedFeatures = _getMatchedFeatures(pet, similarity);

//       return SimilarPetResult(
//         pet: pet,
//         similarityScore: similarity,
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

//   Future<List<double>> _extractPetImageFeatures(PetModel pet) async {
//     try {
//       print('Downloading image for pet: ${pet.name}');

//       final response = await http.get(Uri.parse(pet.imageUrl));

//       if (response.statusCode != 200) {
//         throw Exception('Failed to download image: ${response.statusCode}');
//       }

//       final tempDir = Directory.systemTemp;
//       final tempFile = File(
//           '${tempDir.path}/temp_${pet.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
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
//       return [];
//     }
//   }

//   double _calculateCosineSimilarity(
//       List<double> features1, List<double> features2) {
//     if (features1.length != features2.length || features1.isEmpty) {
//       return 0.0;
//     }

//     double dotProduct = 0.0;
//     double norm1 = 0.0;
//     double norm2 = 0.0;

//     for (int i = 0; i < features1.length; i++) {
//       dotProduct += features1[i] * features2[i];
//       norm1 += features1[i] * features1[i];
//       norm2 += features2[i] * features2[i];
//     }

//     if (norm1 == 0.0 || norm2 == 0.0) {
//       return 0.0;
//     }

//     final similarity = dotProduct / (math.sqrt(norm1) * math.sqrt(norm2));

//     return ((similarity + 1.0) / 2.0).clamp(0.0, 1.0);
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
//     _interpreter?.close();
//     _featureCache.clear();
//   }
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
