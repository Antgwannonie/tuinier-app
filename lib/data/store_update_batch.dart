import 'package:flutter/foundation.dart';

int _batchDepth = 0;
final Set<ChangeNotifier> _pending = {};

/// Coalesce [ChangeNotifier] updates during a batched write (e.g. add plant).
void notifyStore(ChangeNotifier store) {
  if (_batchDepth > 0) {
    _pending.add(store);
    return;
  }
  store.notifyListeners();
}

/// Run async work and notify all touched stores once at the end.
Future<T> runStoreBatch<T>(Future<T> Function() action) async {
  _batchDepth++;
  try {
    return await action();
  } finally {
    _batchDepth--;
    if (_batchDepth == 0) {
      final targets = _pending.toList();
      _pending.clear();
      for (final store in targets) {
        store.notifyListeners();
      }
    }
  }
}
