import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../services/adoption_request_service.dart';
import '../services/auth_service.dart';
import '../services/pet_storage_service.dart';

class AdoptionRequestsPage extends StatefulWidget {
  const AdoptionRequestsPage({super.key});

  @override
  State<AdoptionRequestsPage> createState() => _AdoptionRequestsPageState();
}

class _AdoptionRequestsPageState extends State<AdoptionRequestsPage> {
  final AdoptionRequestService _adoptionService = AdoptionRequestService();
  final AuthService _authService = AuthService();
  final PetStorageService _petStorageService = PetStorageService();

  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    final user = await _authService.getCurrentUser();
    if (user != null) {
      final requests = await _adoptionService.getRequestsForOwner(user.id);
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _approveRequest(Map<String, dynamic> request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Ownership Transfer'),
        content: const Text(
          'Once accepted, this pet will be transferred to the adopter. They will gain full ownership and access to all adoption documents.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Accept',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final currentUser = await _authService.getCurrentUser();
    if (currentUser == null) return;

    final transferResult = await _petStorageService.transferPetOwnership(
      petId: request['petId'],
      currentOwnerId: currentUser.id,
      newOwnerId: request['requesterId'],
      newOwnerName: request['requesterName'],
    );

    if (transferResult['success']) {
      await _updateRequestStatus(request['id'], 'Approved');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pet transferred to adopter successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(transferResult['message'] ?? 'Transfer failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateRequestStatus(String requestId, String status) async {
    final result = await _adoptionService.updateRequestStatus(
      requestId: requestId,
      status: status,
    );

    if (result['success']) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request $status'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      await _loadRequests();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Update failed')),
        );
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;

    if (status == 'Pending') {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else if (status == 'Approved') {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
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
        title: const Text('Adoption Requests'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No adoption requests yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadRequests,
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _requests.length,
                itemBuilder: (context, index) {
                  final request = _requests[index];
                  final isPending = request['status'] == 'Pending';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request['petName'] ?? 'Unknown Pet',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'From: ${request['requesterName'] ?? 'Unknown'}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _buildStatusBadge(request['status'] ?? 'Pending'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Requester Details
                        _buildDetailRow(
                          'Email',
                          request['requesterEmail'] ?? 'N/A',
                        ),
                        _buildDetailRow('Contact', request['contact'] ?? 'N/A'),
                        _buildDetailRow('Address', request['address'] ?? 'N/A'),
                        _buildDetailRow(
                          'Household Type',
                          request['householdType'] ?? 'N/A',
                        ),
                        const SizedBox(height: 12),
                        // Reason
                        if (request['reason'] != null &&
                            (request['reason'] as String).isNotEmpty) ...[
                          const Text(
                            'Why they want to adopt:',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            request['reason'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.darkText,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        // Action Buttons
                        if (isPending) ...[
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _updateRequestStatus(
                                      request['id'],
                                      'Rejected',
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    _approveRequest(request);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Approve',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }
}
