import 'package:flutter/material.dart';

import '../widgets/pest_guide_page.dart';

/// Volledig scherm plagen-gids (vanuit waarschuwing of diepe link).
class PestGuideScreen extends StatelessWidget {
  const PestGuideScreen({super.key, this.initialQuery});

  final String? initialQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plagen opzoeken'),
      ),
      body: PestGuidePage(initialQuery: initialQuery),
    );
  }
}
