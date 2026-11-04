import '../../../core/network/rick_and_morty_api.dart';

import '../models/character.dart';
import '../models/episode.dart';
import '../models/location.dart';

int resourceId(String url) {
  final id = int.tryParse(Uri.parse(url).pathSegments.lastOrNull ?? '');
  if (id == null || id < 1) throw FormatException('Invalid resource URL', url);
  return id;
}

Future<Location> fetchLocation(int id) async => Location.fromJson(
  await fetchApiJson('location/$id') as Map<String, dynamic>,
);

Future<List<T>> _fetchBatch<T>(
  String resource,
  List<int> ids,
  T Function(Map<String, dynamic>) parse,
) async {
  if (ids.isEmpty) return [];
  final data = await fetchApiJson('$resource/${ids.toSet().join(',')}');
  final rows = data is List ? data : [data];
  final byId = <int, T>{
    for (final row in rows)
      (row as Map<String, dynamic>)['id'] as int: parse(row),
  };
  return [
    for (final id in ids)
      byId[id] ?? (throw FormatException('Missing $resource/$id')),
  ];
}

Future<List<Episode>> fetchEpisodesByIds(List<int> ids) =>
    _fetchBatch('episode', ids, Episode.fromJson);

Future<List<Character>> fetchCharactersByIds(List<int> ids) =>
    _fetchBatch('character', ids, Character.fromJson);
