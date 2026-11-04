class Episode {
  final int id;
  final String name;
  final String code;
  final String airDate;
  final List<String> characterUrls;

  const Episode({
    required this.id,
    required this.name,
    required this.code,
    required this.airDate,
    required this.characterUrls,
  });

  factory Episode.fromJson(Map<String, dynamic> json) => Episode(
    id: json['id'] as int,
    name: json['name'] as String,
    code: json['episode'] as String? ?? '',
    airDate: json['air_date'] as String? ?? '',
    characterUrls:
        (json['characters'] as List<dynamic>?)?.cast<String>() ?? const [],
  );
}
