import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../models/character.dart';
import '../models/character_filter.dart';
import '../services/character_service.dart';
import '../widgets/character_card.dart';
import '../widgets/character_filter_dialog.dart';
import '../widgets/character_filter_fields.dart';
import 'character_detail_screen.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});
  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  final _scroll = ScrollController();
  final _name = TextEditingController();
  final _characters = <Character>[];
  CharacterFilter _filter = const CharacterFilter();
  Timer? _debounce;
  int _generation = 0;
  int _nextPage = 1;
  bool _loading = false;
  bool _hasNext = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_checkLoadMore);
    _loadMore();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _name.dispose();
    super.dispose();
  }

  void _checkLoadMore() {
    if (!mounted || !_scroll.hasClients || _failed) return;
    if (_scroll.position.extentAfter < 900) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasNext) return;
    // Filter changes invalidate responses from earlier requests.
    final generation = _generation;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final page = await fetchCharacters(page: _nextPage, filter: _filter);
      if (!mounted || generation != _generation) return;
      setState(() {
        _characters.addAll(page.characters);
        _nextPage++;
        _hasNext = page.hasNextPage && page.characters.isNotEmpty;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || generation != _generation) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  void _applyFilter(CharacterFilter filter) {
    _debounce?.cancel();
    _name.value = TextEditingValue(
      text: filter.name,
      selection: TextSelection.collapsed(offset: filter.name.length),
    );
    setState(() {
      _generation++;
      _filter = filter;
      _characters.clear();
      _nextPage = 1;
      _hasNext = true;
      _loading = false;
      _failed = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
    _loadMore();
  }

  CharacterFilter _withName(CharacterFilter filter) => CharacterFilter(
    name: _name.text.trim(),
    status: filter.status,
    species: filter.species,
    gender: filter.gender,
  );

  Future<void> _showFilters() async {
    _debounce?.cancel();
    final filter = await showDialog<CharacterFilter>(
      context: context,
      builder: (_) => CharacterFilterDialog(filter: _withName(_filter)),
    );
    if (!mounted) return;
    if (filter != null) {
      _applyFilter(filter);
    } else if (_name.text.trim() != _filter.name) {
      _applyFilter(_withName(_filter));
    }
  }

  Widget _toolbar(bool desktop) {
    final search = TextField(
      controller: _name,
      decoration: const InputDecoration(
        labelText: 'Name',
        hintText: 'Charaktere suchen',
        prefixIcon: Icon(Icons.search),
      ),
      onChanged: (_) {
        _debounce?.cancel();
        _debounce = Timer(
          const Duration(milliseconds: 350),
          () => _applyFilter(_withName(_filter)),
        );
      },
    );
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(flex: desktop ? 2 : 1, child: search),
            const SizedBox(width: 12),
            if (desktop) ...[
              Expanded(
                flex: 4,
                child: CharacterFilterFields(
                  filter: _filter,
                  horizontal: true,
                  onChanged: (filter) => _applyFilter(_withName(filter)),
                ),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _applyFilter(const CharacterFilter()),
                icon: const Icon(Icons.filter_alt_off_outlined),
                label: const Text('Zurücksetzen'),
              ),
            ] else ...[
              IconButton(
                tooltip: 'Charaktere filtern',
                onPressed: _showFilters,
                icon: Badge(
                  isLabelVisible: _filter.isActive,
                  child: const Icon(Icons.filter_alt_outlined),
                ),
              ),
              if (_filter.isActive)
                IconButton(
                  tooltip: 'Filter zurücksetzen',
                  onPressed: () => _applyFilter(const CharacterFilter()),
                  icon: const Icon(Icons.filter_alt_off_outlined),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _feedback() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_failed) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _characters.isEmpty
                  ? 'Charaktere konnten nicht geladen werden.'
                  : 'Weitere Charaktere konnten nicht geladen werden.',
            ),
            TextButton(
              onPressed: _loadMore,
              child: const Text('Erneut versuchen'),
            ),
          ],
        ),
      );
    }
    if (_characters.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Keine Charaktere gefunden.'),
          if (_filter.isActive)
            TextButton(
              onPressed: () => _applyFilter(const CharacterFilter()),
              child: const Text('Filter zurücksetzen'),
            ),
        ],
      );
    }
    return const SizedBox(height: 24);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/portal.png', width: 44, height: 44),
            const SizedBox(width: 10),
            const Text('Rickpedia'),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, bounds) {
            return Column(
              children: [
                _toolbar(bounds.maxWidth >= 1000),
                const Divider(height: 1),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (_characters.isEmpty) {
                        return Center(child: _feedback());
                      }
                      final columns = ((constraints.maxWidth - 32 + 16) / 336)
                          .floor()
                          .clamp(1, 20);
                      return NotificationListener<ScrollMetricsNotification>(
                        onNotification: (_) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _checkLoadMore(),
                          );
                          return false;
                        },
                        child: Scrollbar(
                          controller: _scroll,
                          thumbVisibility: true,
                          child: CustomScrollView(
                            scrollCacheExtent: const ScrollCacheExtent.pixels(
                              168,
                            ),
                            controller: _scroll,
                            slivers: [
                              SliverPadding(
                                padding: const EdgeInsets.all(16),
                                sliver: SliverGrid(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columns,
                                        mainAxisSpacing: 16,
                                        crossAxisSpacing: 16,
                                        mainAxisExtent: 168,
                                      ),
                                  delegate: SliverChildBuilderDelegate((
                                    context,
                                    index,
                                  ) {
                                    final character = _characters[index];
                                    return CharacterCard(
                                      key: ValueKey(character.id),
                                      character: character,
                                      onTap: () => Navigator.of(context)
                                          .push<void>(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  CharacterDetailScreen(
                                                    character: character,
                                                  ),
                                            ),
                                          ),
                                    );
                                  }, childCount: _characters.length),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: Center(child: _feedback()),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
