import 'package:flutter/widgets.dart';

import '../data/insect_scan_store.dart';
import '../data/weed_scan_store.dart';

/// Maakt scan-stores beschikbaar via context (o.a. na hot reload).
class TuinierScanStoresScope extends InheritedWidget {
  const TuinierScanStoresScope({
    super.key,
    required this.insectScanStore,
    required this.weedScanStore,
    required super.child,
  });

  final InsectScanStore insectScanStore;
  final WeedScanStore weedScanStore;

  static TuinierScanStoresScope of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<TuinierScanStoresScope>();
    assert(scope != null, 'TuinierScanStoresScope ontbreekt boven in de widget-boom');
    return scope!;
  }

  @override
  bool updateShouldNotify(TuinierScanStoresScope oldWidget) {
    return insectScanStore != oldWidget.insectScanStore ||
        weedScanStore != oldWidget.weedScanStore;
  }
}
