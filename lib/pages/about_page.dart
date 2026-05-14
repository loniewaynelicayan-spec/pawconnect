import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/colors.dart';
import 'terms_page.dart';
import 'privacy_page.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('About'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // App Logo and Name
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.pets, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'PawConnect',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Text(
              'Connecting pets with loving families',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: AppColors.darkText,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 40),

            // Features Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFeatureItem(
                      PhosphorIcons.pawPrint(),
                      'Browse available pets for adoption',
                    ),
                    _buildFeatureItem(
                      PhosphorIcons.heart(),
                      'Save your favorite pets',
                    ),
                    _buildFeatureItem(
                      PhosphorIcons.chatDots(),
                      'Direct messaging with pet owners',
                    ),
                    _buildFeatureItem(
                      PhosphorIcons.fileText(),
                      'Submit adoption requests',
                    ),
                    _buildFeatureItem(
                      PhosphorIcons.house(),
                      'List your own pets for adoption',
                    ),
                    _buildFeatureItem(
                      PhosphorIcons.magnifyingGlass(),
                      'Advanced search filters',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Contact Information Card
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contact Us',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildContactItem(
                      context,
                      PhosphorIcons.phoneCall(),
                      '09151384817',
                      true,
                    ),
                    const SizedBox(height: 12),
                    _buildContactItem(
                      context,
                      PhosphorIcons.mapPin(),
                      'St. Jude Acres, Bulacao, Cebu',
                      false,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Legal Links
            Card(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildLegalLink('Terms of Service', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TermsPage()),
                      );
                    }),
                    const Divider(),
                    _buildLegalLink('Privacy Policy', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPage()),
                      );
                    }),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Made with ',
                  style: TextStyle(fontSize: 16, color: AppColors.darkText),
                ),
                Icon(PhosphorIcons.heart(), size: 18, color: Colors.red),
                const Text(
                  ' for pet lovers',
                  style: TextStyle(fontSize: 16, color: AppColors.darkText),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              '© 2024 PawConnect. All rights reserved.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, IconData icon, String text, bool isClickable) {
    final Widget row = Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: AppColors.darkText),
          ),
        ),
      ],
    );

    if (isClickable) {
      return InkWell(
        onTap: () => _launchUrl(context, 'tel:$text'),
        child: row,
      );
    }
    return row;
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Widget _buildLegalLink(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }
}
