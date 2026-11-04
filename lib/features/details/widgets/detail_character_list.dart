import 'package:flutter/material.dart';

import '../../characters/models/character.dart';
import '../../characters/widgets/character_image.dart';
import '../services/detail_service.dart';
import 'detail_fields.dart';
import 'resource_list.dart';

class DetailCharacterList extends StatelessWidget {
  final List<String> urls;
  final Widget header;
  final ValueChanged<Character> onSelected;
  final String emptyText;

  const DetailCharacterList({
    super.key,
    required this.urls,
    required this.header,
    required this.onSelected,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) => ResourceList<Character>(
    urls: urls,
    fetch: fetchCharactersByIds,
    header: header,
    emptyText: emptyText,
    itemBuilder: (character) => ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CharacterImage(imageUrl: character.imageUrl, size: 48),
      title: Text(character.name),
      subtitle: Text(
        '${DetailFields.displayValue(character.status)} · ${DetailFields.displayValue(character.species)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => onSelected(character),
    ),
  );
}
