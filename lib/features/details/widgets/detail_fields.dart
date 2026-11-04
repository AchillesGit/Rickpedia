import 'package:flutter/material.dart';

class DetailFields extends StatelessWidget {
  final Map<String, String> fields;

  const DetailFields(this.fields, {super.key});

  static String displayValue(String value) =>
      value.trim().isEmpty || value == 'unknown' ? 'Unbekannt' : value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      for (final field in fields.entries)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(field.key),
          subtitle: Text(displayValue(field.value)),
        ),
    ],
  );
}
