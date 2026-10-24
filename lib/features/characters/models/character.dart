class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String imageUrl;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.imageUrl,
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String,
      imageUrl: json['image'] as String,
    );
  }
}
