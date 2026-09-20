import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../data/scan_hero_bg_asset.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/scan_hub_assets.dart';

/// Komkommer-achtergrond voor de scan-hub hero.
class ScanHeroBackground extends StatefulWidget {
  const ScanHeroBackground({super.key});

  @override
  State<ScanHeroBackground> createState() => _ScanHeroBackgroundState();
}

class _ScanHeroBackgroundState extends State<ScanHeroBackground> {
  ImageProvider? _provider;

  static const _downloadUrls = [
    'https://images.unsplash.com/photo-1592840070225-709c27967cfc?auto=format&fit=crop&w=1400&q=90',
    'https://images.unsplash.com/photo-1628773829563-0e763ceb3a7a?auto=format&fit=crop&w=1400&q=90',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final embedded = scanHeroBgBytes;
    if (embedded.isNotEmpty) {
      _setProvider(MemoryImage(embedded));
      return;
    }

    try {
      await rootBundle.load(ScanHubAssets.heroBackground);
      _setProvider(AssetImage(ScanHubAssets.heroBackground));
      return;
    } catch (_) {}

    if (!kIsWeb) {
      final cache = await _cacheFile();
      if (await cache.exists()) {
        _setProvider(FileImage(cache));
        return;
      }

      for (final url in _downloadUrls) {
        try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
            await cache.writeAsBytes(response.bodyBytes, flush: true);
            _setProvider(MemoryImage(response.bodyBytes));
            return;
          }
        } catch (_) {}
      }
    }

    _setProvider(null);
  }

  Future<File> _cacheFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/scan_hero_bg.jpg');
  }

  void _setProvider(ImageProvider? provider) {
    if (!mounted) return;
    setState(() => _provider = provider);
  }

  @override
  Widget build(BuildContext context) {
    final provider = _provider;

    if (provider == null) {
      return ColoredBox(
        color: TuinierColors.headerDark,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Colors.white.withValues(alpha: 0.25),
            size: 48,
          ),
        ),
      );
    }

    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: Transform.scale(
        scale: 1.08,
        child: Image(
          image: provider,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
