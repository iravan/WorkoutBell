// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'WorkoutBell';

  @override
  String get round => 'Round';

  @override
  String get lessonStartTime => 'Started';

  @override
  String get workout => 'Workout';

  @override
  String get rest => 'Rest';

  @override
  String get min => 'min';

  @override
  String get mins => 'min(s)';

  @override
  String get help => 'Help';

  @override
  String get helpTitle => 'How to use';

  @override
  String get helpPlayPause =>
      'Play / Pause — tap the play button under the ring to start or pause.';

  @override
  String get helpStop =>
      'Stop — tap to reset. Confirms only after you have completed at least one round.';

  @override
  String get helpWorkout =>
      'Workout — use + / − to change workout duration (disabled while running).';

  @override
  String get helpRest =>
      'Rest — use + / − to change rest duration (disabled while running).';

  @override
  String get ready => 'Ready';

  @override
  String get confirmStopTitle => 'Reset timer?';

  @override
  String get confirmStopBody =>
      'This clears the current round and remaining time.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get helpStartTime =>
      'Started — long-press to show hours, minutes, and seconds.';

  @override
  String get helpRound => 'Round — counts completed workout and rest cycles.';

  @override
  String get helpColors =>
      'Green ring = workout. Red ring = rest. A bell sounds when a phase ends.';

  @override
  String get helpGotIt => 'Got it';
}
