// import 'dart:io';
// import 'dart:math';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:pettrack/models/lost_found_pet_model.dart';
// import 'package:pettrack/services/cloudinary_service.dart';

// class LostFoundPetService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final CloudinaryService _cloudinaryService = CloudinaryService();

//   // Upload image
//   Future<String> uploadImage(File imageFile) async {
//     try {
//       return await _cloudinaryService.uploadImage(imageFile);
//     } catch (e) {
//       throw Exception('Failed to upload image: $e');
//     }
//   }

//   // Add lost/found pet
//   Future<String> addLostFoundPet(Map<String, dynamic> petData) async {
//     try {
//       final docRef =
//           await _firestore.collection('lost_found_pets').add(petData);
//       return docRef.id;
//     } catch (e) {
//       throw Exception('Failed to add lost/found pet: $e');
//     }
//   }

//   // Get pets by status (lost/found)
//   Stream<List<LostFoundPetModel>> getPetsByStatus(String status) {
//     return _firestore
//         .collection('lost_found_pets')
//         .where('status', isEqualTo: status)
//         .orderBy('timestamp', descending: true)
//         .snapshots()
//         .map((snapshot) {
//       return snapshot.docs
//           .map((doc) => LostFoundPetModel.fromFirestore(doc))
//           .toList();
//     });
//   }

//   // Get all lost/found pets
//   Future<List<LostFoundPetModel>> getAllLostFoundPetsOnce() async {
//     try {
//       final snapshot = await _firestore
//           .collection('lost_found_pets')
//           .orderBy('timestamp', descending: true)
//           .get();

//       return snapshot.docs
//           .map((doc) => LostFoundPetModel.fromFirestore(doc))
//           .toList();
//     } catch (e) {
//       print('Error getting all lost/found pets: $e');
//       return [];
//     }
//   }

//   // Get lost/found pet by ID
//   Future<LostFoundPetModel?> getLostFoundPetById(String petId) async {
//     try {
//       final doc =
//           await _firestore.collection('lost_found_pets').doc(petId).get();
//       if (doc.exists) {
//         return LostFoundPetModel.fromFirestore(doc);
//       }
//       return null;
//     } catch (e) {
//       print('Error getting lost/found pet by ID: $e');
//       return null;
//     }
//   }

//   // Update lost/found pet
//   Future<void> updateLostFoundPet(
//       String petId, Map<String, dynamic> petData) async {
//     try {
//       await _firestore.collection('lost_found_pets').doc(petId).update(petData);
//     } catch (e) {
//       throw Exception('Failed to update lost/found pet: $e');
//     }
//   }

//   // Delete lost/found pet
//   Future<void> deleteLostFoundPet(String petId) async {
//     try {
//       await _firestore.collection('lost_found_pets').doc(petId).delete();
//     } catch (e) {
//       throw Exception('Failed to delete lost/found pet: $e');
//     }
//   }

//   // Search lost/found pets
//   Future<List<LostFoundPetModel>> searchLostFoundPets(String query) async {
//     try {
//       final snapshot = await _firestore.collection('lost_found_pets').get();
//       final allPets = snapshot.docs
//           .map((doc) => LostFoundPetModel.fromFirestore(doc))
//           .toList();

//       final filteredPets = allPets.where((pet) {
//         return pet.name.toLowerCase().contains(query.toLowerCase()) ||
//             pet.breed.toLowerCase().contains(query.toLowerCase()) ||
//             pet.color.toLowerCase().contains(query.toLowerCase()) ||
//             (pet.description?.toLowerCase().contains(query.toLowerCase()) ??
//                 false);
//       }).toList();

//       filteredPets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
//       return filteredPets;
//     } catch (e) {
//       print('Error searching lost/found pets: $e');
//       return [];
//     }
//   }

//   // Calculate distance between two points
//   double _calculateDistance(
//       double lat1, double lon1, double lat2, double lon2) {
//     const double earthRadius = 6371;
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

//   double _degreesToRadians(double degrees) {
//     return degrees * (pi / 180);
//   }
// }
import 'dart:io';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pettrack/models/lost_found_pet_model.dart';
import 'package:pettrack/services/cloudinary_service.dart';

class LostFoundPetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

  // Upload image
  Future<String> uploadImage(File imageFile) async {
    try {
      return await _cloudinaryService.uploadImage(imageFile);
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  // Add lost/found pet
  Future<String> addLostFoundPet(Map<String, dynamic> petData) async {
    try {
      final docRef =
          await _firestore.collection('lost_found_pets').add(petData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add lost/found pet: $e');
    }
  }

  // Get pets by status (lost/found)
  Stream<List<LostFoundPetModel>> getPetsByStatus(String status) {
    return _firestore
        .collection('lost_found_pets')
        .where('status', isEqualTo: status)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => LostFoundPetModel.fromFirestore(doc))
          .toList();
    });
  }

  // Get all lost/found pets
  Future<List<LostFoundPetModel>> getAllLostFoundPetsOnce() async {
    try {
      final snapshot = await _firestore
          .collection('lost_found_pets')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => LostFoundPetModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting all lost/found pets: $e');
      return [];
    }
  }

  // Get lost/found pet by ID
  Future<LostFoundPetModel?> getLostFoundPetById(String petId) async {
    try {
      final doc =
          await _firestore.collection('lost_found_pets').doc(petId).get();
      if (doc.exists) {
        return LostFoundPetModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting lost/found pet by ID: $e');
      return null;
    }
  }

  // Update lost/found pet
  Future<void> updateLostFoundPet(
      String petId, Map<String, dynamic> petData) async {
    try {
      await _firestore.collection('lost_found_pets').doc(petId).update(petData);
    } catch (e) {
      throw Exception('Failed to update lost/found pet: $e');
    }
  }

  // ADD: Update lost/found pet with new image
  Future<void> updateLostFoundPetWithImage(
      String petId, Map<String, dynamic> petData, File imageFile) async {
    try {
      // Upload new image
      String newImageUrl = await uploadImage(imageFile);

      // Add image URL to pet data
      petData['imageUrl'] = newImageUrl;

      // Update the pet
      await _firestore.collection('lost_found_pets').doc(petId).update(petData);
    } catch (e) {
      throw Exception('Failed to update lost/found pet with image: $e');
    }
  }

  // ADD: Check if current user owns this lost/found pet
  Future<bool> isUserOwnerOfPet(String petId, String userId) async {
    try {
      final doc =
          await _firestore.collection('lost_found_pets').doc(petId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['userId'] == userId;
      }
      return false;
    } catch (e) {
      print('Error checking pet ownership: $e');
      return false;
    }
  }

  // Delete lost/found pet
  Future<void> deleteLostFoundPet(String petId) async {
    try {
      await _firestore.collection('lost_found_pets').doc(petId).delete();
    } catch (e) {
      throw Exception('Failed to delete lost/found pet: $e');
    }
  }

  // Search lost/found pets
  Future<List<LostFoundPetModel>> searchLostFoundPets(String query) async {
    try {
      final snapshot = await _firestore.collection('lost_found_pets').get();
      final allPets = snapshot.docs
          .map((doc) => LostFoundPetModel.fromFirestore(doc))
          .toList();

      final filteredPets = allPets.where((pet) {
        return pet.name.toLowerCase().contains(query.toLowerCase()) ||
            pet.breed.toLowerCase().contains(query.toLowerCase()) ||
            pet.color.toLowerCase().contains(query.toLowerCase()) ||
            (pet.description?.toLowerCase().contains(query.toLowerCase()) ??
                false);
      }).toList();

      filteredPets.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return filteredPets;
    } catch (e) {
      print('Error searching lost/found pets: $e');
      return [];
    }
  }

  // Calculate distance between two points
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

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }
}
