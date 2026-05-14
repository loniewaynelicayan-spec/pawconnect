import 'package:flutter/material.dart';
import '../constants/colors.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
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

            _section('1. Acceptance of Terms',
              'By accessing or using PawConnect ("the App"), you agree to be bound by these Terms of Service. '
              'If you do not agree, do not use the App.'),
            _section('2. Description of Service',
              'PawConnect is a platform that connects pet owners with potential adopters. '
              'The App facilitates pet listings, adoption requests, and communication between users.'),
            _section('3. User Responsibilities',
              'You agree to provide accurate information when creating an account or listing a pet. '
              'You are solely responsible for the accuracy of your listings and communications. '
              'You must not use the App for any unlawful purpose.'),
            _section('4. Adoption Process',
              'PawConnect facilitates connections between pet owners and adopters but does not '
              'guarantee adoption outcomes. All adoption decisions are solely between the pet owner '
              'and the adopter. You are encouraged to verify all information independently.'),
            _section('5. Limitation of Liability',
              'PawConnect is provided "as is" without warranties of any kind. We are not liable for '
              'any damages arising from your use of the App, including failed adoptions, '
              'miscommunication, or disputes between users.'),
            _section('6. Termination',
              'We reserve the right to suspend or terminate your account at any time for violating '
              'these terms or for any other reason.'),
            _section('7. Changes to Terms',
              'We may update these terms at any time. Continued use of the App after changes '
              'constitutes acceptance of the new terms.'),
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
