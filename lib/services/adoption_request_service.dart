import 'local_storage_service.dart';
import 'notification_service.dart';

class AdoptionRequestService {
  final LocalStorageService _storage = LocalStorageService();

  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
  }

  Future<List<Map<String, dynamic>>> getAllRequests() async {
    return await _storage.getAdoptionRequests();
  }

  Future<List<Map<String, dynamic>>> getRequestsForOwner(String ownerId) async {
    final requests = await _storage.getAdoptionRequests();
    return requests.where((r) => r['ownerId'] == ownerId).toList();
  }

  Future<List<Map<String, dynamic>>> getRequestsByUser(String userId) async {
    final requests = await _storage.getAdoptionRequests();
    return requests.where((r) => r['requesterId'] == userId).toList();
  }

  Future<Map<String, dynamic>> submitRequest({
    required String requesterId,
    required String requesterName,
    required String requesterEmail,
    required String ownerId,
    required String petId,
    required String petName,
    required String name,
    required String age,
    required String email,
    required String contact,
    required String address,
    required String householdType,
    required String bringHome,
    required String reason,
  }) async {
    try {
      final requestId = _generateRequestId();
      final now = DateTime.now();

      final newRequest = {
        'id': requestId,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'requesterEmail': requesterEmail,
        'ownerId': ownerId,
        'petId': petId,
        'petName': petName,
        'name': name,
        'age': age,
        'email': email,
        'contact': contact,
        'address': address,
        'householdType': householdType,
        'bringHome': bringHome,
        'reason': reason,
        'status': 'Pending',
        'createdAt': now.toIso8601String(),
      };

      final requests = await _storage.getAdoptionRequests();
      requests.add(newRequest);
      await _storage.saveAdoptionRequests(requests);

      NotificationService.showAdoptionNotification(
        petName: petName,
        adopterName: requesterName,
      );

      return {'success': true, 'message': 'Adoption request submitted'};
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit request: $e'};
    }
  }

  Future<Map<String, dynamic>> updateRequestStatus({
    required String requestId,
    required String status,
  }) async {
    try {
      final requests = await _storage.getAdoptionRequests();
      final index = requests.indexWhere((r) => r['id'] == requestId);
      if (index == -1) {
        return {'success': false, 'message': 'Request not found'};
      }

      requests[index]['status'] = status;
      await _storage.saveAdoptionRequests(requests);
      return {'success': true, 'message': 'Request $status'};
    } catch (e) {
      return {'success': false, 'message': 'Update failed: $e'};
    }
  }

  Future<Map<String, dynamic>> deleteRequest(String requestId) async {
    try {
      final requests = await _storage.getAdoptionRequests();
      requests.removeWhere((r) => r['id'] == requestId);
      await _storage.saveAdoptionRequests(requests);
      return {'success': true, 'message': 'Request deleted'};
    } catch (e) {
      return {'success': false, 'message': 'Delete failed: $e'};
    }
  }
}