import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show ScrollCacheExtent;

import '../models/character.dart';
import 'character_card.dart';

class CharacterResults extends StatefulWidget {
  final List<Character> characters;
  final int filterRevision;
  final bool failed;
  final VoidCallback onLoadMore;
  final ValueChanged<Character> onSelected;
  final Widget feedback;

  const CharacterResults({
    super.key,
    required this.characters,
    required this.filterRevision,
    required this.failed,
    required this.onLoadMore,
    required this.onSelected,
    required this.feedback,
  });

  @override
  State<CharacterResults> createState() => _CharacterResultsState();
}

class _CharacterResultsState extends State<CharacterResults> {
  // A recreated viewport starts at the top after a filter clears the results.
  final _scroll = ScrollController(keepScrollOffset: false);

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_checkLoadMore);
  }

  @override
  void didUpdateWidget(covariant CharacterResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filterRevision != widget.filterRevision) {
      final revision = widget.filterRevision;
      // Scroll notifications may rebuild the AppBar, so reset after layout.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted &&
            widget.filterRevision == revision &&
            _scroll.hasClients) {
          _scroll.jumpTo(0);
        }
      });
    }
  }

  void _checkLoadMore() {
    if (!mounted || !_scroll.hasClients || widget.failed) return;
    if (_scroll.position.extentAfter < 900) widget.onLoadMore();
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (widget.characters.isEmpty) {
          return Center(child: widget.feedback);
        }
        final columns = ((constraints.maxWidth - 32 + 16) / 336).floor().clamp(
          1,
          20,
        );
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
              scrollCacheExtent: const ScrollCacheExtent.pixels(168),
              controller: _scroll,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      mainAxisExtent: 168,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final character = widget.characters[index];
                      return CharacterCard(
                        key: ValueKey(character.id),
                        character: character,
                        onTap: () => widget.onSelected(character),
                      );
                    }, childCount: widget.characters.length),
                  ),
                ),
                SliverToBoxAdapter(child: Center(child: widget.feedback)),
              ],
            ),
          ),
        );
      },
    );
  }
}
