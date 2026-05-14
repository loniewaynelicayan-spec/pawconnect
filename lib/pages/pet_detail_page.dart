import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../constants/colors.dart';
import '../models/pet.dart';
import '../services/favorites_service.dart';
import '../services/adoption_request_service.dart';
import '../services/auth_service.dart';
import 'chat_detail_page.dart';

class PetDetailPage extends StatefulWidget {
  final String? petId;
  final String? ownerId;
  final String name;
  final String breed;
  final String age;
  final String gender;
  final String image;
  final String location;
  final String description;
  final String ownerName;
  final bool showAdoptionFormOnOpen;
  final bool isAdopted;

  const PetDetailPage({
    super.key,
    this.petId,
    this.ownerId,
    required this.name,
    required this.breed,
    required this.age,
    required this.gender,
    required this.image,
    this.location = 'Cebu City',
    this.description =
        'Muffy is a lovable pug who enjoys playing and cuddling. She is well-trained, vaccinated, and looking for a forever home where she can share her affectionate personality.',
    this.ownerName = 'Ayem Lavon',
    this.showAdoptionFormOnOpen = false,
    this.isAdopted = false,
  });

  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetDetailPageState extends State<PetDetailPage> {
  final FavoritesService _favoritesService = FavoritesService();
  final AdoptionRequestService _adoptionService = AdoptionRequestService();
  final AuthService _authService = AuthService();

  String? _currentUserId;

  bool get _isOwner =>
      widget.ownerId != null &&
      widget.ownerId!.isNotEmpty &&
      widget.ownerId == _currentUserId;

  bool get _canAdopt => !_isOwner && !widget.isAdopted;

  // Modal state
  bool _showAdoptionForm = false;
  bool _showSuccessModal = false;

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _householdTypeController =
      TextEditingController();
  final TextEditingController _bringHomeController = TextEditingController();
  final TextEditingController _whyAdoptController = TextEditingController();

  // Form key
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isFavorite = false;

  Pet get _pet => Pet(
    id: widget.petId,
    ownerId: widget.ownerId,
    name: widget.name,
    breed: widget.breed,
    age: widget.age,
    gender: widget.gender,
    image: widget.image,
    description: widget.description,
    ownerName: widget.ownerName,
    location: widget.location,
  );

  Future<void> _loadFavoriteStatus() async {
    final fav = await _favoritesService.isFavorite(_pet);
    if (mounted) {
      setState(() {
        _isFavorite = fav;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
    _loadCurrentUser();
    if (widget.showAdoptionFormOnOpen) {
      _showAdoptionForm = true;
    }
  }

  Future<void> _loadCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (mounted) {
      setState(() {
        _currentUserId = user?.id;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    _householdTypeController.dispose();
    _bringHomeController.dispose();
    _whyAdoptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet Image
                SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: _buildPetImage(widget.image),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pet Name and Location
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.location,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              final wasFavorite = _isFavorite;
                              final messenger = ScaffoldMessenger.of(context);
                              await _favoritesService.toggleFavorite(_pet);
                              if (mounted) {
                                setState(() {
                                  _isFavorite = !wasFavorite;
                                });
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      !wasFavorite
                                          ? 'Added to favorites!'
                                          : 'Removed from favorites',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                _isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: _isFavorite
                                    ? Colors.red
                                    : AppColors.primary,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Pet Info Chips
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoChip('Gender', widget.gender),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: _buildInfoChip('Age', widget.age)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoChip('Breed', widget.breed),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      // Foster Owner Section
                      const Text(
                        'Foster Owner',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.ownerName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkText,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Foster Parent',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.message,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                if (widget.ownerId == null ||
                                    widget.ownerId!.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Unable to start chat for this listing',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatDetailPage(
                                      otherUserId: widget.ownerId ?? '',
                                      ownerName: widget.ownerName,
                                      petName: widget.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.call,
                                color: AppColors.primary,
                              ),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Call feature coming soon!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Description
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.description,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: AppColors.darkText,
                        ),
                      ),
                      const SizedBox(height: 40),
                      if (widget.isAdopted)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text(
                                'Already Adopted',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (_canAdopt)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _showAdoptionForm = true;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Adopt Now',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else if (_isOwner)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: const Center(
                            child: Text(
                              'This is your pet listing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Adoption Form Modal
          if (_showAdoptionForm && _canAdopt) _buildAdoptionFormModal(),
          // Success Modal
          if (_showSuccessModal) _buildSuccessModal(),
        ],
      ),
    );
  }

  Widget _buildAdoptionFormModal() {
    return SafeArea(
      child: Container(
        color: Colors.black54,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.82,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              _showAdoptionForm = false;
                            });
                          },
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Adoption Form',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  // Form Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTextField(
                              'Name',
                              'Enter name:',
                              _nameController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Age',
                              'Enter age:',
                              _ageController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Email',
                              'Enter email:',
                              _emailController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Contact #',
                              'Enter contact number:',
                              _contactController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              'Address',
                              'Enter address:',
                              _addressController,
                            ),
                            const SizedBox(height: 16),
                            _buildDropdownField(
                              'Household type',
                              _householdTypeController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextAreaField(
                              'Who will you bring home?',
                              'Write here:',
                              _bringHomeController,
                            ),
                            const SizedBox(height: 16),
                            _buildTextAreaField(
                              'Why do you want to adopt?',
                              'Write here:',
                              _whyAdoptController,
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    final currentUser = await _authService
                                        .getCurrentUser();
                                    final result = await _adoptionService
                                        .submitRequest(
                                          requesterId:
                                              currentUser?.id ?? 'guest',
                                          requesterName:
                                              currentUser?.name ??
                                              _nameController.text,
                                          requesterEmail:
                                              currentUser?.email ??
                                              _emailController.text,
                                          ownerId: widget.ownerId ?? 'unknown',
                                          petId: widget.petId ?? widget.name,
                                          petName: widget.name,
                                          name: _nameController.text,
                                          age: _ageController.text,
                                          email: _emailController.text,
                                          contact: _contactController.text,
                                          address: _addressController.text,
                                          householdType:
                                              _householdTypeController.text,
                                          bringHome: _bringHomeController.text,
                                          reason: _whyAdoptController.text,
                                        );

                                    if (result['success']) {
                                      setState(() {
                                        _showAdoptionForm = false;
                                        _showSuccessModal = true;
                                      });
                                    } else {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              result['message'] ??
                                                  'Failed to submit',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Submit Request',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessModal() {
    return SafeArea(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8CC),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _showSuccessModal = false;
                    });
                  },
                ),
                const SizedBox(height: 20),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 50),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Request Sent',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Select $label'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDropdownOption('Apartment', controller),
                    _buildDropdownOption('House', controller),
                    _buildDropdownOption('Condo', controller),
                    _buildDropdownOption('Villa', controller),
                  ],
                ),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  controller.text.isEmpty
                      ? 'Select household type'
                      : controller.text,
                  style: TextStyle(
                    color: controller.text.isEmpty ? Colors.grey : Colors.black,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownOption(String option, TextEditingController controller) {
    return ListTile(
      title: Text(option),
      onTap: () {
        setState(() {
          controller.text = option;
        });
        Navigator.pop(context);
      },
    );
  }

  Widget _buildTextAreaField(
    String label,
    String placeholder,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: placeholder,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.darkText,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetImage(String image) {
    if (image.isNotEmpty && image.startsWith('assets/')) {
      return Image.asset(image, fit: BoxFit.cover);
    }
    if (image.isNotEmpty) {
      try {
        final Uint8List bytes = base64Decode(image);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.pets, size: 80, color: Colors.grey),
      ),
    );
  }
}
