import 'local_storage_service.dart';
import '../models/pet.dart';

class FavoritesService {
  static final FavoritesService _instance = FavoritesService._internal();
  factory FavoritesService() => _instance;
  FavoritesService._internal();

  final LocalStorageService _storage = LocalStorageService();

  List<Pet> _favorites = [];
  bool _loaded = false;

  List<Pet> get favorites => List.unmodifiable(_favorites);

  Future<String?> get _currentUserId async {
    return await _storage.getCurrentUserId();
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    await _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final userId = await _currentUserId;
    if (userId == null) {
      _favorites = [];
      _loaded = true;
      return;
    }

    final favoritesData = await _storage.getFavorites(userId);
    _favorites = favoritesData.map((data) {
      return Pet(
        id: data['id'],
        ownerId: data['ownerId'],
        name: data['name'] ?? '',
        breed: data['breed'] ?? '',
        age: data['age'],
        gender: data['gender'],
        image: data['image'] ?? 'assets/images/Gohan.jpg',
        description: data['description'],
        category: data['category'],
        ownerName: data['ownerName'],
        location: data['location'],
        isAdopted: data['isAdopted'] ?? false,
      );
    }).toList();
    _loaded = true;
  }

  Future<void> _saveFavorites() async {
    final userId = await _currentUserId;
    if (userId == null) return;

    final favoritesData = _favorites.map((pet) => {
      'id': pet.id,
      'ownerId': pet.ownerId,
      'name': pet.name,
      'breed': pet.breed,
      'age': pet.age,
      'gender': pet.gender,
      'image': pet.image,
      'description': pet.description,
      'category': pet.category,
      'ownerName': pet.ownerName,
      'location': pet.location,
      'isAdopted': pet.isAdopted,
    }).toList();

    await _storage.saveFavorites(userId, favoritesData);
  }

  Future<bool> isFavorite(Pet pet) async {
    await _ensureLoaded();
    return _favorites.any(
      (fav) => (fav.id != null && pet.id != null)
          ? fav.id == pet.id
          : (fav.name == pet.name && fav.breed == pet.breed),
    );
  }

  Future<void> toggleFavorite(Pet pet) async {
    await _ensureLoaded();
    if (_favorites.any((fav) =>
        (fav.id != null && pet.id != null)
            ? fav.id == pet.id
            : (fav.name == pet.name && fav.breed == pet.breed))) {
      _favorites.removeWhere((fav) =>
          (fav.id != null && pet.id != null)
              ? fav.id == pet.id
              : (fav.name == pet.name && fav.breed == pet.breed));
    } else {
      _favorites.add(pet);
    }
    await _saveFavorites();
  }

  Future<void> refresh() async {
    _loaded = false;
    await _ensureLoaded();
  }
}