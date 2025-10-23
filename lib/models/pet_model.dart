// import 'package:cloud_firestore/cloud_firestore.dart';

// class PetModel {
//   final String? id;
//   final String name;
//   final String breed;
//   final String color;
//   final String location;
//   final String imageUrl;
//   final String status; // "lost" or "found"
//   final DateTime timestamp;
//   final String userId;
//   final double latitude;
//   final double longitude;
//   final String? description;
//   final List<String>? tags;

//   PetModel({
//     this.id,
//     required this.name,
//     required this.breed,
//     required this.color,
//     required this.location,
//     required this.imageUrl,
//     required this.status,
//     required this.timestamp,
//     required this.userId,
//     required this.latitude,
//     required this.longitude,
//     this.description,
//     this.tags,
//   });

//   factory PetModel.fromMap(Map<String, dynamic> map, String id) {
//     return PetModel(
//       id: id,
//       name: map['name'] ?? '',
//       breed: map['breed'] ?? '',
//       color: map['color'] ?? '',
//       location: map['location'] ?? '',
//       imageUrl: map['imageUrl'] ?? '',
//       status: map['status'] ?? 'lost',
//       timestamp: (map['timestamp'] as Timestamp).toDate(),
//       userId: map['userId'] ?? '',
//       latitude: (map['latitude'] ?? 0.0).toDouble(),
//       longitude: (map['longitude'] ?? 0.0).toDouble(),
//       description: map['description'],
//       tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'breed': breed,
//       'color': color,
//       'location': location,
//       'imageUrl': imageUrl,
//       'status': status,
//       'timestamp': timestamp,
//       'userId': userId,
//       'latitude': latitude,
//       'longitude': longitude,
//       'description': description,
//       'tags': tags,
//     };
//   }
// }
      

//       import 'package:cloud_firestore/cloud_firestore.dart';

// class PetModel {
//   final String? id;
//   final String name;
//   final String breed;
//   final String color;
//   final String age; // ADD: Age field
//   final String weight; // ADD: Weight field
//   final String location;
//   final String imageUrl;
//   final String status; // "lost", "found", or "owned"
//   final DateTime timestamp;
//   final String userId; // Keep for backward compatibility
//   final String ownerId; // ADD: New field for owner ID
//   final double latitude;
//   final double longitude;
//   final String? description;
//   final String? medicalNotes; // ADD: Medical notes field
//   final String? ownerContact; // ADD: Owner contact field
//   final List<String>? tags;

//   PetModel({
//     this.id,
//     required this.name,
//     required this.breed,
//     required this.color,
//     this.age = '', // Default empty
//     this.weight = '', // Default empty
//     required this.location,
//     required this.imageUrl,
//     required this.status,
//     required this.timestamp,
//     required this.userId,
//     String? ownerId, // Make it optional with fallback
//     required this.latitude,
//     required this.longitude,
//     this.description,
//     this.medicalNotes, // ADD
//     this.ownerContact, // ADD
//     this.tags,
//   }) : ownerId = ownerId ??
//             userId; // Use ownerId if provided, otherwise fallback to userId

//   // UPDATE: Add fromFirestore method (preferred over fromMap)
//   factory PetModel.fromFirestore(DocumentSnapshot doc) {
//     final data = doc.data() as Map<String, dynamic>;

//     return PetModel(
//       id: doc.id,
//       name: data['name'] ?? '',
//       breed: data['breed'] ?? '',
//       color: data['color'] ?? '',
//       age: data['age'] ?? '',
//       weight: data['weight'] ?? '',
//       location: data['location'] ?? '',
//       imageUrl: data['imageUrl'] ?? '',
//       status: data['status'] ?? 'lost',
//       timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       userId:
//           data['userId'] ?? data['ownerId'] ?? '', // Fallback for compatibility
//       ownerId: data['ownerId'] ?? data['userId'] ?? '', // Support both fields
//       latitude: (data['latitude'] ?? 0.0).toDouble(),
//       longitude: (data['longitude'] ?? 0.0).toDouble(),
//       description: data['description'],
//       medicalNotes: data['medicalNotes'],
//       ownerContact: data['ownerContact'],
//       tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
//     );
//   }

//   // KEEP: fromMap for backward compatibility
//   factory PetModel.fromMap(Map<String, dynamic> map, String id) {
//     return PetModel(
//       id: id,
//       name: map['name'] ?? '',
//       breed: map['breed'] ?? '',
//       color: map['color'] ?? '',
//       age: map['age'] ?? '',
//       weight: map['weight'] ?? '',
//       location: map['location'] ?? '',
//       imageUrl: map['imageUrl'] ?? '',
//       status: map['status'] ?? 'lost',
//       timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
//       userId: map['userId'] ?? map['ownerId'] ?? '',
//       ownerId: map['ownerId'] ?? map['userId'] ?? '',
//       latitude: (map['latitude'] ?? 0.0).toDouble(),
//       longitude: (map['longitude'] ?? 0.0).toDouble(),
//       description: map['description'],
//       medicalNotes: map['medicalNotes'],
//       ownerContact: map['ownerContact'],
//       tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
//     );
//   }

//   // UPDATE: toMap method with new fields
//   Map<String, dynamic> toMap() {
//     return {
//       'name': name,
//       'breed': breed,
//       'color': color,
//       'age': age,
//       'weight': weight,
//       'location': location,
//       'imageUrl': imageUrl,
//       'status': status,
//       'timestamp': Timestamp.fromDate(timestamp),
//       'userId': userId, // Keep for backward compatibility
//       'ownerId': ownerId, // New preferred field
//       'latitude': latitude,
//       'longitude': longitude,
//       'description': description,
//       'medicalNotes': medicalNotes,
//       'ownerContact': ownerContact,
//       'tags': tags,
//     };
//   }

//   // ADD: Convenience method to create a copy with updated fields
//   PetModel copyWith({
//     String? id,
//     String? name,
//     String? breed,
//     String? color,
//     String? age,
//     String? weight,
//     String? location,
//     String? imageUrl,
//     String? status,
//     DateTime? timestamp,
//     String? userId,
//     String? ownerId,
//     double? latitude,
//     double? longitude,
//     String? description,
//     String? medicalNotes,
//     String? ownerContact,
//     List<String>? tags,
//   }) {
//     return PetModel(
//       id: id ?? this.id,
//       name: name ?? this.name,
//       breed: breed ?? this.breed,
//       color: color ?? this.color,
//       age: age ?? this.age,
//       weight: weight ?? this.weight,
//       location: location ?? this.location,
//       imageUrl: imageUrl ?? this.imageUrl,
//       status: status ?? this.status,
//       timestamp: timestamp ?? this.timestamp,
//       userId: userId ?? this.userId,
//       ownerId: ownerId ?? this.ownerId,
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//       description: description ?? this.description,
//       medicalNotes: medicalNotes ?? this.medicalNotes,
//       ownerContact: ownerContact ?? this.ownerContact,
//       tags: tags ?? this.tags,
//     );
//   }

//   // ADD: Helper method to check if this is an owned pet
//   bool get isOwnedPet => status == 'owned';

//   // ADD: Helper method to check if this is a lost pet
//   bool get isLostPet => status == 'lost';

//   // ADD: Helper method to check if this is a found pet
//   bool get isFoundPet => status == 'found';
// }


import 'package:cloud_firestore/cloud_firestore.dart';

class PetModel {
  final String? id;
  final String name;
  final String breed;
  final String color;
  final String age;
  final String weight;
  final String imageUrl;
  final String ownerId;
  final DateTime timestamp;
  final String? description;
  final String? medicalNotes;
  final String? ownerContact;
  final String? microchipId;
  final List<String>? vaccinations;
  final bool isLost; // Track if this pet is currently lost

  PetModel({
    this.id,
    required this.name,
    required this.breed,
    required this.color,
    this.age = '',
    this.weight = '',
    required this.imageUrl,
    required this.ownerId,
    required this.timestamp,
    this.description,
    this.medicalNotes,
    this.ownerContact,
    this.microchipId,
    this.vaccinations,
    this.isLost = false,
  });

  factory PetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PetModel(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      color: data['color'] ?? '',
      age: data['age'] ?? '',
      weight: data['weight'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      ownerId: data['ownerId'] ?? data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      description: data['description'],
      medicalNotes: data['medicalNotes'],
      ownerContact: data['ownerContact'],
      microchipId: data['microchipId'],
      vaccinations: data['vaccinations'] != null
          ? List<String>.from(data['vaccinations'])
          : null,
      isLost: data['isLost'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'color': color,
      'age': age,
      'weight': weight,
      'imageUrl': imageUrl,
      'ownerId': ownerId,
      'timestamp': Timestamp.fromDate(timestamp),
      'description': description,
      'medicalNotes': medicalNotes,
      'ownerContact': ownerContact,
      'microchipId': microchipId,
      'vaccinations': vaccinations,
      'isLost': isLost,
    };
  }

  PetModel copyWith({
    String? id,
    String? name,
    String? breed,
    String? color,
    String? age,
    String? weight,
    String? imageUrl,
    String? ownerId,
    DateTime? timestamp,
    String? description,
    String? medicalNotes,
    String? ownerContact,
    String? microchipId,
    List<String>? vaccinations,
    bool? isLost,
  }) {
    return PetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      color: color ?? this.color,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      imageUrl: imageUrl ?? this.imageUrl,
      ownerId: ownerId ?? this.ownerId,
      timestamp: timestamp ?? this.timestamp,
      description: description ?? this.description,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      ownerContact: ownerContact ?? this.ownerContact,
      microchipId: microchipId ?? this.microchipId,
      vaccinations: vaccinations ?? this.vaccinations,
      isLost: isLost ?? this.isLost,
    );
  }
}
