import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/character.dart';
import '../models/character_filter.dart';
import '../models/character_page.dart';
import '../services/character_service.dart';

typedef CharacterFetcher = Future<CharacterPage> Function({
  required int page,
  required CharacterFilter filter,
});

class CharacterController extends ChangeNotifier {
  final CharacterFetcher _fetch;
  final _characters = <Character>[];
  late final List<Character> characters = UnmodifiableListView(_characters);
  CharacterFilter _filter = const CharacterFilter();
  int _generation = 0;
  int _nextPage = 1;
  bool _loading = false;
  bool _hasNext = true;
  bool _failed = false;
  bool _disposed = false;

  CharacterController({CharacterFetcher? fetch})
    : _fetch = fetch ?? fetchCharacters;

  CharacterFilter get filter => _filter;
  int get filterRevision => _generation;
  bool get loading => _loading;
  bool get hasNext => _hasNext;
  bool get failed => _failed;

  Future<void> loadMore() async {
    if (_disposed || _loading || !_hasNext) return;
    final generation = _generation;
    _loading = true;
    _failed = false;
    notifyListeners();
    try {
      final page = await _fetch(page: _nextPage, filter: _filter);
      if (_disposed || generation != _generation) return;
      _characters.addAll(page.characters);
      _nextPage++;
      _hasNext = page.hasNextPage && page.characters.isNotEmpty;
      _loading = false;
      notifyListeners();
    } catch (_) {
      if (_disposed || generation != _generation) return;
      _loading = false;
      _failed = true;
      notifyListeners();
    }
  }

  void applyFilter(CharacterFilter filter) {
    if (_disposed) return;
    // Invalidate responses from requests for earlier filters.
    _generation++;
    _filter = filter;
    _characters.clear();
    _nextPage = 1;
    _hasNext = true;
    _loading = false;
    _failed = false;
    loadMore();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
