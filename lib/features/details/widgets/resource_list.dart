import 'package:flutter/material.dart';

import '../services/detail_service.dart';
import 'detail_load_error.dart';

/// Loads only the next batch and keeps earlier results when a request fails.
class ResourceList<T> extends StatefulWidget {
  final List<String> urls;
  final Future<List<T>> Function(List<int>) fetch;
  final Widget Function(T) itemBuilder;
  final Widget? header;
  final String emptyText;

  const ResourceList({
    super.key,
    required this.urls,
    required this.fetch,
    required this.itemBuilder,
    required this.emptyText,
    this.header,
  });

  @override
  State<ResourceList<T>> createState() => ResourceListState<T>();
}

class ResourceListState<T> extends State<ResourceList<T>> {
  final _items = <T>[];
  final _scroll = ScrollController();
  int _loaded = 0;
  bool _loading = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading || _loaded >= widget.urls.length) return;
    setState(() {
      _loading = true;
      _failed = false;
    });
    try {
      final end = (_loaded + 20).clamp(0, widget.urls.length);
      final ids = widget.urls.sublist(_loaded, end).map(resourceId).toList();
      final items = await widget.fetch(ids);
      if (!mounted) return;
      setState(() {
        _items.addAll(items);
        _loaded = end;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListView.builder(
    controller: _scroll,
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    itemCount: _items.length + 2,
    itemBuilder: (context, index) {
      if (index == 0) return widget.header ?? const SizedBox.shrink();
      if (index <= _items.length) return widget.itemBuilder(_items[index - 1]);
      if (_loading) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        );
      }
      if (_failed) return DetailLoadError(onRetry: _load);
      if (widget.urls.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Text(widget.emptyText),
        );
      }
      if (_loaded < widget.urls.length) {
        return TextButton(onPressed: _load, child: const Text('Mehr laden'));
      }
      return const SizedBox.shrink();
    },
  );
}
