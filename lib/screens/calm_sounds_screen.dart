import '../services/locale_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/calm_sound_service.dart';
import '../widgets/ad_native_widget.dart';

class CalmSoundsScreen extends StatefulWidget {
  const CalmSoundsScreen({super.key});

  @override
  State<CalmSoundsScreen> createState() => _CalmSoundsScreenState();
}

class _CalmSoundsScreenState extends State<CalmSoundsScreen> {
  final CalmSoundService _service = CalmSoundService();
  Timer? _sleepTimer;
  int _remainingSeconds = 0;
  bool _timerActive = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initService();
  }

  Future<void> _initService() async {
    await _service.init();
    if (mounted) {
      setState(() => _initialized = true);
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    // Don't dispose the service — it's a singleton
    super.dispose();
  }

  void _startTimer(int minutes) {
    _sleepTimer?.cancel();
    setState(() {
      _remainingSeconds = minutes * 60;
      _timerActive = true;
    });

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        _service.stopAll();
        if (mounted) {
          setState(() {
            _timerActive = false;
            _remainingSeconds = 0;
          });
          _showTimerComplete();
        }
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _cancelTimer() {
    _sleepTimer?.cancel();
    setState(() {
      _timerActive = false;
      _remainingSeconds = 0;
    });
  }

  void _showTimerComplete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('⏰ Time\'s Up'),
        content: const Text('Your sound session has ended. Hope you feel refreshed!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.get('ok')),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sounds = _initialized ? _service.sounds : [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calm Sounds'),
      ),
      body: _initialized
          ? ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Header ──
                Icon(Icons.headphones, size: 48, color: theme.colorScheme.primary),
                const SizedBox(height: 12),
                Text(
                  'Ambient Soundscapes',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Mix sounds to create your perfect calm environment',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),

                // ── Sound Cards ──
                ...sounds.map((sound) => _SoundCard(
                      sound: sound,
                      service: _service,
                      onChanged: () => setState(() {}),
                    )),
                const SizedBox(height: 28),

                // ── Native Ad ──
                const AdNativeWidget(),
                const SizedBox(height: 28),

                // ── Sleep Timer ──
                Text(
                  'Sleep Timer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 12),

                if (_timerActive) ...[
                  // Active timer display
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer, color: theme.colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Auto-stop in ${_formatTime(_remainingSeconds)}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        TextButton(
                          onPressed: _cancelTimer,
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Timer preset buttons
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: [
                      _TimerChip(
                        label: '15 min',
                        onTap: () => _startTimer(15),
                      ),
                      _TimerChip(
                        label: '30 min',
                        onTap: () => _startTimer(30),
                      ),
                      _TimerChip(
                        label: '45 min',
                        onTap: () => _startTimer(45),
                      ),
                      _TimerChip(
                        label: '60 min',
                        onTap: () => _startTimer(60),
                      ),
                      _TimerChip(
                        label: '90 min',
                        onTap: () => _startTimer(90),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 32),

                // ── Stop All Button ──
                if (_service.isAnyPlaying)
                  OutlinedButton.icon(
                    onPressed: () {
                      _service.stopAll();
                      _cancelTimer();
                      setState(() {});
                    },
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop All Sounds'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}

class _SoundCard extends StatelessWidget {
  final CalmSound sound;
  final CalmSoundService service;
  final VoidCallback onChanged;

  const _SoundCard({
    required this.sound,
    required this.service,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Top Row: Icon + Label + Play/Pause ──
            Row(
              children: [
                Text(sound.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sound.label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Play/Pause toggle
                GestureDetector(
                  onTap: () async {
                    await service.toggle(sound.type);
                    onChanged();
                  },
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: sound.isPlaying
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      sound.isPlaying ? Icons.pause : Icons.play_arrow,
                      color: sound.isPlaying
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),

            // ── Volume Slider ──
            Row(
              children: [
                const Icon(Icons.volume_down, size: 18, color: Colors.grey),
                Expanded(
                  child: Slider(
                    value: sound.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    activeColor: sound.isPlaying
                        ? theme.colorScheme.primary
                        : Colors.grey,
                    onChanged: (value) async {
                      await service.setVolume(sound.type, value);
                      onChanged();
                    },
                  ),
                ),
                const Icon(Icons.volume_up, size: 18, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimerChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimerChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      side: BorderSide.none,
    );
  }
}