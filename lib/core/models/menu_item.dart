class MenuItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final String imageUrl; // url pubblico per mostrare l'immagine
  final String?
  imagePath; // path in Storage (es. "menu_images/uuid_filename.jpg") — utile per delete
  final bool available;

  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.imageUrl,
    this.imagePath,
    required this.available,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map, String id) {
    return MenuItem(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      categoryId: map['categoryId'] ?? 'default',
      imageUrl: map['imageUrl'] ?? '',
      imagePath: map['imagePath'],
      available: map['available'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'imagePath': imagePath,
      'available': available,
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    String? imageUrl,
    String? imagePath,
    bool? available,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePath: imagePath ?? this.imagePath,
      available: available ?? this.available,
    );
  }
}
