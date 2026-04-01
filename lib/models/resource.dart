class Resource {
  final String id;
  final String name;
  final String description;
  final String category;
  final String phoneNumber;
  final String website;
  final String address;
  final bool isEmergency;

  const Resource({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.phoneNumber,
    required this.website,
    required this.address,
    required this.isEmergency,
  });

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      website: map['website'] ?? '',
      address: map['address'] ?? '',
      isEmergency: map['isEmergency'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'phoneNumber': phoneNumber,
      'website': website,
      'address': address,
      'isEmergency': isEmergency,
    };
  }

  Resource copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    String? phoneNumber,
    String? website,
    String? address,
    bool? isEmergency,
  }) {
    return Resource(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      website: website ?? this.website,
      address: address ?? this.address,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }
}