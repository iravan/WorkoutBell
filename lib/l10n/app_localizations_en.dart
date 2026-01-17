// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Workout Timer';

  @override
  String get round => 'Round';

  @override
  String get lessonStartTime => 'Lesson Start Time';

  @override
  String get workout => 'Workout';

  @override
  String get rest => 'Rest';

  @override
  String get min => 'min';

  @override
  String get mins => 'min(s)';
}
