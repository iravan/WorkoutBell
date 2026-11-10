// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'ワークアウトタイマー';

  @override
  String get round => 'ラウンド';

  @override
  String get lessonStartTime => '開始';

  @override
  String get workout => 'ワークアウト';

  @override
  String get rest => '休息';

  @override
  String get min => '分';

  @override
  String get mins => '分';

  @override
  String get help => 'ヘルプ';

  @override
  String get helpTitle => '使い方';

  @override
  String get helpPlayPause => '再生 / 一時停止 — リング下のボタンで開始または一時停止します。';

  @override
  String get helpStop => '停止 — タップでリセット。1ラウンド以上完了後のみ確認します。';

  @override
  String get helpWorkout => 'ワークアウト — + / − で時間を変更（実行中は変更不可）。';

  @override
  String get helpRest => '休息 — + / − で時間を変更（実行中は変更不可）。';

  @override
  String get ready => '準備完了';

  @override
  String get confirmStopTitle => 'タイマーをリセットしますか？';

  @override
  String get confirmStopBody => '現在のラウンドと残り時間をクリアします。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get reset => 'リセット';

  @override
  String get helpStartTime => '開始 — 長押しで時・分・秒を表示します。';

  @override
  String get helpRound => 'ラウンド — 完了したワークアウトと休息のサイクル数です。';

  @override
  String get helpColors => '緑のリング = ワークアウト。赤のリング = 休息。フェーズ終了時にベルが鳴ります。';

  @override
  String get helpGotIt => '閉じる';

  @override
  String get seoDescription =>
      'WorkoutBell — トレーニング、休憩、ベルで知らせ。ラウンド・カラーリング・明確な通知付きの無料HIIT／ボクシング用インターバルタイマー。広告なし。アカウント不要。';

  @override
  String get seoKeywords =>
      'ワークアウトタイマー, インターバルタイマー, HIITタイマー, ボクシングタイマー, タバタ, サーキット, 休憩タイマー, ジムタイマー, ラウンド, フィットネス, トレーニング, 運動, 格闘技, WorkoutBell';

  @override
  String get storeKeywords =>
      'ワークアウト,インターバル,HIIT,ボクシング,休憩,ラウンド,ジム,サーキット,タバタ,フィットネス,トレーニング,運動,ベル';
}
