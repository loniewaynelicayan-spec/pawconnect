class Pet {
  final String? id;
  final String? ownerId;
  final String name;
  final String breed;
  final String? age;
  final String? gender;
  final String image;
  final String? description;
  final String? category;
  final String? ownerName;
  final String? location;
  final bool? isAdopted;
  final String? contactInfo;
  final String? imageUrl;

  Pet({
    this.id,
    this.ownerId,
    required this.name,
    required this.breed,
    this.age,
    this.gender,
    required this.image,
    this.description,
    this.category,
    this.ownerName,
    this.location,
    this.isAdopted,
    this.contactInfo,
    this.imageUrl,
  });
}
