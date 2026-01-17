// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Temporizador de Entrenamiento';

  @override
  String get round => 'Ronda';

  @override
  String get lessonStartTime => 'Hora de Inicio de la Lección';

  @override
  String get workout => 'Entrenamiento';

  @override
  String get rest => 'Descanso';

  @override
  String get min => 'min';

  @override
  String get mins => 'min(s)';
}
