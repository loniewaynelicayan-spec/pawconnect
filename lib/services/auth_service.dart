import 'local_storage_service.dart';
import '../models/user.dart' as app_user;

class AuthService {
  final LocalStorageService _storage = LocalStorageService();

  String _generateUserId() {
    return 'user_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  DateTime _parseDateTime(dynamic value) {
    if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }
      if (password.length < 8) {
        return {'success': false, 'message': 'Password must be at least 8 characters'};
      }

      final users = await _storage.getUsers();
      final existingUser = users.any((u) => u['email'] == email);
      if (existingUser) {
        return {'success': false, 'message': 'Email already registered'};
      }

      final userId = _generateUserId();
      final now = DateTime.now();
      final newUser = app_user.User(
        id: userId,
        email: email,
        name: name,
        createdAt: now,
      );

      final userData = {
        'id': userId,
        'email': email,
        'name': name,
        'password': password,
        'createdAt': now.toIso8601String(),
      };

      users.add(userData);
      await _storage.saveUsers(users);
      await _storage.setCurrentUserId(userId);

      return {'success': true, 'message': 'Account created successfully', 'user': newUser};
    } catch (e) {
      return {'success': false, 'message': 'Registration failed: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email and password required'};
      }

      final users = await _storage.getUsers();
      final userMap = users.firstWhere(
        (u) => u['email'] == email && u['password'] == password,
        orElse: () => <String, dynamic>{},
      );

      if (userMap.isEmpty) {
        return {'success': false, 'message': 'Invalid email or password'};
      }

      final user = app_user.User(
        id: userMap['id'] as String,
        email: userMap['email'] as String,
        name: userMap['name'] as String,
        phone: userMap['phone'] as String?,
        address: userMap['address'] as String?,
        createdAt: _parseDateTime(userMap['createdAt']),
      );

      await _storage.setCurrentUserId(user.id);

      return {'success': true, 'message': 'Login successful', 'user': user};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  Future<app_user.User?> getUserData(String userId) async {
    try {
      final users = await _storage.getUsers();
      final userMap = users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );
      if (userMap.isEmpty) return null;

      return app_user.User(
        id: userMap['id'] as String,
        email: userMap['email'] as String? ?? '',
        name: userMap['name'] as String? ?? '',
        phone: userMap['phone'] as String?,
        address: userMap['address'] as String?,
        createdAt: _parseDateTime(userMap['createdAt']),
      );
    } catch (_) {
      return null;
    }
  }

  Future<app_user.User?> getCurrentUser() async {
    final userId = await _storage.getCurrentUserId();
    if (userId == null) return null;
    return getUserData(userId);
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String name,
    String? phone,
    String? address,
  }) async {
    try {
      final users = await _storage.getUsers();
      final index = users.indexWhere((u) => u['id'] == userId);
      if (index == -1) {
        return {'success': false, 'message': 'User not found'};
      }

      users[index]['name'] = name;
      if (phone != null) users[index]['phone'] = phone;
      if (address != null) users[index]['address'] = address;
      users[index]['updatedAt'] = DateTime.now().toIso8601String();

      await _storage.saveUsers(users);
      return {'success': true, 'message': 'Profile updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteAccount(String userId) async {
    try {
      final users = await _storage.getUsers();
      users.removeWhere((u) => u['id'] == userId);
      await _storage.saveUsers(users);
      await _storage.setCurrentUserId(null);
      return {'success': true, 'message': 'Account deleted successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }

  Future<void> logout() async {
    await _storage.setCurrentUserId(null);
  }

  Future<bool> isLoggedIn() async {
    final userId = await _storage.getCurrentUserId();
    return userId != null;
  }

  Future<Map<String, dynamic>?> getUserDataByEmail(String email) async {
    try {
      final users = await _storage.getUsers();
      final userMap = users.firstWhere(
        (u) => u['email'] == email,
        orElse: () => <String, dynamic>{},
      );
      return userMap.isEmpty ? null : userMap;
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final users = await _storage.getUsers();
      final index = users.indexWhere((u) => u['email'] == email);
      if (index == -1) {
        return {'success': false, 'message': 'No account found with this email'};
      }
      return {'success': true, 'message': 'Password reset functionality not available in local mode. Please contact support.'};
    } catch (e) {
      return {'success': false, 'message': 'Reset failed: $e'};
    }
  }
}