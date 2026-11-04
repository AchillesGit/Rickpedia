class Character {
  final int id;
  final String name;
  final String status;
  final String species;
  final String type;
  final String imageUrl;
  final String gender;
  final String origin;
  final String location;
  final int episodeCount;
  final String originUrl;
  final String locationUrl;
  final List<String> episodeUrls;

  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.type,
    required this.imageUrl,
    this.gender = 'unknown',
    this.origin = 'unknown',
    this.location = 'unknown',
    this.episodeCount = 0,
    this.originUrl = '',
    this.locationUrl = '',
    this.episodeUrls = const [],
  });

  factory Character.fromJson(Map<String, dynamic> json) {
    return Character(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String,
      imageUrl: json['image'] as String,
      gender: json['gender'] as String? ?? 'unknown',
      origin:
          (json['origin'] as Map<String, dynamic>?)?['name'] as String? ??
          'unknown',
      location:
          (json['location'] as Map<String, dynamic>?)?['name'] as String? ??
          'unknown',
      episodeCount: (json['episode'] as List<dynamic>?)?.length ?? 0,
      originUrl:
          (json['origin'] as Map<String, dynamic>?)?['url'] as String? ?? '',
      locationUrl:
          (json['location'] as Map<String, dynamic>?)?['url'] as String? ?? '',
      episodeUrls:
          (json['episode'] as List<dynamic>?)?.cast<String>() ?? const [],
    );
  }
}
