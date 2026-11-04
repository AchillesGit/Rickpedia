import 'package:flutter/material.dart';

import '../controllers/character_controller.dart';
import '../models/character_filter.dart';
import '../widgets/character_feedback.dart';
import '../widgets/character_results.dart';
import '../widgets/character_toolbar.dart';
import 'character_detail_screen.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  final _controller = CharacterController();

  @override
  void initState() {
    super.initState();
    _controller.loadMore();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) => LayoutBuilder(
            builder: (context, bounds) => Column(
              children: [
                CharacterToolbar(
                  filter: _controller.filter,
                  desktop: bounds.maxWidth >= 1000,
                  onChanged: _controller.applyFilter,
                ),
                const Divider(height: 1),
                Expanded(
                  child: CharacterResults(
                    characters: _controller.characters,
                    filterRevision: _controller.filterRevision,
                    failed: _controller.failed,
                    onLoadMore: _controller.loadMore,
                    onSelected: (character) => Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) =>
                            CharacterDetailScreen(character: character),
                      ),
                    ),
                    feedback: CharacterFeedback(
                      loading: _controller.loading,
                      failed: _controller.failed,
                      isEmpty: _controller.characters.isEmpty,
                      hasActiveFilter: _controller.filter.isActive,
                      onRetry: _controller.loadMore,
                      onReset: () =>
                          _controller.applyFilter(const CharacterFilter()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
