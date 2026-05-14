import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static const String _usersKey = 'users';
  static const String _currentUserIdKey = 'current_user_id';
  static const String _petsKey = 'pets';
  static const String _messagesKey = 'messages';
  static const String _adoptionRequestsKey = 'adoption_requests';
  static const String _favoritesPrefix = 'favorites_';

  Future<List<Map<String, dynamic>>> getUsers() async {
    final p = await prefs;
    final data = p.getString(_usersKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> saveUsers(List<Map<String, dynamic>> users) async {
    final p = await prefs;
    await p.setString(_usersKey, jsonEncode(users));
  }

  Future<void> setCurrentUserId(String? userId) async {
    final p = await prefs;
    if (userId == null) {
      await p.remove(_currentUserIdKey);
    } else {
      await p.setString(_currentUserIdKey, userId);
    }
  }

  Future<String?> getCurrentUserId() async {
    final p = await prefs;
    return p.getString(_currentUserIdKey);
  }

  Future<List<Map<String, dynamic>>> getPets() async {
    final p = await prefs;
    final data = p.getString(_petsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> savePets(List<Map<String, dynamic>> pets) async {
    final p = await prefs;
    await p.setString(_petsKey, jsonEncode(pets));
  }

  Future<List<Map<String, dynamic>>> getMessages() async {
    final p = await prefs;
    final data = p.getString(_messagesKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> saveMessages(List<Map<String, dynamic>> messages) async {
    final p = await prefs;
    await p.setString(_messagesKey, jsonEncode(messages));
  }

  Future<List<Map<String, dynamic>>> getAdoptionRequests() async {
    final p = await prefs;
    final data = p.getString(_adoptionRequestsKey);
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> saveAdoptionRequests(List<Map<String, dynamic>> requests) async {
    final p = await prefs;
    await p.setString(_adoptionRequestsKey, jsonEncode(requests));
  }

  Future<List<Map<String, dynamic>>> getFavorites(String userId) async {
    final p = await prefs;
    final data = p.getString('$_favoritesPrefix$userId');
    if (data == null) return [];
    final list = jsonDecode(data) as List;
    return list.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<void> saveFavorites(String userId, List<Map<String, dynamic>> favorites) async {
    final p = await prefs;
    await p.setString('$_favoritesPrefix$userId', jsonEncode(favorites));
  }

  Future<void> clearAll() async {
    final p = await prefs;
    await p.clear();
  }
}