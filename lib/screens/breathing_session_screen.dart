import '../services/locale_service.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/breathing_patterns.dart';
import '../models/breathing_session.dart';
import '../services/hive_service.dart';
import '../services/admob_service.dart';
import '../widgets/breathing_circle.dart';

class BreathingSessionScreen extends StatefulWidget {
  final BreathingPattern pattern;
  final int durationMinutes;

  const BreathingSessionScreen({
    super.key,
    required this.pattern,
    required this.durationMinutes,
  });

  @override
  State<BreathingSessionScreen> createState() => _BreathingSessionScreenState();
}

class _BreathingSessionScreenState extends State<BreathingSessionScreen>
    with TickerProviderStateMixin {
  late AnimationController _phaseController;
  late BreathingPhase _currentPhase;
  int _cyclesCompleted = 0;
  int _secondsRemaining = 0;
  bool _isPaused = false;
  bool _isComplete = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.durationMinutes * 60;
    _currentPhase = BreathingPhase.inhale;
    _initPhaseController();
    _startCountdown();
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _phaseController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _initPhaseController() {
    final seconds = _getPhaseSeconds(_currentPhase);
    _phaseController = AnimationController(
      vsync: this,
      duration: Duration(seconds: seconds),
    );

    _phaseController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isPaused && !_isComplete) {
        _advancePhase();
      }
    });

    _phaseController.forward();
  }

  void _advancePhase() {
    _phaseController.dispose();
    HapticFeedback.lightImpact();

    final nextPhase = _getNextPhase(_currentPhase, widget.pattern);
    if (nextPhase == BreathingPhase.inhale) {
      setState(() => _cyclesCompleted++);
    }

    setState(() => _currentPhase = nextPhase);
    _initPhaseController();
  }

  int _getPhaseSeconds(BreathingPhase phase) {
    switch (phase) {
      case BreathingPhase.inhale:
        return widget.pattern.inhaleSeconds;
      case BreathingPhase.hold:
        return widget.pattern.holdSeconds;
      case BreathingPhase.exhale:
        return widget.pattern.exhaleSeconds;
      case BreathingPhase.holdAfterExhale:
        return widget.pattern.holdAfterExhaleSeconds;
    }
  }

  BreathingPhase _getNextPhase(BreathingPhase current, BreathingPattern pattern) {
    switch (current) {
      case BreathingPhase.inhale:
        return BreathingPhase.hold;
      case BreathingPhase.hold:
        return BreathingPhase.exhale;
      case BreathingPhase.exhale:
        if (pattern.holdAfterExhaleSeconds > 0) {
          return BreathingPhase.holdAfterExhale;
        }
        return BreathingPhase.inhale;
      case BreathingPhase.holdAfterExhale:
        return BreathingPhase.inhale;
    }
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isPaused || _isComplete) return;
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          _completeSession();
        }
      });
    });
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
      if (_isPaused) {
        _phaseController.stop();
      } else {
        _phaseController.forward();
      }
    });
  }

  void _confirmEnd() {
    _phaseController.stop();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(L10n.get('endSession')),
        content: Text(L10n.get('confirmEndSession')),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _phaseController.forward();
            },
            child: Text(L10n.get('cancel')),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _saveSession();
              Navigator.pop(context);
            },
            child: Text(
              L10n.get('endSession'),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _completeSession() {
    setState(() => _isComplete = true);
    _phaseController.stop();
    _countdownTimer?.cancel();
    HapticFeedback.heavyImpact();
    _saveSession();
  }

  void _saveSession() {
    final session = BreathingSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      patternName: widget.pattern.name,
      durationMinutes: widget.durationMinutes,
      cyclesCompleted: _cyclesCompleted,
      completed: _isComplete,
    );
    HiveService.saveBreathingSession(session);
    AdMobService.trackBreathingAndShowInterstitial();
  }

  String _formatTime(int seconds) {
    final mins = seconds ~/ 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: _isComplete
          ? null
          : AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: _confirmEnd,
              ),
            ),
      body: SafeArea(
        child: _isComplete ? _buildCompleteScreen(theme) : _buildSessionScreen(theme),
      ),
    );
  }

  Widget _buildSessionScreen(ThemeData theme) {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Breathing circle
        AnimatedBuilder(
          animation: _phaseController,
          builder: (context, _) {
            return BreathingCircle(
              animationValue: _phaseController.value,
              phase: _currentPhase,
              pattern: widget.pattern,
            );
          },
        ),

        const Spacer(),

        // Timer
        Text(
          _formatTime(_secondsRemaining),
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w200,
            letterSpacing: 4,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$_cyclesCompleted cycles',
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
        const SizedBox(height: 24),

        // Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pause / Resume
            IconButton.filled(
              onPressed: _togglePause,
              iconSize: 32,
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundColor: theme.colorScheme.primary,
                minimumSize: const Size(64, 64),
              ),
            ),
            const SizedBox(width: 24),
            // End session
            IconButton(
              onPressed: _confirmEnd,
              iconSize: 28,
              icon: const Icon(Icons.stop),
              style: IconButton.styleFrom(
                foregroundColor: Colors.red.shade300,
                minimumSize: const Size(56, 56),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildCompleteScreen(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          // Checkmark
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primaryContainer,
            ),
            child: Icon(
              Icons.check,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            L10n.get('sessionComplete'),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            L10n.get('sessionCompleteDesc'),
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),

          // Stats card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _StatItem(
                    icon: Icons.repeat,
                    value: '$_cyclesCompleted',
                    label: L10n.get('cyclesCompleted'),
                  ),
                  _StatItem(
                    icon: Icons.timer,
                    value: '${widget.durationMinutes} ${L10n.get('minAbbr')}',
                    label: L10n.get('totalTime'),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
            ),
            child: Text(L10n.get('done')),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
        ),
      ],
    );
  }
}