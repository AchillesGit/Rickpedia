class Location {
  final int id;
  final String name;
  final String type;
  final String dimension;
  final List<String> residentUrls;

  const Location({
    required this.id,
    required this.name,
    required this.type,
    required this.dimension,
    required this.residentUrls,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
    id: json['id'] as int,
    name: json['name'] as String,
    type: json['type'] as String? ?? '',
    dimension: json['dimension'] as String? ?? '',
    residentUrls:
        (json['residents'] as List<dynamic>?)?.cast<String>() ?? const [],
  );
}
