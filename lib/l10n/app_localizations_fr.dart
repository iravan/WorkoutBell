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
  String get lessonStartTime => 'Début';

  @override
  String get workout => 'Entraînement';

  @override
  String get rest => 'Repos';

  @override
  String get min => 'min';

  @override
  String get mins => 'min(s)';

  @override
  String get help => 'Aide';

  @override
  String get helpTitle => 'Mode d\'emploi';

  @override
  String get helpPlayPause =>
      'Lecture / Pause — appuyez sur le bouton sous l\'anneau pour démarrer ou mettre en pause.';

  @override
  String get helpStop =>
      'Arrêt — appuyez pour réinitialiser. Confirmation seulement après au moins un tour.';

  @override
  String get helpWorkout =>
      'Entraînement — utilisez + / − pour changer la durée (désactivé en cours).';

  @override
  String get helpRest =>
      'Repos — utilisez + / − pour changer la durée (désactivé en cours).';

  @override
  String get ready => 'Prêt';

  @override
  String get confirmStopTitle => 'Réinitialiser le minuteur ?';

  @override
  String get confirmStopBody =>
      'Cela efface le tour actuel et le temps restant.';

  @override
  String get cancel => 'Annuler';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get helpStartTime =>
      'Début — appui long pour afficher heures, minutes et secondes.';

  @override
  String get helpRound =>
      'Tour — compte les cycles d\'entraînement et de repos terminés.';

  @override
  String get helpColors =>
      'Anneau vert = entraînement. Anneau rouge = repos. Une cloche sonne à la fin d\'une phase.';

  @override
  String get helpGotIt => 'Compris';

  @override
  String get seoDescription =>
      'WorkoutBell — entraînez-vous, reposez-vous, écoutez la cloche. Minuteur d\'intervalles HIIT et boxe avec tours, anneau coloré et alertes claires. Sans pub. Sans compte.';

  @override
  String get seoKeywords =>
      'minuteur entraînement, minuteur intervalle, minuteur HIIT, minuteur boxe, Tabata, circuit, repos, salle de sport, tour, fitness, training, exercice, arts martiaux, WorkoutBell';

  @override
  String get storeKeywords =>
      'minuteur,intervalle,HIIT,boxe,repos,tour,sport,circuit,tabata,fitness,entraînement,exercice,cloche';
}
