import 'package:flutter/material.dart';

import 'tuinier_shell_navigation.dart';

/// Sluit scanresultaat (optioneel) en opent de moestuin-tab.
void goToMoestuinFromScanContext(
  BuildContext context, {
  bool popScanResult = false,
}) {
  final navigator = Navigator.of(context);

  void openMoestuin() {
    mainShellKey.currentState?.goToMoestuinTab();
  }

  if (popScanResult && navigator.canPop()) {
    navigator.pop();
    WidgetsBinding.instance.addPostFrameCallback((_) => openMoestuin());
    return;
  }

  openMoestuin();
}
