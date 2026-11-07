import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('zh'),
    Locale('zh', 'HK'),
    Locale('zh', 'TW'),
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'WorkoutBell'**
  String get appTitle;

  /// Label for round counter
  ///
  /// In en, this message translates to:
  /// **'Round'**
  String get round;

  /// Label for session start time
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get lessonStartTime;

  /// Label for workout time
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// Label for rest time
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// Abbreviation for minutes
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// Abbreviation for minutes with plural
  ///
  /// In en, this message translates to:
  /// **'min(s)'**
  String get mins;

  /// Tooltip for the help button
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Title of the help dialog
  ///
  /// In en, this message translates to:
  /// **'How to use'**
  String get helpTitle;

  /// Help text for play/pause
  ///
  /// In en, this message translates to:
  /// **'Play / Pause — tap the play button under the ring to start or pause.'**
  String get helpPlayPause;

  /// Help text for stop
  ///
  /// In en, this message translates to:
  /// **'Stop — tap to reset. Confirms only after you have completed at least one round.'**
  String get helpStop;

  /// Help text for workout control
  ///
  /// In en, this message translates to:
  /// **'Workout — use + / − to change workout duration (disabled while running).'**
  String get helpWorkout;

  /// Help text for rest control
  ///
  /// In en, this message translates to:
  /// **'Rest — use + / − to change rest duration (disabled while running).'**
  String get helpRest;

  /// Phase label when timer is idle at the start
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// Title for stop confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'Reset timer?'**
  String get confirmStopTitle;

  /// Body for stop confirmation dialog
  ///
  /// In en, this message translates to:
  /// **'This clears the current round and remaining time.'**
  String get confirmStopBody;

  /// Cancel button label
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirm reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Help text for start time
  ///
  /// In en, this message translates to:
  /// **'Started — long-press to show hours, minutes, and seconds.'**
  String get helpStartTime;

  /// Help text for round counter
  ///
  /// In en, this message translates to:
  /// **'Round — counts completed workout and rest cycles.'**
  String get helpRound;

  /// Help text for colors and sound
  ///
  /// In en, this message translates to:
  /// **'Green ring = workout. Red ring = rest. A bell sounds when a phase ends.'**
  String get helpColors;

  /// Dismiss button for help dialog
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get helpGotIt;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'ja', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.countryCode) {
          case 'HK':
            return AppLocalizationsZhHk();
          case 'TW':
            return AppLocalizationsZhTw();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
