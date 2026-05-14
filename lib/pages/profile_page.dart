import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../models/user.dart' as app_user;
import '../services/auth_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import 'chat_list_page.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  app_user.User? _user;
  bool isLoading = true;
  bool isEditing = false;
  bool _isSaving = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final userData = await _authService.getCurrentUser();
    setState(() {
      _user = userData;
      nameController.text = userData?.name ?? '';
      phoneController.text = userData?.phone ?? '';
      addressController.text = userData?.address ?? '';
      isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUpdate() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();

    if (name.isEmpty) {
      _showErrorDialog('Name is required');
      return;
    }
    if (phone.isNotEmpty && !RegExp(r'^\+?[0-9]{7,15}$').hasMatch(phone)) {
      _showErrorDialog('Please enter a valid phone number');
      return;
    }
    if (_user == null) {
      _showErrorDialog('No user data found');
      return;
    }

    setState(() => _isSaving = true);

    final result = await _authService.updateUser(
      userId: _user!.id,
      name: name,
      phone: phone.isEmpty ? null : phone,
      address: address.isEmpty ? null : address,
    );

    setState(() {
      _isSaving = false;
      isEditing = false;
    });

    if (result['success']) {
      _showSuccessDialog('Profile updated successfully');
      await _loadUserData();
    } else {
      _showErrorDialog(result['message'] ?? 'Update failed');
    }
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isLoading = true);
              final result = await _authService.deleteAccount(_user!.id);
              setState(() => isLoading = false);
              if (result['success']) {
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              } else {
                if (mounted) {
                  _showErrorDialog(result['message'] ?? 'Delete failed');
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout from this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (shouldLogout != true) return;
    await _authService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && _user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (!isLoading && _user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person_off, size: 56, color: Colors.grey),
                const SizedBox(height: 12),
                const Text(
                  'No profile found. Please login again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                CustomButton(text: 'Go to Login', onPressed: _handleLogout),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() => isEditing = true);
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: AppColors.primary,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: LinearProgressIndicator(color: AppColors.primary),
              ),
            const SizedBox(height: 20),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _user?.name ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _user?.email ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            if (isEditing) ...[
              CustomTextField(controller: nameController, hintText: 'Name'),
              const SizedBox(height: 16),
              CustomTextField(
                controller: phoneController,
                hintText: 'Phone (optional)',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: addressController,
                hintText: 'Address (optional)',
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: _isSaving
                          ? () {}
                          : () {
                              setState(() {
                                isEditing = false;
                                nameController.text = _user?.name ?? '';
                                phoneController.text = _user?.phone ?? '';
                                addressController.text = _user?.address ?? '';
                              });
                            },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomButton(
                      text: _isSaving ? 'Saving...' : 'Save',
                      onPressed: _isSaving ? () {} : _handleUpdate,
                    ),
                  ),
                ],
              ),
            ] else ...[
              _buildProfileItem('Phone', _user?.phone ?? 'Not set'),
              _buildProfileItem('Address', _user?.address ?? 'Not set'),
              _buildProfileItem(
                'Member Since',
                '${_user?.createdAt.day}/${_user?.createdAt.month}/${_user?.createdAt.year}',
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Messages',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: _isSaving ? 'Please wait...' : 'Logout',
                onPressed: _isSaving ? () {} : _handleLogout,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _isSaving ? null : _handleDelete,
                child: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: AppColors.darkText),
          ),
        ],
      ),
    );
  }
}
