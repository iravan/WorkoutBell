import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Keep screen on
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workout Timer',
      theme: ThemeData(primarySwatch: Colors.grey, useMaterial3: false),
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

    // Draw the arc
    final sweepAngle = 2 * math.pi * progress;
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

class _WorkoutTimerPageState extends State<WorkoutTimerPage> {
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

  final Color pauseColor = const Color.fromRGBO(242, 242, 242, 1.0);
  final Color textColor = const Color.fromRGBO(102, 102, 102, 1.0);
  Color circleColor = const Color.fromRGBO(242, 242, 242, 1.0);

  Timer? timer;
  AudioPlayer? audioPlayer;

  @override
  void initState() {
    super.initState();
    _loadPreferences().then((_) {
      _initializeAudio();
      _updateStartTime();
      _resetAll();
      _startTimer();
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      countDownFromIndex = prefs.getInt('count_down_index') ?? 0;
      restTimeFromIndex = prefs.getInt('rest_time_from_index') ?? 0;
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('count_down_index', countDownFromIndex);
    await prefs.setInt('rest_time_from_index', restTimeFromIndex);
  }

  Future<void> _initializeAudio() async {
    audioPlayer = AudioPlayer();
    // Note: You'll need to add a boxingbell.mp3 file to assets/sounds/
    // For now, we'll use a system sound as fallback
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

  (int, int) _shiftCountDownList(int index, List<double> list) {
    int returnIndex = index + 1;
    if (returnIndex >= list.length) {
      returnIndex = 0;
    }
    return (returnIndex, (list[returnIndex] * 60).toInt());
  }

  String _restTimeString(double restTime) {
    if (restTime < 1) {
      return restTime.toStringAsFixed(1);
    }
    return restTime.toInt().toString();
  }

  Future<void> _playSound() async {
    try {
      // Try to play boxingbell.mp3 from assets
      await audioPlayer?.play(AssetSource('sounds/boxingbell.mp3'));
    } catch (e) {
      // Fallback to system sound if asset not found
      HapticFeedback.mediumImpact();
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
        circleColor = pauseColor;
      }
    });
  }

  void _stopTimer() {
    setState(() {
      isRunning = false;
      circleColor = pauseColor;
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
          circleColor = const Color.fromRGBO(0, 255, 0, 1.0);
          timeRemainingText = _numberToDisplayTimeExact(timeRemaining);
          return;
        }

        if (!isRunning) {
          circleColor = pauseColor;
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
    timer?.cancel();
    audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Round counter and Start time display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Round counter
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Round",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Text(
                        "$round",
                        style: TextStyle(
                          color: textColor,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
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
                          "Lesson Start Time",
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
                ],
              ),

              const Spacer(),

              // Countdown timer text
              Text(
                timeRemainingText,
                style: TextStyle(
                  color: textColor,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(),

              // Circular progress with control buttons
              SizedBox(
                width: 300,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background circle
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: RoundedCircularProgressPainter(
                          progress: 1.0,
                          strokeWidth: 30,
                          color: const Color.fromRGBO(217, 217, 217, 1.0),
                          startAngle:
                              -math.pi / 2, // -90 degrees (rotated left)
                          outerRadius:
                              150.0, // Use full radius to extend outward
                        ),
                      ),
                    ),
                    // Progress circle
                    SizedBox(
                      width: 300,
                      height: 300,
                      child: CustomPaint(
                        painter: RoundedCircularProgressPainter(
                          progress: _ringTrimTo(),
                          strokeWidth: 25,
                          color: circleColor,
                          startAngle:
                              -math.pi / 2, // -90 degrees (rotated left)
                          outerRadius:
                              147.5, // Centered within background (150 - 15 + 12.5)
                        ),
                      ),
                    ),
                    // Control buttons in center
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Play/Pause button - centered
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _toggleRun,
                            borderRadius: BorderRadius.circular(50),
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(242, 242, 242, 1.0),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: textColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                isRunning ? Icons.pause : Icons.play_arrow,
                                color: textColor,
                                size: 40,
                              ),
                            ),
                          ),
                        ),
                        // Stop button (only visible when running) - positioned below
                        if (isRunning) ...[
                          const SizedBox(height: 16),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _stopTimer,
                              borderRadius: BorderRadius.circular(25),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: const Color.fromRGBO(
                                    242,
                                    242,
                                    242,
                                    1.0,
                                  ),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: textColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Icon(
                                  Icons.stop,
                                  color: textColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Workout and Rest time controls
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final result = _shiftCountDownList(
                            countDownFromIndex,
                            workoutTimeMinutesList,
                          );
                          setState(() {
                            countDownFromIndex = result.$1;
                            countDownFrom = result.$2;
                          });
                          _resetAll();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(242, 242, 242, 1.0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: textColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Workout",
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${workoutTimeMinutesList[countDownFromIndex].toInt()}",
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 4,
                                      left: 4,
                                    ),
                                    child: Text(
                                      "min",
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          final result = _shiftCountDownList(
                            restTimeFromIndex,
                            restTimeMinutesList,
                          );
                          setState(() {
                            restTimeFromIndex = result.$1;
                            restTimeFrom = result.$2;
                          });
                          _resetAll();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(242, 242, 242, 1.0),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: textColor.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Rest",
                                style: TextStyle(
                                  color: textColor.withOpacity(0.7),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _restTimeString(
                                      restTimeMinutesList[restTimeFromIndex],
                                    ),
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 4,
                                      left: 4,
                                    ),
                                    child: Text(
                                      "min",
                                      style: TextStyle(
                                        color: textColor.withOpacity(0.7),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
