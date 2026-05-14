import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../constants/colors.dart';
import '../services/pet_storage_service.dart';
import '../services/auth_service.dart';
import '../models/user.dart' as app_user;
import '../models/pet.dart';
import 'pet_detail_page.dart';
import 'add_pet_page.dart';
import 'adoption_requests_page.dart';

class MyPetsPage extends StatefulWidget {
  const MyPetsPage({super.key});

  @override
  State<MyPetsPage> createState() => _MyPetsPageState();
}

class _MyPetsPageState extends State<MyPetsPage> {
  final _petStorageService = PetStorageService();
  final _authService = AuthService();
  List<Map<String, dynamic>> _myPets = [];
  bool isLoading = true;
  app_user.User? _currentUser;

  @override
  void initState() {
    super.initState();
    _loadMyPets();
  }

  Future<void> _loadMyPets() async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    _currentUser = user;
    final pets = await _petStorageService.getUserPets(user.id);

    setState(() {
      _myPets = pets;
      isLoading = false;
    });
  }

  Future<void> _deletePet(String? petId) async {
    if (petId == null || petId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid pet ID')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Pet'),
        content: const Text(
          'Are you sure you want to remove this pet listing?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true || _currentUser == null) return;

    setState(() => isLoading = true);
    final result = await _petStorageService.deletePet(
      petId: petId,
      ownerId: _currentUser!.id,
    );
    setState(() => isLoading = false);

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Pet removed')));
      }
      await _loadMyPets();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to remove pet')),
        );
      }
    }
  }

  Pet _mapToPet(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] is String ? map['id'] as String : null,
      ownerId: map['ownerId'] is String ? map['ownerId'] as String : null,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'],
      gender: map['gender'],
      image: map['image'] ?? 'assets/images/Gohan.jpg',
      description: map['description'],
      category: map['category'],
      ownerName: map['ownerName'],
      location: map['location'],
      isAdopted: map['status'] == 'Adopted',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('My Pet Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mail_outline),
            tooltip: 'Adoption Requests',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AdoptionRequestsPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPetPage()),
              );
              _loadMyPets();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _myPets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No pets listed yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tap + to list your pet for adoption',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddPetPage(),
                        ),
                      );
                      _loadMyPets();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('List a Pet'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadMyPets,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _myPets.length,
                itemBuilder: (context, index) {
                  final pet = _myPets[index];
                  return _buildPetCard(pet);
                },
              ),
            ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    final petModel = _mapToPet(pet);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetDetailPage(
                petId: petModel.id,
                ownerId: petModel.ownerId,
                name: petModel.name,
                breed: petModel.breed,
                age: petModel.age ?? 'Unknown',
                gender: petModel.gender ?? 'Unknown',
                image: petModel.image,
                description:
                    petModel.description ??
                    'Friendly pet looking for a loving and responsible home.',
                ownerName:
                    petModel.ownerName ??
                    (_currentUser?.name ?? 'Foster Owner'),
                location: petModel.location ?? 'Cebu City',
                isAdopted: petModel.isAdopted ?? false,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Pet Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[300],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _buildPetImage(petModel.image),
                ),
              ),
              const SizedBox(width: 16),
              // Pet Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet['breed']} • ${pet['category']}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: pet['status'] == 'Available'
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        pet['status'] ?? 'Available',
                        style: TextStyle(
                          fontSize: 11,
                          color: pet['status'] == 'Available'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary),
                    onPressed: () {
                      // TODO: Implement edit
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit coming soon')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deletePet(pet['id']),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetImage(String image) {
    if (image.isNotEmpty && image.startsWith('assets/')) {
      return Image.asset(
        image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    if (image.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(image);
        return Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        );
      } catch (_) {}
    }
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(Icons.pets, color: Colors.white),
    );
  }
}
