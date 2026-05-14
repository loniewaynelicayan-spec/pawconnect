import 'local_storage_service.dart';
import '../models/pet.dart';

const String _defaultPetImage = 'assets/images/Gohan.jpg';

class PetStorageService {
  final LocalStorageService _storage = LocalStorageService();

  String _generatePetId() {
    return 'pet_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Future<List<Map<String, dynamic>>> getAllPets() async {
    return await _storage.getPets();
  }

  Future<List<Map<String, dynamic>>> getUserPets(String userId) async {
    final pets = await _storage.getPets();
    return pets.where((p) => p['ownerId'] == userId).toList();
  }

  Future<Map<String, dynamic>> addPet({
    required String ownerId,
    required String ownerName,
    required String name,
    required String breed,
    required String category,
    String? age,
    String? gender,
    String? description,
    String? location,
    String image = _defaultPetImage,
  }) async {
    try {
      final petId = _generatePetId();
      final now = DateTime.now();
      final newPet = {
        'id': petId,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'name': name,
        'breed': breed,
        'category': category,
        'age': age,
        'gender': gender,
        'description': description,
        'location': location,
        'image': image,
        'createdAt': now.toIso8601String(),
        'status': 'Available',
      };

      final pets = await _storage.getPets();
      pets.add(newPet);
      await _storage.savePets(pets);

      return {
        'success': true,
        'message': 'Pet listed successfully',
        'pet': newPet,
      };
    } catch (e) {
      return {'success': false, 'message': 'Failed to add pet: $e'};
    }
  }

  Future<Map<String, dynamic>> updatePet({
    required String petId,
    required String ownerId,
    String? name,
    String? breed,
    String? category,
    String? age,
    String? gender,
    String? description,
    String? status,
  }) async {
    try {
      final pets = await _storage.getPets();
      final index = pets.indexWhere((p) => p['id'] == petId);
      if (index == -1) {
        return {'success': false, 'message': 'Pet not found'};
      }
      final pet = pets[index];
      if (pet['ownerId'] != ownerId) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      if (name != null) pet['name'] = name;
      if (breed != null) pet['breed'] = breed;
      if (category != null) pet['category'] = category;
      if (age != null) pet['age'] = age;
      if (gender != null) pet['gender'] = gender;
      if (description != null) pet['description'] = description;
      if (status != null) pet['status'] = status;
      pet['updatedAt'] = DateTime.now().toIso8601String();

      pets[index] = pet;
      await _storage.savePets(pets);
      return {'success': true, 'message': 'Pet updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }

  Future<Map<String, dynamic>> transferPetOwnership({
    required String petId,
    required String currentOwnerId,
    required String newOwnerId,
    required String newOwnerName,
  }) async {
    try {
      final pets = await _storage.getPets();
      final index = pets.indexWhere((p) => p['id'] == petId);
      if (index == -1) {
        return {'success': false, 'message': 'Pet not found'};
      }
      final pet = pets[index];
      if (pet['ownerId'] != currentOwnerId) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      pet['ownerId'] = newOwnerId;
      pet['ownerName'] = newOwnerName;
      pet['status'] = 'Adopted';
      pet['updatedAt'] = DateTime.now().toIso8601String();

      pets[index] = pet;
      await _storage.savePets(pets);
      return {'success': true, 'message': 'Pet ownership transferred successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Transfer failed: $e'};
    }
  }

  Future<Map<String, dynamic>> deletePet({
    required String petId,
    required String ownerId,
  }) async {
    try {
      final pets = await _storage.getPets();
      final index = pets.indexWhere((p) => p['id'] == petId);
      if (index == -1) {
        return {'success': false, 'message': 'Pet not found'};
      }
      if (pets[index]['ownerId'] != ownerId) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      pets.removeAt(index);
      await _storage.savePets(pets);
      return {'success': true, 'message': 'Pet removed successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }

  Pet mapToPet(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] is String ? map['id'] as String : null,
      ownerId: map['ownerId'] is String ? map['ownerId'] as String : null,
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      age: map['age'],
      gender: map['gender'],
      image: map['image'] ?? _defaultPetImage,
      description: map['description'],
      category: map['category'],
      ownerName: map['ownerName'],
      location: map['location'],
      isAdopted: map['status'] == 'Adopted',
    );
  }
}