/// The combinable query parameters supported by the character endpoint.
class CharacterFilter {
  final String name;
  final String? status;
  final String species;
  final String? gender;

  const CharacterFilter({
    this.name = '',
    this.status,
    this.species = '',
    this.gender,
  });

  Map<String, String> toQueryParameters() {
    final values = {
      'name': name.trim(),
      'status': status?.trim() ?? '',
      'species': species.trim(),
      'gender': gender?.trim() ?? '',
    };
    return values..removeWhere((key, value) => value.isEmpty);
  }

  bool get isActive => toQueryParameters().isNotEmpty;
}
