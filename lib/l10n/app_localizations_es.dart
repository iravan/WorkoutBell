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
  String get lessonStartTime => 'Inicio';

  @override
  String get workout => 'Entrenamiento';

  @override
  String get rest => 'Descanso';

  @override
  String get min => 'min';

  @override
  String get mins => 'min(s)';

  @override
  String get help => 'Ayuda';

  @override
  String get helpTitle => 'Cómo usar';

  @override
  String get helpPlayPause =>
      'Reproducir / Pausar — toca el botón bajo el anillo para iniciar o pausar.';

  @override
  String get helpStop =>
      'Detener — toca para reiniciar. Solo pide confirmación tras completar al menos una ronda.';

  @override
  String get helpWorkout =>
      'Entrenamiento — usa + / − para cambiar la duración (desactivado al correr).';

  @override
  String get helpRest =>
      'Descanso — usa + / − para cambiar la duración (desactivado al correr).';

  @override
  String get ready => 'Listo';

  @override
  String get confirmStopTitle => '¿Reiniciar temporizador?';

  @override
  String get confirmStopBody =>
      'Se borrará la ronda actual y el tiempo restante.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get reset => 'Reiniciar';

  @override
  String get helpStartTime =>
      'Inicio — mantén pulsado para mostrar horas, minutos y segundos.';

  @override
  String get helpRound =>
      'Ronda — cuenta los ciclos de entrenamiento y descanso completados.';

  @override
  String get helpColors =>
      'Anillo verde = entrenamiento. Anillo rojo = descanso. Suena una campana al terminar una fase.';

  @override
  String get helpGotIt => 'Entendido';
}
