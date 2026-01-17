// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Minuteur d\'Entraînement';

  @override
  String get round => 'Tour';

  @override
  String get lessonStartTime => 'Heure de Début de la Leçon';

  @override
  String get workout => 'Entraînement';

  @override
  String get rest => 'Repos';

  @override
  String get min => 'min';

  @override
  String get mins => 'min(s)';
}
