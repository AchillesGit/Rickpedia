import 'package:flutter/material.dart';

import '../../characters/models/character.dart';
import '../models/episode.dart';
import '../services/detail_service.dart';
import 'detail_character_list.dart';
import 'detail_dialog.dart';
import 'detail_fields.dart';
import 'resource_list.dart';

class EpisodeDetailDialog extends StatefulWidget {
  final List<String> urls;
  final ValueChanged<Character> onCharacterSelected;

  const EpisodeDetailDialog({
    super.key,
    required this.urls,
    required this.onCharacterSelected,
  });

  @override
  State<EpisodeDetailDialog> createState() => _EpisodeDetailDialogState();
}

class _EpisodeDetailDialogState extends State<EpisodeDetailDialog> {
  Episode? _selected;

  @override
  Widget build(BuildContext context) {
    final episode = _selected;
    return DetailDialog(
      title: episode?.name ?? 'Episodenauftritte',
      onBack: episode == null ? null : () => setState(() => _selected = null),
      child: IndexedStack(
        index: episode == null ? 0 : 1,
        children: [
          ResourceList<Episode>(
            urls: widget.urls,
            fetch: fetchEpisodesByIds,
            emptyText: 'Keine Episoden bekannt.',
            itemBuilder: (item) => ListTile(
              title: Text(item.name),
              subtitle: Text(item.code),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => setState(() => _selected = item),
            ),
          ),
          if (episode == null)
            const SizedBox.shrink()
          else
            DetailCharacterList(
              key: ValueKey(episode.id),
              urls: episode.characterUrls,
              onSelected: widget.onCharacterSelected,
              emptyText: 'Keine Charaktere bekannt.',
              header: DetailFields({
                'Titel': episode.name,
                'Episodencode': episode.code,
                'Erstausstrahlung': episode.airDate,
                'Charaktere': '${episode.characterUrls.length}',
              }),
            ),
        ],
      ),
    );
  }
}
