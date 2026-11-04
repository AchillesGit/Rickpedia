import 'package:flutter/material.dart';

import '../models/character.dart';
import '../models/location.dart';
import '../services/detail_service.dart';
import 'detail_character_list.dart';
import 'detail_dialog.dart';
import 'detail_fields.dart';
import 'detail_load_error.dart';

class LocationDetailDialog extends StatefulWidget {
  final String url;
  final String name;
  final ValueChanged<Character> onCharacterSelected;

  const LocationDetailDialog({
    super.key,
    required this.url,
    required this.name,
    required this.onCharacterSelected,
  });

  @override
  State<LocationDetailDialog> createState() => _LocationDetailDialogState();
}

class _LocationDetailDialogState extends State<LocationDetailDialog> {
  late Future<Location> _location = _fetch();

  Future<Location> _fetch() async => fetchLocation(resourceId(widget.url));

  @override
  Widget build(BuildContext context) => DetailDialog(
    title: widget.name,
    child: FutureBuilder<Location>(
      future: _location,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: DetailLoadError(
              onRetry: () => setState(() {
                _location = _fetch();
              }),
            ),
          );
        }
        final location = snapshot.requireData;
        return DetailCharacterList(
          urls: location.residentUrls,
          onSelected: widget.onCharacterSelected,
          emptyText: 'Keine Bewohner bekannt.',
          header: DetailFields({
            'Name': location.name,
            'Typ': location.type,
            'Dimension': location.dimension,
            'Bewohner': '${location.residentUrls.length}',
          }),
        );
      },
    ),
  );
}
