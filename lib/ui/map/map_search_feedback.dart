import 'package:campus_mobile_experimental/core/providers/map.dart';
import 'package:campus_mobile_experimental/ui/common/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MapSearchFeedback extends StatefulWidget {
  const MapSearchFeedback({super.key});

  @override
  State<MapSearchFeedback> createState() => _MapSearchFeedbackState();
}

class _MapSearchFeedbackState extends State<MapSearchFeedback> {
  MapsDataProvider? _provider;
  bool _hasNoResults = false;
  int _revision = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = Provider.of<MapsDataProvider>(context);
    if (identical(provider, _provider)) return;
    _provider?.removeListener(_handleSearchChanged);
    _provider = provider;
    _hasNoResults = false;
    _revision++;
    provider.addListener(_handleSearchChanged);
    _handleSearchChanged();
  }

  void _handleSearchChanged() {
    final provider = _provider!;
    final hasNoResults = provider.isLoading != true && provider.noResults == true && provider.markers.isEmpty;
    if (hasNoResults == _hasNoResults) return;
    _hasNoResults = hasNoResults;
    final revision = ++_revision;
    if (!hasNoResults) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != _revision) return;
      AppSnackBar.show(context, 'No results found for your search.');
    });
  }

  @override
  void dispose() {
    _provider?.removeListener(_handleSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}
