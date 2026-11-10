import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:workout_bell/l10n/app_localizations.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

Future<void> _enableWakelockSafely() async {
  try {
    await WakelockPlus.enable();
  } catch (_) {
    // Unsupported or denied on some browsers / platforms.
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    // Never block web startup on wakelock (mobile Safari can hang / fail).
    unawaited(_enableWakelockSafely());
  } else {
    await _enableWakelockSafely();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkoutBell',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: false,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.grey,
          secondary: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: false,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.grey,
          secondary: Colors.grey,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      themeMode:
          ThemeMode.system, // Automatically switch based on system settings
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('fr'), // French
        Locale('zh'), // Chinese (Simplified)
        Locale('zh', 'TW'), // Chinese (Traditional - Taiwan)
        Locale('zh', 'HK'), // Chinese (Traditional - Hong Kong)
        Locale('ja'), // Japanese
      ],
      home: const WorkoutTimerPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RoundedCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;
  final double startAngle;
  final double? outerRadius; // Optional outer radius for background circle

  RoundedCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
    required this.startAngle,
    this.outerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // If outerRadius is specified, use it; otherwise calculate normally
    final radius = outerRadius != null
        ? outerRadius! - (strokeWidth / 2)
        : (size.width / 2) - (strokeWidth / 2);

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Negative sweep = clockwise from 12 o'clock (Flutter arcs are CCW by default)
    final sweepAngle = -2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(RoundedCircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.outerRadius != outerRadius;
  }
}

class WorkoutTimerPage extends StatefulWidget {
  const WorkoutTimerPage({super.key});

  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}

class _WorkoutTimerPageState extends State<WorkoutTimerPage>
    with WidgetsBindingObserver {
  final List<double> workoutTimeMinutesList = [1, 2, 3, 4, 5, 10, 15, 30];
  final List<double> restTimeMinutesList = [0.5, 1, 2, 3, 4, 5, 10];

  int countDownFrom = 0;
  int restTimeFrom = 0;
  int countDownFromIndex = 0;
  int restTimeFromIndex = 0;
  int timeRemaining = 0;
  int restTimeRemaining = 0;
  String timeRemainingText = "";
  bool isRunning = false;
  bool isResetting = false;
  int round = 0;
  String startTime = "";

  // Theme-aware color getters
  Color get pauseColor => Theme.of(context).brightness == Brightness.dark
      ? const Color.fromRGBO(60, 60, 60, 1.0)
      : const Color.fromRGBO(242, 242, 242, 1.0);

  Color get textColor => Theme.of(context).brightness == Brightness.dark
      ? const Color.fromRGBO(200, 200, 200, 1.0)
      : const Color.fromRGBO(102, 102, 102, 1.0);

  Color get backgroundColor => Theme.of(context).brightness == Brightness.dark
      ? const Color.fromRGBO(40, 40, 40, 1.0)
      : const Color.fromRGBO(217, 217, 217, 1.0);

  Color get buttonBackgroundColor =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color.fromRGBO(60, 60, 60, 1.0)
      : const Color.fromRGBO(242, 242, 242, 1.0);

  Color get cardBackgroundColor =>
      Theme.of(context).brightness == Brightness.dark
      ? const Color.fromRGBO(40, 40, 40, 1.0)
      : const Color.fromRGBO(242, 242, 242, 1.0);

  Color circleColor = const Color.fromRGBO(242, 242, 242, 1.0);

  Timer? timer;
  AudioPlayer? audioPlayer;
  /// After screen lock, mobile browsers often need a tap before audio works.
  bool _audioNeedsPrime = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPreferences().then((_) {
      _initializeAudio();
      _updateStartTime();
      _resetAll();
      _startTimer();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      unawaited(_enableWakelockSafely());
      // Mobile web suspends AudioContext while the screen is locked; rebuild
      // the player on resume so the next phase bell can play again.
      _audioNeedsPrime = kIsWeb;
      unawaited(_initializeAudio());
    }
  }

  void _primeAudioAfterUnlock() {
    if (!_audioNeedsPrime) return;
    _audioNeedsPrime = false;
    unawaited(_initializeAudio());
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      countDownFromIndex =
          prefs.getInt('count_down_index') ??
          2; // Default to 3 minutes (index 2)
      restTimeFromIndex =
          prefs.getInt('rest_time_from_index') ??
          1; // Default to 1 minute (index 1)
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_down_index', countDownFromIndex);
    await prefs.setInt('rest_time_from_index', restTimeFromIndex);
  }

  Future<void> _initializeAudio() async {
    try {
      await audioPlayer?.dispose();
    } catch (_) {}
    audioPlayer = null;

    try {
      final player = AudioPlayer();
      // mediaPlayer keeps the session suitable for short alert sounds.
      await player.setPlayerMode(PlayerMode.mediaPlayer);
      await player.setReleaseMode(ReleaseMode.stop);
      // Preload so the first play after unlock does not race source load.
      await player.setSource(AssetSource('sounds/boxingbell.mp3'));
      audioPlayer = player;
    } catch (_) {
      // Audio may be unavailable until a user gesture on mobile web.
      audioPlayer = null;
    }
  }

  void _updateStartTime() {
    final now = DateTime.now();
    setState(() {
      startTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    });
  }

  String _numberToDisplayTime(int num) {
    final countDown = num - 1;
    if (countDown == 0) {
      _playSound();
    }

    if (countDown < 60) {
      return countDown.toString();
    }

    final minutes = countDown ~/ 60;
    final seconds = countDown % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  String _numberToDisplayTimeExact(int num) {
    // Display exact time without subtracting 1 (for reset/initial display)
    if (num < 60) {
      return num.toString();
    }

    final minutes = num ~/ 60;
    final seconds = num % 60;
    return "$minutes:${seconds.toString().padLeft(2, '0')}";
  }

  double _ringTrimTo() {
    if (timeRemaining > 0) {
      return timeRemaining / countDownFrom;
    }
    if (restTimeRemaining > 0) {
      return restTimeRemaining / restTimeFrom;
    }
    return 1.0;
  }

  void _resetAll() {
    setState(() {
      round = 0;
      circleColor = pauseColor;
      countDownFrom = (workoutTimeMinutesList[countDownFromIndex] * 60).toInt();
      restTimeFrom = (restTimeMinutesList[restTimeFromIndex] * 60).toInt();
      timeRemaining = countDownFrom;
      restTimeRemaining = restTimeFrom;
      isResetting = true;
      isRunning = false;
      timeRemainingText = _numberToDisplayTimeExact(timeRemaining);
    });
    _savePreferences();
  }

  void _updateCircleColor() {
    if (!mounted) return;
    if (!isRunning) {
      circleColor = pauseColor;
    } else if (timeRemaining > 0) {
      circleColor = const Color.fromRGBO(0, 255, 0, 1.0); // Green for workout
    } else if (restTimeRemaining > 0) {
      circleColor = const Color.fromRGBO(255, 0, 0, 1.0); // Red for rest
    } else {
      circleColor = pauseColor;
    }
  }

  (int, int) _shiftCountDownList(int index, List<double> list, {int delta = 1}) {
    final returnIndex = (index + delta) % list.length;
    final safeIndex = returnIndex < 0 ? returnIndex + list.length : returnIndex;
    return (safeIndex, (list[safeIndex] * 60).toInt());
  }

  void _nudgeDuration({required bool workout, required int delta}) {
    if (isRunning) return;
    if (workout) {
      countDownFromIndex = _shiftCountDownList(
        countDownFromIndex,
        workoutTimeMinutesList,
        delta: delta,
      ).$1;
    } else {
      restTimeFromIndex = _shiftCountDownList(
        restTimeFromIndex,
        restTimeMinutesList,
        delta: delta,
      ).$1;
    }
    _resetAll();
  }

  bool get _canReset =>
      isRunning ||
      round > 0 ||
      timeRemaining != countDownFrom ||
      restTimeRemaining != restTimeFrom;

  String _restTimeString(double restTime) {
    if (restTime < 1) {
      return restTime.toStringAsFixed(1);
    }
    return restTime.toInt().toString();
  }

  String _phaseLabel(AppLocalizations l10n) {
    if (!isRunning &&
        timeRemaining == countDownFrom &&
        restTimeRemaining == restTimeFrom &&
        round == 0) {
      return l10n.ready;
    }
    if (timeRemaining > 0) return l10n.workout;
    if (restTimeRemaining > 0) return l10n.rest;
    return l10n.ready;
  }

  Color get _phaseTextColor {
    if (timeRemaining > 0 && (isRunning || round > 0 || timeRemaining != countDownFrom)) {
      return const Color.fromRGBO(0, 170, 80, 1.0);
    }
    if (timeRemaining == 0 && restTimeRemaining > 0) {
      return const Color.fromRGBO(220, 70, 70, 1.0);
    }
    return textColor.withValues(alpha: 0.75);
  }

  Future<void> _onStopPressed(BuildContext context, AppLocalizations l10n) async {
    if (!_canReset) return;
    // Confirm only after progress matters (completed rounds).
    if (round == 0) {
      _stopTimer();
      return;
    }
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmStopTitle),
        content: Text(l10n.confirmStopBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.reset),
          ),
        ],
      ),
    );
    if (shouldReset == true) _stopTimer();
  }

  Widget _durationCard({
    required String label,
    required String value,
    required bool enabled,
    required VoidCallback onDecrease,
    required VoidCallback onIncrease,
  }) {
    final buttonColor = textColor.withValues(alpha: enabled ? 1 : 0.35);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: enabled ? onDecrease : null,
            icon: Icon(Icons.remove, color: buttonColor),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: value,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextSpan(
                        text: ' ${AppLocalizations.of(context)!.min}',
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: enabled ? onIncrease : null,
            icon: Icon(Icons.add, color: buttonColor),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required VoidCallback? onTap,
    required double size,
    required double iconSize,
    bool primary = false,
  }) {
    final enabled = onTap != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fill = isDark ? const Color(0xFFE8E8E8) : const Color(0xFF2C2C2C);
    final iconColor = primary
        ? (isDark ? const Color(0xFF121212) : Colors.white)
        : textColor.withValues(alpha: enabled ? 0.85 : 0.35);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(size / 2),
        child: Opacity(
          opacity: enabled || primary ? 1 : 0.45,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: primary ? fill : Colors.transparent,
              shape: BoxShape.circle,
              border: primary
                  ? null
                  : Border.all(
                      color: textColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ),
      ),
    );
  }

  Future<void> _playSound() async {
    try {
      if (audioPlayer == null) {
        await _initializeAudio();
      }
      final player = audioPlayer;
      if (player == null) {
        HapticFeedback.mediumImpact();
        return;
      }
      // stop + play resumes a suspended web AudioContext when possible.
      await player.stop();
      await player.play(AssetSource('sounds/boxingbell.mp3'));
    } catch (_) {
      try {
        await _initializeAudio();
        await audioPlayer?.play(AssetSource('sounds/boxingbell.mp3'));
      } catch (_) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  void _toggleRun() {
    setState(() {
      isRunning = !isRunning;
      if (isRunning) {
        // Immediately update the display when starting
        if (timeRemaining > 0) {
          circleColor = const Color.fromRGBO(0, 255, 0, 1.0);
          timeRemainingText = _numberToDisplayTime(timeRemaining);
          _playSound();
        } else if (restTimeRemaining > 0) {
          circleColor = const Color.fromRGBO(255, 0, 0, 1.0);
          timeRemainingText = _numberToDisplayTime(restTimeRemaining);
        }
      } else {
        _updateCircleColor();
      }
    });
  }

  void _stopTimer() {
    setState(() {
      isRunning = false;
      _updateCircleColor();
      timeRemaining = countDownFrom;
      restTimeRemaining = restTimeFrom;
      round = 0;
      timeRemainingText = _numberToDisplayTimeExact(timeRemaining);
    });
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;

      setState(() {
        if (isResetting) {
          isResetting = false;
          isRunning = false;
          _updateCircleColor();
          timeRemainingText = _numberToDisplayTimeExact(timeRemaining);
          return;
        }

        if (!isRunning) {
          _updateCircleColor();
          return;
        }

        if (timeRemaining > 0) {
          circleColor = const Color.fromRGBO(0, 255, 0, 1.0);
          timeRemainingText = _numberToDisplayTime(timeRemaining);
          timeRemaining--;
          if (timeRemaining == 0) {
            circleColor = const Color.fromRGBO(255, 0, 0, 1.0);
          }
          return;
        }

        if (restTimeRemaining > 0) {
          circleColor = const Color.fromRGBO(255, 0, 0, 1.0);
          timeRemainingText = _numberToDisplayTime(restTimeRemaining);
          restTimeRemaining--;
          if (restTimeRemaining == 0) {
            circleColor = const Color.fromRGBO(0, 255, 0, 1.0);
          }
          return;
        }

        if (restTimeRemaining == 0 && timeRemaining == 0) {
          timeRemaining = countDownFrom;
          restTimeRemaining = restTimeFrom;
          round++;
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    timer?.cancel();
    audioPlayer?.dispose();
    // Note: We keep wakelock enabled even after dispose since this is a workout timer app
    // The wakelock will be automatically released when the app is closed
    super.dispose();
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.helpTitle),
        content: SingleChildScrollView(
          child: Text(
            [
              l10n.helpPlayPause,
              l10n.helpStop,
              l10n.helpWorkout,
              l10n.helpRest,
              l10n.helpStartTime,
              l10n.helpRound,
              l10n.helpColors,
            ].join('\n\n'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.helpGotIt),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _primeAudioAfterUnlock(),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Round counter, start time, and help
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Round counter
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.round,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          round == 0 ? "–" : "$round",
                          style: TextStyle(
                            color: textColor,
                            fontSize: 34,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Start time display
                  GestureDetector(
                    onLongPress: () {
                      final now = DateTime.now();
                      setState(() {
                        startTime =
                            "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
                      });
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.lessonStartTime,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          startTime,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 34,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.help,
                    onPressed: () => _showHelpDialog(context, l10n),
                    icon: Icon(Icons.help_outline, color: textColor),
                  ),
                ],
              ),

              const Spacer(),

              // Ring = status; controls sit underneath
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(300, 300),
                      painter: RoundedCircularProgressPainter(
                        progress: 1.0,
                        strokeWidth: 30,
                        color: backgroundColor,
                        startAngle: -math.pi / 2,
                        outerRadius: 150.0,
                      ),
                    ),
                    CustomPaint(
                      size: const Size(300, 300),
                      painter: RoundedCircularProgressPainter(
                        progress: _ringTrimTo(),
                        strokeWidth: 25,
                        color: circleColor,
                        startAngle: -math.pi / 2,
                        outerRadius: 147.5,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _phaseLabel(l10n).toUpperCase(),
                          style: TextStyle(
                            color: _phaseTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          timeRemainingText,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlButton(
                    icon: isRunning ? Icons.pause : Icons.play_arrow,
                    onTap: _toggleRun,
                    size: 76,
                    iconSize: 38,
                    primary: true,
                  ),
                  const SizedBox(width: 28),
                  _controlButton(
                    icon: Icons.stop,
                    onTap: _canReset
                        ? () => _onStopPressed(context, l10n)
                        : null,
                    size: 56,
                    iconSize: 26,
                  ),
                ],
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: _durationCard(
                      label: l10n.workout,
                      value:
                          "${workoutTimeMinutesList[countDownFromIndex].toInt()}",
                      enabled: !isRunning,
                      onDecrease: () =>
                          _nudgeDuration(workout: true, delta: -1),
                      onIncrease: () =>
                          _nudgeDuration(workout: true, delta: 1),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _durationCard(
                      label: l10n.rest,
                      value: _restTimeString(
                        restTimeMinutesList[restTimeFromIndex],
                      ),
                      enabled: !isRunning,
                      onDecrease: () =>
                          _nudgeDuration(workout: false, delta: -1),
                      onIncrease: () =>
                          _nudgeDuration(workout: false, delta: 1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
