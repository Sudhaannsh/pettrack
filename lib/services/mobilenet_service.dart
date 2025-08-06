// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:math';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/services.dart';

// class MobileNetService {
//   static final MobileNetService _instance = MobileNetService._internal();
//   factory MobileNetService() => _instance;
//   MobileNetService._internal();

//   Interpreter? _interpreter;
//   List<String>? _labels;
//   bool _isInitialized = false;

//   Future<void> initialize() async {
//     if (_isInitialized) return;

//     try {
//       // For now, skip model loading and use feature extraction only
//       // _interpreter = await Interpreter.fromAsset('assets/models/mobilenet_v2_1.0_224.tflite');
      
//       // Skip labels loading for now
//       // String labelsData = await rootBundle.loadString('assets/labels/imagenet_labels.txt');
//       // _labels = labelsData.split('\n').where((line) => line.isNotEmpty).toList();
      
//       _isInitialized = true;
//       print('MobileNet service initialized (feature extraction mode)');
//     } catch (e) {
//       print('Error loading MobileNet model: $e');
//       _isInitialized = true; // Continue with feature extraction
//     }
//   }

//   Future<PetAnalysisResult> analyzePetImage(File imageFile) async {
//     if (!_isInitialized) await initialize();

//     try {
//       // Load and preprocess image
//       img.Image? image = img.decodeImage(await imageFile.readAsBytes());
//       if (image == null) return PetAnalysisResult.empty();

//       // Extract features using multiple methods
//       PetFeatures features = await _extractComprehensiveFeatures(image);
      
//       // Skip MobileNet inference for now, use feature-based analysis
//       List<Recognition> recognitions = _generateBasicRecognitions(features);

//       // Analyze pet characteristics
//       PetCharacteristics characteristics = _analyzePetCharacteristics(image, features, recognitions);

//       return PetAnalysisResult(
//         features: features,
//         recognitions: recognitions,
//         characteristics: characteristics,
//         confidence: 0.8, // Default confidence for feature-based analysis
//       );
//     } catch (e) {
//       print('Error analyzing pet image: $e');
//       return PetAnalysisResult.empty();
//     }
//   }

//   List<Recognition> _generateBasicRecognitions(PetFeatures features) {
//     // Generate basic recognitions based on features
//     List<Recognition> recognitions = [];
    
//     // Analyze dominant colors to guess animal type
//     List<String> colorNames = _getColorNames(features.dominantColors);
    
//     if (colorNames.contains('Brown') || colorNames.contains('Golden')) {
//       recognitions.add(Recognition(id: 1, label: 'Dog', confidence: 0.7));
//     }
//     if (colorNames.contains('Gray') || colorNames.contains('White')) {
//       recognitions.add(Recognition(id: 2, label: 'Cat', confidence: 0.6));
//     }
    
//     return recognitions;
//   }

//   Future<PetFeatures> _extractComprehensiveFeatures(img.Image image) async {
//     // Resize for consistent processing
//     img.Image processed = img.copyResize(image, width: 256, height: 256);

//     return PetFeatures(
//       colorHistogram: _extractColorHistogram(processed),
//       dominantColors: _extractDominantColors(processed),
//       textureFeatures: _extractTextureFeatures(processed),
//       shapeFeatures: _extractShapeFeatures(processed),
//       brightnessStats: _calculateBrightnessStats(processed),
//     );
//   }

//   List<double> _extractColorHistogram(img.Image image) {
//     List<double> histogram = List.filled(64, 0.0); // 4x4x4 RGB bins
//     int totalPixels = image.width * image.height;

//     for (int y = 0; y < image.height; y++) {
//       for (int x = 0; x < image.width; x++) {
//         img.Pixel pixel = image.getPixel(x, y);
//         int r = (pixel.r / 64).floor().clamp(0, 3);
//         int g = (pixel.g / 64).floor().clamp(0, 3);
//         int b = (pixel.b / 64).floor().clamp(0, 3);
        
//         int binIndex = r * 16 + g * 4 + b;
//         histogram[binIndex]++;
//       }
//     }

//     // Normalize
//     return histogram.map((count) => count / totalPixels).toList();
//   }

//   List<DominantColor> _extractDominantColors(img.Image image) {
//     Map<String, ColorCount> colorMap = {};

//     // Sample every 5th pixel for performance
//     for (int y = 0; y < image.height; y += 5) {
//       for (int x = 0; x < image.width; x += 5) {
//         img.Pixel pixel = image.getPixel(x, y);
        
//         // Quantize colors
//         int r = (pixel.r / 32).round() * 32;
//         int g = (pixel.g / 32).round() * 32;
//         int b = (pixel.b / 32).round() * 32;
        
//         String key = '$r,$g,$b';
//         if (colorMap.containsKey(key)) {
//           colorMap[key]!.count++;
//         } else {
//           colorMap[key] = ColorCount(r, g, b, 1);
//         }
//       }
//     }

//     // Get top 5 colors
//     List<ColorCount> sortedColors = colorMap.values.toList()
//       ..sort((a, b) => b.count.compareTo(a.count));

//     return sortedColors.take(5).map((cc) => 
//       DominantColor(cc.r, cc.g, cc.b, cc.count)
//     ).toList();
//   }

//   List<double> _extractTextureFeatures(img.Image image) {
//     // Local Binary Pattern implementation
//     List<double> lbpHistogram = List.filled(256, 0.0);
    
//     for (int y = 1; y < image.height - 1; y++) {
//       for (int x = 1; x < image.width - 1; x++) {
//         img.Pixel centerPixel = image.getPixel(x, y);
//         int centerGray = _toGrayscale(centerPixel);
        
//         int lbpValue = 0;
//         List<List<int>> neighbors = [
//           [-1, -1], [-1, 0], [-1, 1],
//           [0, 1], [1, 1], [1, 0],
//           [1, -1], [0, -1]
//         ];
        
//         for (int i = 0; i < neighbors.length; i++) {
//           int nx = x + neighbors[i][0];
//           int ny = y + neighbors[i][1];
//           img.Pixel neighborPixel = image.getPixel(nx, ny);
//           int neighborGray = _toGrayscale(neighborPixel);
          
//           if (neighborGray >= centerGray) {
//             lbpValue |= (1 << i);
//           }
//         }
        
//         lbpHistogram[lbpValue]++;
//       }
//     }
    
//     // Normalize
//     double total = lbpHistogram.reduce((a, b) => a + b);
//     return total > 0 ? lbpHistogram.map((count) => count / total).toList() : lbpHistogram;
//   }

//   List<double> _extractShapeFeatures(img.Image image) {
//     // Basic shape analysis
//     List<List<int>> edges = _detectEdges(image);
    
//     int totalEdges = 0;
//     int strongEdges = 0;
    
//     for (int y = 0; y < edges.length; y++) {
//       for (int x = 0; x < edges[y].length; x++) {
//         if (edges[y][x] > 50) {
//           totalEdges++;
//           if (edges[y][x] > 100) strongEdges++;
//         }
//       }
//     }
    
//     double aspectRatio = image.width / image.height;
//     double edgeDensity = totalEdges / (image.width * image.height);
//     double strongEdgeRatio = totalEdges > 0 ? strongEdges / totalEdges : 0.0;
    
//     return [aspectRatio, edgeDensity, strongEdgeRatio, totalEdges.toDouble()];
//   }

//   BrightnessStats _calculateBrightnessStats(img.Image image) {
//     List<int> brightness = [];
    
//     for (int y = 0; y < image.height; y++) {
//       for (int x = 0; x < image.width; x++) {
//         img.Pixel pixel = image.getPixel(x, y);
//         brightness.add(_toGrayscale(pixel));
//       }
//     }
    
//     brightness.sort();
    
//     double mean = brightness.reduce((a, b) => a + b) / brightness.length;
//     double variance = brightness.map((b) => pow(b - mean, 2)).reduce((a, b) => a + b) / brightness.length;
    
//     return BrightnessStats(
//       mean: mean,
//       median: brightness[brightness.length ~/ 2].toDouble(),
//       stdDev: sqrt(variance),
//       min: brightness.first.toDouble(),
//       max: brightness.last.toDouble(),
//     );
//   }

//   PetCharacteristics _analyzePetCharacteristics(
//     img.Image image, 
//     PetFeatures features, 
//     List<Recognition> recognitions
//   ) {
//     return PetCharacteristics(
//       animalType: _determineAnimalType(recognitions),
//       estimatedBreed: _determineBreed(recognitions),
//       estimatedSize: _estimateSize(features, recognitions),
//       coatPattern: _analyzeCoatPattern(features),
//       dominantColorNames: _getColorNames(features.dominantColors),
//     );
//   }

//   String _determineAnimalType(List<Recognition> recognitions) {
//     for (Recognition r in recognitions.take(5)) {
//       String label = r.label.toLowerCase();
//       if (label.contains('dog') || label.contains('puppy') || label.contains('canine')) return 'Dog';
//       if (label.contains('cat') || label.contains('kitten') || label.contains('feline')) return 'Cat';
//     }
//     return 'Pet'; // Default to Pet if can't determine
//   }

//   String _determineBreed(List<Recognition> recognitions) {
//     for (Recognition r in recognitions.take(3)) {
//       if (r.confidence > 0.3) {
//         return r.label;
//       }
//     }
//     return 'Mixed Breed';
//   }

//   String _estimateSize(PetFeatures features, List<Recognition> recognitions) {
//     // Use breed information if available
//     for (Recognition r in recognitions.take(3)) {
//       String breed = r.label.toLowerCase();
//       if (breed.contains('chihuahua') || breed.contains('yorkie') || breed.contains('pomeranian')) {
//         return 'Small';
//       }
//       if (breed.contains('golden') || breed.contains('labrador') || breed.contains('german')) {
//         return 'Large';
//       }
//     }
    
//     // Fallback to shape analysis
//     if (features.shapeFeatures.isNotEmpty) {
//       double aspectRatio = features.shapeFeatures[0];
//       if (aspectRatio > 1.3) return 'Large';
//       if (aspectRatio < 0.8) return 'Small';
//     }
    
//     return 'Medium';
//   }

//   String _analyzeCoatPattern(PetFeatures features) {
//     if (features.dominantColors.length <= 2) return 'Solid';
//     if (features.dominantColors.length >= 4) return 'Multi-colored';
//     return 'Patterned';
//   }

//   List<String> _getColorNames(List<DominantColor> colors) {
//     return colors.map((color) => _getColorName(color.r, color.g, color.b)).toList();
//   }

//   String _getColorName(int r, int g, int b) {
//     // Simple color name mapping
//     if (r > 200 && g > 200 && b > 200) return 'White';
//     if (r < 50 && g < 50 && b < 50) return 'Black';
//     if (r > 150 && g > 100 && b < 100) return 'Brown';
//     if (r > 200 && g > 150 && b < 100) return 'Golden';
//     if (r < 100 && g < 100 && b > 150) return 'Blue';
//     if (r > 100 && g > 100 && b > 100) return 'Gray';
//     return 'Mixed';
//   }

//   // Helper methods
//   int _toGrayscale(img.Pixel pixel) {
//     return ((pixel.r + pixel.g + pixel.b) / 3).round();
//   }

//   List<List<int>> _detectEdges(img.Image image) {
//     List<List<int>> gray = List.generate(
//       image.height, 
//       (i) => List.filled(image.width, 0)
//     );
    
//     // Convert to grayscale
//     for (int y = 0; y < image.height; y++) {
//       for (int x = 0; x < image.width; x++) {
//         gray[y][x] = _toGrayscale(image.getPixel(x, y));
//       }
//     }
    
//     List<List<int>> edges = List.generate(
//       image.height, 
//       (i) => List.filled(image.width, 0)
//     );
    
//     // Sobel edge detection
//     for (int y = 1; y < image.height - 1; y++) {
//       for (int x = 1; x < image.width - 1; x++) {
//         int gx = (-1 * gray[y-1][x-1]) + (1 * gray[y-1][x+1]) +
//                  (-2 * gray[y][x-1]) + (2 * gray[y][x+1]) +
//                  (-1 * gray[y+1][x-1]) + (1 * gray[y+1][x+1]);
                 
//         int gy = (-1 * gray[y-1][x-1]) + (-2 * gray[y-1][x]) + (-1 * gray[y-1][x+1]) +
//                  (1 * gray[y+1][x-1]) + (2 * gray[y+1][x]) + (1 * gray[y+1][x+1]);
                 
//         edges[y][x] = sqrt(gx * gx + gy * gy).round();
//       }
//     }
    
//     return edges;
//   }
// }

// // Data classes remain the same...
// class PetAnalysisResult {
//   final PetFeatures features;
//   final List<Recognition> recognitions;
//   final PetCharacteristics characteristics;
//   final double confidence;

//   PetAnalysisResult({
//     required this.features,
//     required this.recognitions,
//     required this.characteristics,
//     required this.confidence,
//   });

//   static PetAnalysisResult empty() {
//     return PetAnalysisResult(
//       features: PetFeatures.empty(),
//       recognitions: [],
//       characteristics: PetCharacteristics.empty(),
//       confidence: 0.0,
//     );
//   }
// }

// class PetFeatures {
//   final List<double> colorHistogram;
//   final List<DominantColor> dominantColors;
//   final List<double> textureFeatures;
//   final List<double> shapeFeatures;
//   final BrightnessStats brightnessStats;

//   PetFeatures({
//     required this.colorHistogram,
//     required this.dominantColors,
//     required this.textureFeatures,
//     required this.shapeFeatures,
//     required this.brightnessStats,
//   });

//   static PetFeatures empty() {
//     return PetFeatures(
//       colorHistogram: [],
//       dominantColors: [],
//       textureFeatures: [],
//       shapeFeatures: [],
//       brightnessStats: BrightnessStats(mean: 0, median: 0, stdDev: 0, min: 0, max: 0),
//     );
//   }
// }

// class Recognition {
//   final int id;
//   final String label;
//   final double confidence;

//   Recognition({
//     required this.id,
//     required this.label,
//     required this.confidence,
//   });
// }

// class PetCharacteristics {
//   final String animalType;
//   final String estimatedBreed;
//   final String estimatedSize;
//   final String coatPattern;
//   final List<String> dominantColorNames;

//   PetCharacteristics({
//     required this.animalType,
//     required this.estimatedBreed,
//     required this.estimatedSize,
//     required this.coatPattern,
//     required this.dominantColorNames,
//   });

//   static PetCharacteristics empty() {
//     return PetCharacteristics(
//       animalType: 'Unknown',
//       estimatedBreed: 'Unknown',
//       estimatedSize: 'Unknown',
//       coatPattern: 'Unknown',
//       dominantColorNames: [],
//     );
//   }
// }

// class DominantColor {
//   final int r, g, b;
//   final int count;

//   DominantColor(this.r, this.g, this.b, this.count);
// }

// class ColorCount {
//   final int r, g, b;
//   int count;

//   ColorCount(this.r, this.g, this.b, this.count);
// }

// class BrightnessStats {
//   final double mean;
//   final double median;
//   final double stdDev;
//   final double min;
//   final double max;

//   BrightnessStats({
//     required this.mean,
//     required this.median,
//     required this.stdDev,
//     required this.min,
//     required this.max,
//   });
// }