// // In services/image_search_service.dart
// import 'dart:io';
// import 'dart:math';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/pet_service.dart';
// import 'package:pettrack/services/mobilenet_service.dart';
// import 'package:pettrack/services/notification_service.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// class ImageSearchService {
//   final PetService _petService = PetService();
//   final MobileNetService _mobileNetService = MobileNetService();
//   final SimpleNotificationService _notificationService =
//       SimpleNotificationService();

//   Future<List<PetMatchResult>> searchSimilarPets(
//       File queryImage, String searchType) async {
//     try {
//       // Initialize MobileNet if not already done
//       await _mobileNetService.initialize();

//       // Analyze the query image
//       PetAnalysisResult queryAnalysis =
//           await _mobileNetService.analyzePetImage(queryImage);

//       // Get pets of opposite type (lost pets search in found, and vice versa)
//       String targetStatus = searchType == 'lost' ? 'found' : 'lost';
//       List<PetModel> targetPets = await _petService.getAllPetsOnce();
//       targetPets =
//           targetPets.where((pet) => pet.status == targetStatus).toList();

//       // Find similar pets
//       List<PetMatchResult> matches =
//           await _findMatches(queryAnalysis, targetPets);

//       // Send notifications for high-confidence matches
//       await _sendMatchNotifications(matches, searchType);

//       return matches;
//     } catch (e) {
//       print('Error in image search: $e');
//       return [];
//     }
//   }

//   // Your existing _findMatches method...
//   Future<List<PetMatchResult>> _findMatches(
//       PetAnalysisResult queryAnalysis, List<PetModel> targetPets) async {
//     List<PetMatchResult> matches = [];

//     for (PetModel pet in targetPets) {
//       try {
//         // Download and analyze pet image
//         File petImageFile = await _downloadImage(pet.imageUrl);
//         PetAnalysisResult petAnalysis =
//             await _mobileNetService.analyzePetImage(petImageFile);

//         // Calculate similarity
//         double similarity = _calculateSimilarity(queryAnalysis, petAnalysis);

//         if (similarity > 60.0) {
//           // 60% threshold
//           matches.add(PetMatchResult(
//             pet: pet,
//             similarity: similarity,
//             matchReasons: _getMatchReasons(queryAnalysis, petAnalysis),
//           ));
//         }

//         // Clean up downloaded file
//         await petImageFile.delete();
//       } catch (e) {
//         print('Error processing pet ${pet.id}: $e');
//       }
//     }

//     // Sort by similarity
//     matches.sort((a, b) => b.similarity.compareTo(a.similarity));
//     return matches.take(10).toList();
//   }

//   // Your existing helper methods remain the same...
//   double _calculateSimilarity(
//       PetAnalysisResult query, PetAnalysisResult target) {
//     // Your existing implementation
//     return 75.0; // Placeholder
//   }

//   List<String> _getMatchReasons(
//       PetAnalysisResult query, PetAnalysisResult target) {
//     // Your existing implementation
//     return ['Similar colors', 'Same size'];
//   }

//   Future<File> _downloadImage(String imageUrl) async {
//     try {
//       final response = await http.get(Uri.parse(imageUrl));
//       final directory = await getTemporaryDirectory();
//       final file = File(
//           '${directory.path}/temp_${DateTime.now().millisecondsSinceEpoch}.jpg');
//       await file.writeAsBytes(response.bodyBytes);
//       return file;
//     } catch (e) {
//       throw Exception('Failed to download image: $e');
//     }
//   }

//   Future<void> _sendMatchNotifications(
//       List<PetMatchResult> matches, String searchType) async {
//     for (PetMatchResult match in matches.take(3)) {
//       // Top 3 matches
//       if (match.similarity > 75.0) {
//         // High confidence matches only
//         try {
//           String title = searchType == 'lost'
//               ? '🐕 Potential Match Found!'
//               : '🔍 Someone is looking for a similar pet!';

//           String body =
//               'A ${searchType} pet similar to ${match.pet.name} has been reported. '
//               'AI Similarity: ${match.similarity.toStringAsFixed(1)}%';

//           await _notificationService.sendNotificationToUser(
//             match.pet.userId,
//             title,
//             body,
//             {
//               'petId': match.pet.id,
//               'type': 'match_found',
//               'similarity': match.similarity.toString(),
//               'searchType': searchType,
//             },
//           );
//         } catch (e) {
//           print('Error sending notification: $e');
//         }
//       }
//     }
//   }
// }

// class PetMatchResult {
//   final PetModel pet;
//   final double similarity;
//   final List<String> matchReasons;

//   PetMatchResult({
//     required this.pet,
//     required this.similarity,
//     required this.matchReasons,
//   });
// }
