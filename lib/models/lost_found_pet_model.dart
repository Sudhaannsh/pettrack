import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundPetModel {
  final String? id;
  final String name;
  final String breed;
  final String color;
  final String location;
  final String imageUrl;
  final String status; // "lost" or "found"
  final DateTime timestamp;
  final String userId;
  final double latitude;
  final double longitude;
  final String? description;
  final String? contactPhone;
  final String? petType; // Dog, Cat, Other
  final String? size; // Small, Medium, Large
  final DateTime? lastSeenDate;
  final List<String>? tags;

  LostFoundPetModel({
    this.id,
    required this.name,
    required this.breed,
    required this.color,
    required this.location,
    required this.imageUrl,
    required this.status,
    required this.timestamp,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.description,
    this.contactPhone,
    this.petType,
    this.size,
    this.lastSeenDate,
    this.tags,
  });

  factory LostFoundPetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return LostFoundPetModel(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      color: data['color'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      status: data['status'] ?? 'lost',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      description: data['description'],
      contactPhone: data['contactPhone'],
      petType: data['petType'],
      size: data['size'],
      lastSeenDate: (data['lastSeenDate'] as Timestamp?)?.toDate(),
      tags: data['tags'] != null ? List<String>.from(data['tags']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'breed': breed,
      'color': color,
      'location': location,
      'imageUrl': imageUrl,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'contactPhone': contactPhone,
      'petType': petType,
      'size': size,
      'lastSeenDate':
          lastSeenDate != null ? Timestamp.fromDate(lastSeenDate!) : null,
      'tags': tags,
    };
  }

  // Helper method to extract phone number from description
  String? get extractedPhoneNumber {
    if (contactPhone != null && contactPhone!.isNotEmpty) {
      return contactPhone;
    }
    if (description == null) return null;

    final phoneRegex = RegExp(r'Contact:\s*([+]?[\d\s\-()]+)');
    final match = phoneRegex.firstMatch(description!);
    return match?.group(1)?.trim();
  }
}
