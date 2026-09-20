import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WeedImpact {
  invasive,
  neutral,
  beneficial,
}

extension WeedImpactLabel on WeedImpact {
  String get label {
    switch (this) {
      case WeedImpact.invasive:
        return 'Ongewenst';
      case WeedImpact.neutral:
        return 'Neutraal';
      case WeedImpact.beneficial:
        return 'Nuttig (eetbaar/wild)';
    }
  }
}

class WeedScanEntry {
  const WeedScanEntry({
    required this.id,
    required this.tuinSpaceId,
    required this.nameNl,
    required this.impact,
    required this.summary,
    required this.scannedAt,
    this.confidence,
    this.resolved = false,
  });

  final String id;
  final String tuinSpaceId;
  final String nameNl;
  final WeedImpact impact;
  final String summary;
  final DateTime scannedAt;
  final double? confidence;
  final bool resolved;

  WeedScanEntry copyWith({bool? resolved}) {
    return WeedScanEntry(
      id: id,
      tuinSpaceId: tuinSpaceId,
      nameNl: nameNl,
      impact: impact,
      summary: summary,
      scannedAt: scannedAt,
      confidence: confidence,
      resolved: resolved ?? this.resolved,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tuinSpaceId': tuinSpaceId,
        'nameNl': nameNl,
        'impact': impact.name,
        'summary': summary,
        'scannedAt': scannedAt.toIso8601String(),
        if (confidence != null) 'confidence': confidence,
        'resolved': resolved,
      };

  factory WeedScanEntry.fromJson(Map<String, dynamic> json) {
    return WeedScanEntry(
      id: json['id'] as String,
      tuinSpaceId: json['tuinSpaceId'] as String,
      nameNl: json['nameNl'] as String,
      impact: WeedImpact.values.byName(json['impact'] as String),
      summary: json['summary'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      confidence: (json['confidence'] as num?)?.toDouble(),
      resolved: json['resolved'] as bool? ?? false,
    );
  }
}

/// Logboek onkruid-scans per tuin.
class WeedScanStore extends ChangeNotifier {
  static const _storageKey = 'weed_scans_v1';
  static const _maxPerSpace = 80;

  final List<WeedScanEntry> _entries = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;

  List<WeedScanEntry> entriesForSpace(String tuinSpaceId) {
    return _entries
        .where((e) => e.tuinSpaceId == tuinSpaceId)
        .toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
  }

  List<WeedScanEntry> activeEntriesForSpace(String tuinSpaceId) {
    return entriesForSpace(tuinSpaceId).where((e) => !e.resolved).toList();
  }

  Future<void> resolveEntry(String id) async {
    final index = _entries.indexWhere((e) => e.id == id);
    if (index < 0) return;
    _entries[index] = _entries[index].copyWith(resolved: true);
    await _persist();
    notifyListeners();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _entries.clear();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        _entries.add(WeedScanEntry.fromJson(item as Map<String, dynamic>));
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> addEntry(WeedScanEntry entry) async {
    _entries.insert(0, entry);
    final perSpace =
        _entries.where((e) => e.tuinSpaceId == entry.tuinSpaceId).length;
    if (perSpace > _maxPerSpace) {
      var removed = 0;
      for (var i = _entries.length - 1;
          i >= 0 && removed < perSpace - _maxPerSpace;
          i--) {
        if (_entries[i].tuinSpaceId == entry.tuinSpaceId) {
          _entries.removeAt(i);
          removed++;
        }
      }
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_entries.map((e) => e.toJson()).toList()),
    );
  }
}
