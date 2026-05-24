import 'garden_notification_service.dart';
import 'garden_profile_store.dart';
import 'garden_scan_prefs_store.dart';
import 'my_garden_store.dart';
import 'vegetable_repository.dart';

Future<void> syncGardenNotifications({
  required GardenProfileStore profileStore,
  required MyGardenStore gardenStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
}) async {
  await GardenNotificationService.instance.rescheduleAll(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
    enabled: gardenStore.notificationsEnabled,
    daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
    weeklyScanIntervalDays: scanPrefs.weeklyScanIntervalDays,
  );
}
