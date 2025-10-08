
// import 'dart:io';
// import 'dart:math'; // Add this import for mathematical functions
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pettrack/models/pet_model.dart';
// import 'package:pettrack/services/cloudinary_service.dart';

// class PetService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final CloudinaryService _cloudinaryService = CloudinaryService();

//   // Get pets by user ID
//   Future<List<PetModel>> getPetsByUserId(String userId) async {
//     try {
//       final snapshot = await _firestore
//           .collection('pets')
//           .where('userId', isEqualTo: userId)
//           .get();
      
//       return snapshot.docs
//           .map((doc) => PetModel.fromMap(doc.data(), doc.id))
//           .toList();
//     } catch (e) {
//       print('Error getting pets by user ID: $e');
//       return [];
//     }
//   }

//   // Add a new pet
//   Future<void> addPet(PetModel pet, File imageFile) async {
//     try {
//       // Upload image to Cloudinary
//       String imageUrl = await _cloudinaryService.uploadImage(imageFile);

//       // Create pet with image URL
//       PetModel petWithImage = PetModel(
//         name: pet.name,
//         breed: pet.breed,
//         color: pet.color,
//         location: pet.location,
//         imageUrl: imageUrl,
//         status: pet.status,
//         timestamp: pet.timestamp,
//         userId: pet.userId,
//         latitude: pet.latitude,
//         longitude: pet.longitude,
//         description: pet.description,
//       );

//       // Add to Firestore
//       await _firestore.collection('pets').add(petWithImage.toMap());
//     } catch (e) {
//       print('Error in addPet: $e');
//       rethrow;
//     }
//   }

//   // Update an existing pet
//   Future<void> updatePet(PetModel pet) async {
//     try {
//       if (pet.id == null) {
//         throw Exception('Pet ID is required for update');
//       }

//       // Update in Firestore
//       await _firestore.collection('pets').doc(pet.id).update(pet.toMap());
//     } catch (e) {
//       print('Error updating pet: $e');
//       rethrow;
//     }
//   }

//   // Update pet with new image
//   Future<void> updatePetWithImage(PetModel pet, File imageFile) async {
//     try {
//       if (pet.id == null) {
//         throw Exception('Pet ID is required for update');
//       }

//       // Upload new image to Cloudinary
//       String newImageUrl = await _cloudinaryService.uploadImage(imageFile);

//       // Create updated pet with new image URL
//       PetModel updatedPet = PetModel(
//         id: pet.id,
//         name: pet.name,
//         breed: pet.breed,
//         color: pet.color,
//         location: pet.location,
//         imageUrl: newImageUrl,
//         status: pet.status,
//         timestamp: pet.timestamp,
//         userId: pet.userId,
//         latitude: pet.latitude,
//         longitude: pet.longitude,
//         description: pet.description,
//       );

//       // Update in Firestore
//       await _firestore
//           .collection('pets')
//           .doc(pet.id)
//           .update(updatedPet.toMap());

//       // Note: Old image will remain in Cloudinary
//       // For production, you might want to delete the old image
//       if (pet.imageUrl.isNotEmpty) {
//         String oldPublicId =
//             _cloudinaryService.extractPublicIdFromUrl(pet.imageUrl);
//         print(
//             'Pet updated. Old image public ID for manual cleanup: $oldPublicId');
//       }
//     } catch (e) {
//       print('Error updating pet with image: $e');
//       rethrow;
//     }
//   }

//   // Delete pet (only removes from Firestore, image stays in Cloudinary)
//   Future<void> deletePet(String petId, String imageUrl) async {
//     try {
//       // Delete from Firestore
//       await _firestore.collection('pets').doc(petId).delete();

//       // Note: Image will remain in Cloudinary
//       // For production, you might want to:
//       // 1. Keep a list of "deleted" images for manual cleanup
//       // 2. Implement server-side deletion
//       // 3. Use Cloudinary's auto-delete features

//       if (imageUrl.isNotEmpty) {
//         String publicId = _cloudinaryService.extractPublicIdFromUrl(imageUrl);
//         print('Pet deleted. Image public ID for manual cleanup: $publicId');
//       }
//     } catch (e) {
//       print('Error deleting pet: $e');
//       rethrow;
//     }
//   }

//   // Get pets by status (lost/found)
//   Stream<List<PetModel>> getPetsByStatus(String status) {
//     return _firestore
//         .collection('pets')
//         .where('status', isEqualTo: status)
//         .snapshots()
//         .map((snapshot) {
//       List<PetModel> pets = snapshot.docs
//           .map((doc) => PetModel.fromMap(doc.data(), doc.id))
//           .toList();

//       pets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       return pets;
//     });
//   }

//   // Get a single pet by ID
//   Future<PetModel?> getPetById(String petId) async {
//     try {
//       DocumentSnapshot doc =
//           await _firestore.collection('pets').doc(petId).get();
//       if (doc.exists) {
//         return PetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
//       }
//       return null;
//     } catch (e) {
//       print('Error getting pet by ID: $e');
//       rethrow;
//     }
//   }

//   // Get pets by user ID
//   Stream<List<PetModel>> getUserPets(String userId) {
//     return _firestore
//         .collection('pets')
//         .where('userId', isEqualTo: userId)
//         .snapshots()
//         .map((snapshot) {
//       List<PetModel> pets = snapshot.docs
//           .map((doc) => PetModel.fromMap(doc.data(), doc.id))
//           .toList();

//       pets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       return pets;
//     });
//   }

//   // Get all pets (stream)
//   Stream<List<PetModel>> getAllPets() {
//     return _firestore.collection('pets').snapshots().map((snapshot) {
//       List<PetModel> pets = snapshot.docs
//           .map((doc) => PetModel.fromMap(doc.data(), doc.id))
//           .toList();

//       pets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       return pets;
//     });
//   }

//   // Get all pets (one-time fetch)
//   Future<List<PetModel>> getAllPetsOnce() async {
//     try {
//       final snapshot = await _firestore.collection('pets').get();
//       List<PetModel> pets = snapshot.docs
//           .map((doc) => PetModel.fromMap(doc.data(), doc.id))
//           .toList();

//       pets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       return pets;
//     } catch (e) {
//       print('Error getting all pets: $e');
//       rethrow;
//     }
//   }

//   // Search pets by name or breed
//   Future<List<PetModel>> searchPets(String query) async {
//     try {
//       final snapshot = await _firestore.collection('pets').get();
//       List<PetModel> allPets = snapshot.docs
//           .map((doc) => PetModel.fromMap(doc.data(), doc.id))
//           .toList();

//       // Filter pets based on query
//       List<PetModel> filteredPets = allPets.where((pet) {
//         return pet.name.toLowerCase().contains(query.toLowerCase()) ||
//             pet.breed.toLowerCase().contains(query.toLowerCase()) ||
//             pet.color.toLowerCase().contains(query.toLowerCase());
//       }).toList();

//       filteredPets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       return filteredPets;
//     } catch (e) {
//       print('Error searching pets: $e');
//       rethrow;
//     }
//   }

//   // Get pets within a certain radius (in kilometers)
//   Future<List<PetModel>> getPetsNearLocation(
//       double latitude, double longitude, double radiusKm) async {
//     try {
//       final snapshot = await _firestore.collection('pets').get();
//       List<PetModel> allPets = snapshot.docs
//           .map((doc) => PetModel.fromMap(doc.data(), doc.id))
//           .toList();

//       // Filter pets by distance
//       List<PetModel> nearbyPets = allPets.where((pet) {
//         if (pet.latitude == 0.0 || pet.longitude == 0.0) return false;

//         // Calculate distance using Haversine formula
//         double distance = _calculateDistance(
//             latitude, longitude, pet.latitude, pet.longitude);

//         return distance <= radiusKm;
//       }).toList();

//       nearbyPets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       return nearbyPets;
//     } catch (e) {
//       print('Error getting nearby pets: $e');
//       rethrow;
//     }
//   }

//   // Calculate distance between two points using Haversine formula
//   double _calculateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371; // Earth's radius in kilometers

//     double dLat = _degreesToRadians(lat2 - lat1);
//     double dLon = _degreesToRadians(lon2 - lon1);

//     double a = sin(dLat / 2) * sin(dLat / 2) +
//         cos(_degreesToRadians(lat1)) *
//             cos(_degreesToRadians(lat2)) *
//             sin(dLon / 2) *
//             sin(dLon / 2);

//     double c = 2 * asin(sqrt(a));

//     return earthRadius * c;
//   }

//   // Convert degrees to radians
//   double _degreesToRadians(double degrees) {
//     return degrees * (pi / 180);
//   }
// }
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
import 'package:pettrack/models/pet_model.dart';
import 'package:pettrack/services/cloudinary_service.dart';

class PetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // ADD THIS: Upload image method (can use Cloudinary or Firebase Storage)
  // Upload image method
  Future<String> uploadImage(File imageFile) async {
    try {
      return await _cloudinaryService.uploadImage(imageFile);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }



  // UPDATE THIS: Modified addPet method to accept Map instead of PetModel + File
  Future<String> addPet(Map<String, dynamic> petData) async {
    try {
      // Add to Firestore
      final docRef = await _firestore.collection('pets').add(petData);
      return docRef.id;
    } catch (e) {
      print('Error in addPet: $e');
      throw Exception('Failed to add pet: $e');
    }
  }

  // UPDATE THIS: Modified updatePet to accept petId and Map
  Future<void> updatePet(String petId, Map<String, dynamic> petData) async {
    try {
      // Update in Firestore
      await _firestore.collection('pets').doc(petId).update(petData);
    } catch (e) {
      print('Error updating pet: $e');
      throw Exception('Failed to update pet: $e');
    }
  }

  // UPDATE THIS: Simplified deletePet method
  Future<void> deletePet(String petId) async {
    try {
      // Get pet data to extract image URL
      final petDoc = await _firestore.collection('pets').doc(petId).get();

      if (petDoc.exists) {
        final petData = petDoc.data();
        final imageUrl = petData?['imageUrl'] as String?;

        // Delete from Firestore
        await _firestore.collection('pets').doc(petId).delete();

        // Optional: Delete image from storage
        if (imageUrl != null && imageUrl.isNotEmpty) {
          try {
            // If using Cloudinary
            String publicId =
                _cloudinaryService.extractPublicIdFromUrl(imageUrl);
            print('Pet deleted. Image public ID for manual cleanup: $publicId');

            // If using Firebase Storage, uncomment below:
            /*
            final ref = FirebaseStorage.instance.refFromURL(imageUrl);
            await ref.delete();
            */
          } catch (e) {
            print('Error deleting image: $e');
          }
        }
      }
    } catch (e) {
      print('Error deleting pet: $e');
      throw Exception('Failed to delete pet: $e');
    }
  }

  // UPDATE THIS: Get pets by user ID with 'owned' status filter
  // Future<List<PetModel>> getPetsByUserId(String userId) async {
  //   try {
  //     final snapshot = await _firestore
  //         .collection('pets')
  //         .where('ownerId',
  //             isEqualTo: userId) // Changed from 'userId' to 'ownerId'
  //         .where('status', isEqualTo: 'owned')
  //         .orderBy('timestamp', descending: true)
  //         .get();

  //     return snapshot.docs
  //         .map((doc) => PetModel.fromFirestore(
  //             doc)) // Use fromFirestore instead of fromMap
  //         .toList();
  //   } catch (e) {
  //     print('Error getting pets by user ID: $e');
  //     return [];
  //   }
  // }
// Update this method in pet_service.dart
  Future<List<PetModel>> getPetsByUserId(String userId) async {
    try {
      print('Getting pets for user: $userId'); // Debug log

      // Try both field names for compatibility
      final snapshot1 = await _firestore
          .collection('pets')
          .where('ownerId', isEqualTo: userId)
          .get();

      final snapshot2 = await _firestore
          .collection('pets')
          .where('userId', isEqualTo: userId)
          .get();

      // Combine results and remove duplicates
      Set<String> seenIds = {};
      List<PetModel> allPets = [];

      for (var doc in [...snapshot1.docs, ...snapshot2.docs]) {
        if (!seenIds.contains(doc.id)) {
          seenIds.add(doc.id);
          allPets.add(PetModel.fromFirestore(doc));
        }
      }

      print('Found ${allPets.length} pets'); // Debug log

      // Sort by timestamp
      allPets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return allPets;
    } catch (e) {
      print('Error getting pets by user ID: $e');
      return [];
    }
  }
  // KEEP THIS: Get pets by status (lost/found)
  Stream<List<PetModel>> getPetsByStatus(String status) {
    return _firestore
        .collection('pets')
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      List<PetModel> pets =
          snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();

      pets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return pets;
    });
  }

  // UPDATE THIS: Get a single pet by ID (already good, just ensure it uses fromFirestore)
  Future<PetModel?> getPetById(String petId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('pets').doc(petId).get();
      if (doc.exists) {
        return PetModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting pet by ID: $e');
      return null; // Return null instead of rethrowing for better UX
    }
  }

  // UPDATE THIS: Get pets by user ID as Stream
  Stream<List<PetModel>> getUserPets(String userId) {
    return _firestore
        .collection('pets')
        .where('ownerId', isEqualTo: userId) // Changed from 'userId'
        .where('status', isEqualTo: 'owned')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
    });
  }

  // KEEP THIS: Get all pets (stream)
  Stream<List<PetModel>> getAllPets() {
    return _firestore
        .collection('pets')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
    });
  }

  // KEEP THIS: Get all pets (one-time fetch)
  Future<List<PetModel>> getAllPetsOnce() async {
    try {
      final snapshot = await _firestore
          .collection('pets')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting all pets: $e');
      return [];
    }
  }

  // KEEP THIS: Search pets
  Future<List<PetModel>> searchPets(String query) async {
    try {
      final snapshot = await _firestore.collection('pets').get();
      List<PetModel> allPets =
          snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();

      // Filter pets based on query
      List<PetModel> filteredPets = allPets.where((pet) {
        return pet.name.toLowerCase().contains(query.toLowerCase()) ||
            pet.breed.toLowerCase().contains(query.toLowerCase()) ||
            pet.color.toLowerCase().contains(query.toLowerCase()) ||
            (pet.description?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();

      filteredPets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filteredPets;
    } catch (e) {
      print('Error searching pets: $e');
      return [];
    }
  }

  // KEEP THIS: Get pets near location
  Future<List<PetModel>> getPetsNearLocation(
      double latitude, double longitude, double radiusKm) async {
    try {
      final snapshot = await _firestore.collection('pets').get();
      List<PetModel> allPets =
          snapshot.docs.map((doc) => PetModel.fromFirestore(doc)).toList();

      // Filter pets by distance
      List<PetModel> nearbyPets = allPets.where((pet) {
        if (pet.latitude == 0.0 || pet.longitude == 0.0) return false;

        double distance = _calculateDistance(
            latitude, longitude, pet.latitude, pet.longitude);

        return distance <= radiusKm;
      }).toList();

      nearbyPets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return nearbyPets;
    } catch (e) {
      print('Error getting nearby pets: $e');
      return [];
    }
  }

  // KEEP THIS: Calculate distance
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371;

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * asin(sqrt(a));

    return earthRadius * c;
  }

  // KEEP THIS: Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  // REMOVE THESE OLD METHODS (they're redundant with the new structure):
  // - Old addPet(PetModel pet, File imageFile)
  // - updatePetWithImage method
  // - Old deletePet(String petId, String imageUrl)
}
