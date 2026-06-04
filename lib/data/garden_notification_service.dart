import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/garden_note.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'garden_notes_store.dart';
import 'crop_harvest_kind.dart';
import 'garden_plant_schedule.dart';
import 'garden_profile_store.dart';
import 'my_garden_store.dart';
import 'vegetable_repository.dart';

/// Meldingen: eerste foto, wekelijkse scan, oogst.
class GardenNotificationService {
  GardenNotificationService._();
  static final GardenNotificationService instance =
      GardenNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _tzReady = false;

  static const _channelId = 'tuinier_moestuin';
  static const _baseId = 2000;
  static const _notesBaseId = 4000;

  Future<void> init() async {
    if (!_tzReady) {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.local);
      _tzReady = true;
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      _channelId,
      'Moestuin herinneringen',
      description:
          'Herinneringen voor foto\'s, wekelijkse scans en oogst uit je tuin.',
      importance: Importance.defaultImportance,
    );
    await androidPlugin?.createNotificationChannel(channel);
  }

  Future<void> rescheduleAll({
    required GardenProfileStore profileStore,
    required MyGardenStore gardenStore,
    required VegetableRepository repository,
    GardenNotesStore? notesStore,
    required bool enabled,
    required int daysUntilFirstPhoto,
    required int weeklyScanIntervalDays,
  }) async {
    await init();
    await _plugin.cancelAll();

    if (!enabled || gardenStore.isEmpty) return;

    var slot = 0;
    for (final id in gardenStore.ids) {
      final profile = profileStore.profileFor(id);
      final veg = repository.byId(id);
      if (profile == null || veg == null) continue;

      final scheduled = _upcomingNotifications(
        profile,
        veg,
        daysUntilFirstPhoto: daysUntilFirstPhoto,
        weeklyScanIntervalDays: weeklyScanIntervalDays,
      );
      for (final item in scheduled) {
        if (slot > 48) break;
        await _schedule(
          id: _baseId + slot,
          when: item.when,
          title: item.title,
          body: item.body,
        );
        slot++;
      }
    }

    if (notesStore != null) {
      for (final note in notesStore.all) {
        if (note.source != GardenNoteSource.user) continue;
        if (!note.notify) continue;
        final when = DateTime(
          note.date.year,
          note.date.month,
          note.date.day,
          9,
          0,
        );
        final prefix =
            note.source == GardenNoteSource.ai ? 'AI-tuin' : 'Notitie';
        await _schedule(
          id: _notesBaseId + (note.id.hashCode.abs() % 500),
          when: when,
          title: '$prefix — ${note.title}',
          body: note.body.length > 120
              ? '${note.body.substring(0, 117)}…'
              : note.body,
        );
      }
    }
  }

  List<_ScheduledNotify> _upcomingNotifications(
    GardenPlantProfile profile,
    Vegetable veg, {
    required int daysUntilFirstPhoto,
    required int weeklyScanIntervalDays,
  }) {
    final now = DateTime.now();
    final out = <_ScheduledNotify>[];
    final name = veg.nameNl;

    if (!profile.isPlanted) return out;

    if (profile.lastAnalysis == null) {
      var firstPrompt = DateTime(now.year, now.month, now.day, 9, 30);
      if (!firstPrompt.isAfter(now)) {
        firstPrompt = firstPrompt.add(const Duration(days: 1));
      }
      out.add(
        _ScheduledNotify(
          when: firstPrompt,
          title: 'Eerste foto — $name',
          body:
              'Start je plantgeschiedenis: maak een foto van het zaadbed of de '
              'plek in de grond — ook zonder zichtbare kiem.',
        ),
      );
      if (firstPhotoNotificationDue(
        profile,
        daysUntilFirstPhoto: daysUntilFirstPhoto,
      )) {
        final due = firstPhotoDueDate(
          profile,
          daysUntilFirstPhoto: daysUntilFirstPhoto,
        );
        final reminder = DateTime(due.year, due.month, due.day, 9, 30);
        if (reminder.isAfter(firstPrompt)) {
          out.add(
            _ScheduledNotify(
              when: reminder,
              title: 'Herinnering — $name',
              body:
                  'Nog geen eerste scan? Leg je plant vast voor persoonlijke '
                  'voortgang in de app.',
            ),
          );
        }
      }
    } else {
      var scanDue = profile.nextScanDue ??
          profile.lastAnalysis!.scannedAt
              .add(Duration(days: weeklyScanIntervalDays));
      if (scanDue.isBefore(now)) {
        scanDue = DateTime(now.year, now.month, now.day + 1, 10, 0);
      }
      out.add(
        _ScheduledNotify(
          when: DateTime(scanDue.year, scanDue.month, scanDue.day, 10, 0),
          title: 'Wekelijkse scan — $name',
          body:
              'Maak een nieuwe foto zodat oogst en groei in je kalender bijblijven.',
        ),
      );

      final bloomCrop = isMoestuinBloomCrop(veg);
      if (!bloomCrop) {
        final harvest = profile.predictedHarvestAt;
        if (harvest != null && harvest.isAfter(now)) {
          final remind = harvest.subtract(const Duration(days: 2));
          if (remind.isAfter(now)) {
            out.add(
              _ScheduledNotify(
                when: DateTime(remind.year, remind.month, remind.day, 9, 0),
                title: 'Oogst nadert — $name',
                body: profile.lastAnalysis?.harvestWindowLabel ??
                    'Binnenkort oogsten volgens je laatste scan.',
              ),
            );
          }
          out.add(
            _ScheduledNotify(
              when: DateTime(harvest.year, harvest.month, harvest.day, 8, 30),
              title: 'Oogstdag — $name',
              body:
                  'Volgens je AI-scan is vandaag een goed moment om te oogsten.',
            ),
          );
        }
      }

      if (isEdibleMoestuinBloomCrop(veg) &&
          showEdibleBloomHarvestSection(profile, veg)) {
        final bloomNote = bloomHintFromProfile(profile);
        out.add(
          _ScheduledNotify(
            when: DateTime(now.year, now.month, now.day, 11, 0)
                .add(const Duration(hours: 1)),
            title: 'In bloei — $name',
            body: bloomNote.trim().isNotEmpty
                ? '$bloomNote Plukken om te eten of seizoen afronden kan in de app.'
                : 'Eetbaar of laten uitbloeien — open Tuinier bij je plant.',
          ),
        );
      } else if (isOrnamentalOnlyMoestuinCrop(veg) &&
          showOrnamentalFinishSection(profile, veg)) {
        final bloomNote = bloomHintFromProfile(profile);
        out.add(
          _ScheduledNotify(
            when: DateTime(now.year, now.month, now.day, 11, 0)
                .add(const Duration(hours: 1)),
            title: 'In bloei — $name',
            body: bloomNote.trim().isNotEmpty
                ? bloomNote
                : 'Je moestuinbloem doet het goed — open Tuinier voor het advies.',
          ),
        );
      } else if (isReadyToHarvest(profile, vegetable: veg)) {
        out.add(
          _ScheduledNotify(
            when: DateTime(now.year, now.month, now.day, 11, 0)
                .add(const Duration(hours: 1)),
            title: 'Klaar om te oogsten — $name',
            body: 'Open Tuinier en controleer je plant in Plant scan.',
          ),
        );
      }
    }

    return out;
  }

  Future<void> _schedule({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    if (when.isBefore(DateTime.now())) return;

    final tzWhen = tz.TZDateTime.from(when, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzWhen,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Moestuin herinneringen',
          channelDescription:
              'Herinneringen voor foto\'s, scans en oogst.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

class _ScheduledNotify {
  const _ScheduledNotify({
    required this.when,
    required this.title,
    required this.body,
  });

  final DateTime when;
  final String title;
  final String body;
}
