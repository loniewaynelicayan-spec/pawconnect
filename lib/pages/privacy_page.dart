import 'package:flutter/material.dart';
import '../constants/colors.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Last updated: May 2026',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _section('1. Information We Collect',
              'We collect information you provide when creating an account, such as your name, '
              'email address, and contact details. When you list a pet, we collect information '
              'about the pet including photos and descriptions.'),
            _section('2. How We Use Your Information',
              'Your information is used to operate and improve the App, facilitate adoptions, '
              'enable communication between users, and send notifications related to your activity.'),
            _section('3. Information Sharing',
              'We do not sell your personal information. Your profile details and contact '
              'information are shared with other users only as necessary for the adoption process.'),
            _section('4. Data Storage',
              'All data is stored locally on your device using SharedPreferences. We do not '
              'maintain external servers or cloud storage. You are responsible for backing up your data.'),
            _section('5. Photos and Images',
              'Photos you upload are stored locally on your device as base64-encoded data. '
              'These images are shared with other users of the App for adoption purposes.'),
            _section('6. Third-Party Services',
              'The App may use third-party libraries and services which have their own privacy policies. '
              'These include Flutter SDK packages and their respective data handling practices.'),
            _section('7. Your Rights',
              'You can access, update, or delete your account and associated data at any time '
              'through the Profile page. Deleting your account removes your data from the App.'),
            _section('8. Changes to This Policy',
              'We may update this Privacy Policy. Changes will be reflected in the App.'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.5),
          ),
        ],
      ),
    );
  }
}
