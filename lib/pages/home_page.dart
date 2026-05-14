import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../constants/colors.dart';
import '../models/pet.dart';
import '../services/pet_storage_service.dart';
import 'pet_list_page.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import 'all_pets_page.dart';
import 'favorites_page.dart';
import 'profile_page.dart';
import 'my_pets_page.dart';
import 'settings_page.dart';
import 'about_page.dart';
import 'chat_list_page.dart';
import 'pet_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedCategory = 0;
  int selectedNavIndex = 0;
  final TextEditingController searchController = TextEditingController();
  final PetStorageService _petStorageService = PetStorageService();
  List<Pet> _userPets = [];
  List<Pet> _filteredPets = [];
  bool _isSearching = false;

  // Add featured pets at the beginning
  final List<Pet> _featuredPets = [
    Pet(
      id: 'featured_1',
      name: 'Muffy',
      category: 'Dog',
      breed: 'Dragon',
      age: '4 years',
      gender: 'Male',
      description:
          'A powerful and loyal companion with a heart of gold. Perfect for families. Known for his fierce loyalty and gentle nature with children.',
      image: 'assets/images/Muffy.jpg',
      isAdopted: false,
      ownerName: 'Dragon Master',
      contactInfo: 'dragonmaster@pawconnect.com',
      location: 'Dragon Temple',
    ),
    Pet(
      id: 'featured_2',
      name: 'Galaxy Destroyer',
      category: 'Cat',
      breed: 'Space',
      age: '2 years',
      gender: 'Female',
      description:
          'A mysterious and agile feline with cosmic powers. Loves to explore and nap in sunbeams. Known for her stellar speed and ability to navigate through asteroid fields.',
      image: 'assets/images/galaxy_destroyer.webp',
      isAdopted: false,
      ownerName: 'Space Explorer',
      contactInfo: 'galaxy@pawconnect.com',
      location: 'Space Station',
    ),
  ];

  final List<String> categories = [
    'Featured',
    'All',
    'Dog',
    'Cat',
    'Bird',
    'Rabbit',
  ];
  final List<IconData> categoryIcons = [
    PhosphorIcons.star(),
    PhosphorIcons.pawPrint(),
    PhosphorIcons.dog(),
    PhosphorIcons.cat(),
    PhosphorIcons.bird(),
    PhosphorIcons.rabbit(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserPets();
    _filteredPets = [];
    searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadUserPets() async {
    final allPets = await _petStorageService.getAllPets();
    setState(() {
      _userPets = allPets.map((p) => _petStorageService.mapToPet(p)).toList();
      _filteredPets = [..._userPets, ..._featuredPets];
    });
  }

  void _onSearchChanged() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _isSearching = false;
        _filteredPets = [..._userPets, ..._featuredPets];
      } else {
        _isSearching = true;
        _filteredPets = [..._userPets, ..._featuredPets].where((pet) {
          return pet.name.toLowerCase().contains(query) ||
              pet.breed.toLowerCase().contains(query) ||
              (pet.category?.toLowerCase().contains(query) ?? false);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChatListPage()),
              );
            },
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.primary),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.pets, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'PawConnect',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home, color: AppColors.primary),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pets, color: AppColors.primary),
              title: const Text('All Pets'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllPetsPage(category: 'All'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: AppColors.primary),
              title: const Text('Favorites'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppColors.primary),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_circle, color: AppColors.primary),
              title: const Text('List My Pet'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPetsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.primary),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.primary),
              title: const Text('About'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AboutPage()),
                );
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start your Journey with a Loving Pet',
              style: const TextStyle(fontSize: 25, color: AppColors.darkText),
            ),
            const SizedBox(height: 16),
            // List Your Pet Button
            InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyPetsPage()),
                );
                _loadUserPets();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_circle, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'List Your Pet for Adoption',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Categories
            const Text(
              'Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  categories.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllPetsPage(
                              category: categories[index] == "Featured"
                                  ? "All"
                                  : categories[index],
                            ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: selectedCategory == index
                                  ? AppColors.primary
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: selectedCategory == index
                                  ? null
                                  : Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                            ),
                            child: Center(
                              child: Icon(
                                categoryIcons[index],
                                size: 28,
                                color: selectedCategory == index
                                    ? Colors.white
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            categories[index],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: selectedCategory == index
                                  ? AppColors.primary
                                  : AppColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Search Bar
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search pets by name or breed...',
                hintStyle: const TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Listings
            Text(
              _isSearching ? 'Search Results' : 'Pet Listings',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 16),
            _filteredPets.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    alignment: Alignment.center,
                    child: const Text(
                      'No pets found',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        _filteredPets.length,
                        (index) => Padding(
                          padding: const EdgeInsets.only(right: 12.0),
                          child: _buildPetCard(_filteredPets[index]),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 32),
            // Featured Pets Section
            _buildFeaturedPetsSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        selectedIndex: selectedNavIndex,
        onTap: (index) {
          if (index == 1) {
            // Navigate to All Pets page
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllPetsPage(category: 'All'),
              ),
            );
          } else if (index == 2) {
            // Navigate to Favorites page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FavoritesPage()),
            );
          } else if (index == 3) {
            // Navigate to Profile page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfilePage()),
            );
          } else {
            // Home page - already here
            setState(() {
              selectedNavIndex = index;
            });
          }
        },
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailPage(
              petId: pet.id,
              ownerId: pet.ownerId,
              name: pet.name,
              breed: pet.breed,
              age: pet.age ?? 'Unknown',
              gender: pet.gender ?? 'Unknown',
              image: pet.image,
              description:
                  pet.description ??
                  'Friendly pet looking for a loving and responsible home.',
              ownerName: pet.ownerName ?? 'Foster Owner',
              location: pet.location ?? 'Cebu City',
              isAdopted: pet.isAdopted ?? false,
            ),
          ),
        );
      },
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: _buildPetImage(pet.image),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.breed,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.darkText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.age ?? 'Unknown',
                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedPetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Pets',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.darkText,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PetListPage(
                      pets: _featuredPets,
                      category: 'Featured',
                      categoryIcon: PhosphorIcons.star(),
                    ),
                  ),
                );
              },
              child: const Text(
                'See all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _featuredPets.map((pet) {
              return Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: _buildFeaturedPetCard(pet),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailPage(
              petId: pet.id,
              ownerId: pet.ownerId,
              name: pet.name,
              breed: pet.breed,
              age: pet.age ?? 'Unknown',
              gender: pet.gender ?? 'Unknown',
              image: pet.image,
              description:
                  pet.description ??
                  'Friendly pet looking for a loving and responsible home.',
              ownerName: pet.ownerName ?? 'Foster Owner',
              location: pet.location ?? 'Cebu City',
              isAdopted: pet.isAdopted ?? false,
            ),
          ),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.primary.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Image
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                    ),
                    color: Colors.grey[300],
                  ),
                  child: _buildPetImage(pet.image),
                ),
                // Pet Details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              pet.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: (pet.isAdopted ?? false)
                                  ? Colors.grey
                                  : Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (pet.isAdopted ?? false)
                                  ? 'Adopted'
                                  : 'Available',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${pet.breed} • ${pet.gender} • ${pet.age}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet.description ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.darkText,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            pet.location ?? 'Unknown Location',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Featured Badge
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Featured',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetImage(String image) {
    if (image.isNotEmpty && image.startsWith('assets/')) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        child: Image.asset(
          image,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    if (image.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(image);
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(14),
            topRight: Radius.circular(14),
          ),
          child: Image.memory(
            bytes,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        );
      } catch (_) {}
    }
    return Center(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(6),
        ),
        child: const Icon(Icons.pets, color: Colors.white, size: 40),
      ),
    );
  }
}
