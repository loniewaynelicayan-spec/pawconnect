import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/styles.dart';
import '../models/pet.dart';
import '../widgets/custom_button.dart';
import 'pet_detail_page.dart';
import 'settings_page.dart';

class AdoptCompanionPage extends StatefulWidget {
  const AdoptCompanionPage({super.key});

  @override
  State<AdoptCompanionPage> createState() => _AdoptCompanionPageState();
}

class _AdoptCompanionPageState extends State<AdoptCompanionPage> {
  int currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Pet> pets = [
    Pet(
      name: 'Muffy',
      breed: 'Pug',
      age: '2 years',
      gender: 'Male',
      image: 'assets/images/Muffy.jpg',
      description: 'A friendly and playful companion',
    ),
    Pet(
      name: 'Galaxy Destroyer',
      breed: 'Persian Cat',
      age: '1 year',
      gender: 'Female',
      image: 'assets/images/galaxy_destroyer.webp',
      description: 'A calm and affectionate friend',
    ),
    Pet(
      name: 'Gohan',
      breed: 'Shih Tzu',
      age: '3 years',
      gender: 'Male',
      image: 'assets/images/Gohan.jpg',
      description: 'An sensitive and loyal companion',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: 20.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Heading
            const Text(
              'Adopt a Furever\nCompanion',
              textAlign: TextAlign.center,
              style: AppStyles.heading2,
            ),
            const SizedBox(height: 24),
            // Pet card carousel
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
              ),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
                itemCount: pets.length,
                itemBuilder: (context, index) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.grey[300],
                      image: DecorationImage(
                        image: AssetImage(pets[index].image),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: pets[index].image.isEmpty
                        ? Center(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.pets,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          )
                        : null,
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            // Dots indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pets.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: currentIndex == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: currentIndex == index
                        ? AppColors.primary
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Pet details
            Column(
              children: [
                Text(
                  pets[currentIndex].name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  pets[currentIndex].breed,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                Text(
                  pets[currentIndex].description ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.darkText,
                    height: 1.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      if (currentIndex < pets.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _pageController.animateToPage(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Icon(Icons.close, color: AppColors.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Adopt',
                    onPressed: () {
                      final pet = pets[currentIndex];
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PetDetailPage(
                            name: pet.name,
                            breed: pet.breed,
                            age: pet.age ?? 'Unknown',
                            gender: pet.gender ?? 'Unknown',
                            image: pet.image,
                            description: pet.description ?? '',
                            showAdoptionFormOnOpen: true,
                            isAdopted: pet.isAdopted ?? false,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
