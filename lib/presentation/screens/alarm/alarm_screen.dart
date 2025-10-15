import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../core/services/notification_service.dart';

class AlarmScreen extends StatefulWidget {
  final String taskTitle;
  final String taskId;

  const AlarmScreen({super.key, required this.taskTitle, required this.taskId});

  @override
  State<AlarmScreen> createState() => _AlarmScreenState();
}

class _AlarmScreenState extends State<AlarmScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _playAlarmSound();
  }

  void _setupAnimations() {
    // انیمیشن پالس (نبض)
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // انیمیشن تکان خوردن
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // شروع انیمیشن‌ها
    _pulseController.repeat(reverse: true);
    _shakeController.repeat(reverse: true);
  }

  Future<void> _playAlarmSound() async {
    try {
      if (!_isPlaying) {
        setState(() {
          _isPlaying = true;
        });

        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource('sounds/alarm_sound.mp3'));
        debugPrint('صدای آلارم شروع شد');
      }
    } catch (e) {
      debugPrint('خطا در پخش صدای آلارم: $e');
    }
  }

  Future<void> _stopAlarm() async {
    await _audioPlayer.stop();
    await NotificationService.cancelNotification(widget.taskId);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _snoozeAlarm() async {
    await _audioPlayer.stop();
    await NotificationService.cancelNotification(widget.taskId);

    // تنظیم آلارم برای 5 دقیقه بعد
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));
    await NotificationService.showNotification(
      id: '${widget.taskId}_snooze',
      title: widget.taskTitle,
      scheduledDate: snoozeTime,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shakeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade900,
      body: SafeArea(
        child: Column(
          children: [
            // نمایش زمان فعلی
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'آلارم',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getCurrentTime(),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // انیمیشن آیکون آلارم
            Expanded(
              child: Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseAnimation,
                    _shakeAnimation,
                  ]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Transform.translate(
                        offset: Offset(_shakeAnimation.value, 0),
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.2),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: const Icon(
                            Icons.alarm,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // نمایش عنوان تسک
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.taskTitle,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // دکمه‌های کنترل
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // دکمه چرت
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _snoozeAlarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'چرت (5 دقیقه)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // دکمه قطع
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _stopAlarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'قطع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
