import 'package:flutter/material.dart';
import 'package:pettrack/models/lost_found_pet_model.dart';
import 'package:pettrack/services/lost_found_pet_service.dart';
import 'package:pettrack/screens/lost_found_pet_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class FilterableLostFoundPetListView extends StatelessWidget {
  final String status;
  final String searchQuery;
  final LostFoundPetService _lostFoundPetService = LostFoundPetService();

  FilterableLostFoundPetListView({
    super.key,
    required this.status,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<LostFoundPetModel>>(
      stream: _lostFoundPetService.getPetsByStatus(status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final allPets = snapshot.data ?? [];

        // Filter pets based on search query
        final List<LostFoundPetModel> filteredPets = searchQuery.isEmpty
            ? allPets
            : allPets.where((pet) {
                return pet.name.toLowerCase().contains(searchQuery) ||
                    pet.breed.toLowerCase().contains(searchQuery) ||
                    pet.color.toLowerCase().contains(searchQuery) ||
                    pet.location.toLowerCase().contains(searchQuery) ||
                    (pet.description?.toLowerCase().contains(searchQuery) ??
                        false);
              }).toList();

        if (filteredPets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  searchQuery.isEmpty ? Icons.pets : Icons.search_off,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  searchQuery.isEmpty
                      ? 'No ${status.toLowerCase()} pets found'
                      : 'No $status pets match "$searchQuery"',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (searchQuery.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Try different keywords or check other tab',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredPets.length,
          itemBuilder: (context, index) {
            final pet = filteredPets[index];
            return LostFoundPetCard(pet: pet);
          },
        );
      },
    );
  }
}

class LostFoundPetCard extends StatelessWidget {
  final LostFoundPetModel pet;

  const LostFoundPetCard({super.key, required this.pet});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('MMM d, yyyy').format(pet.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LostFoundPetDetailScreen(petId: pet.id!),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: pet.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.pets),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: pet.status == 'lost'
                                ? Colors.red.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            pet.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: pet.status == 'lost'
                                  ? Colors.red.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pet.breed,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (pet.location.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              pet.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
