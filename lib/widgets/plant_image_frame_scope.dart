import 'package:flutter/material.dart';

import '../data/plant_image_frame_prefs_store.dart';

class PlantImageFrameScope extends InheritedNotifier<PlantImageFramePrefsStore> {
  const PlantImageFrameScope({
    super.key,
    required PlantImageFramePrefsStore store,
    required super.child,
  }) : super(notifier: store);

  static PlantImageFramePrefsStore? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PlantImageFrameScope>()
        ?.notifier;
  }
}
