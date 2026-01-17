// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '锻炼计时器';

  @override
  String get round => '轮次';

  @override
  String get lessonStartTime => '课程开始时间';

  @override
  String get workout => '锻炼';

  @override
  String get rest => '休息';

  @override
  String get min => '分钟';

  @override
  String get mins => '分钟';
}

/// The translations for Chinese, as used in Hong Kong (`zh_HK`).
class AppLocalizationsZhHk extends AppLocalizationsZh {
  AppLocalizationsZhHk() : super('zh_HK');

  @override
  String get appTitle => '鍛鍊計時器';

  @override
  String get round => '輪次';

  @override
  String get lessonStartTime => '課程開始時間';

  @override
  String get workout => '鍛鍊';

  @override
  String get rest => '休息';

  @override
  String get min => '分鐘';

  @override
  String get mins => '分鐘';
}

/// The translations for Chinese, as used in Taiwan (`zh_TW`).
class AppLocalizationsZhTw extends AppLocalizationsZh {
  AppLocalizationsZhTw() : super('zh_TW');

  @override
  String get appTitle => '鍛鍊計時器';

  @override
  String get round => '輪次';

  @override
  String get lessonStartTime => '課程開始時間';

  @override
  String get workout => '鍛鍊';

  @override
  String get rest => '休息';

  @override
  String get min => '分鐘';

  @override
  String get mins => '分鐘';
}
