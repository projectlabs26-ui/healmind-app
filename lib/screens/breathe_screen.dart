import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import '../constants/breathing_patterns.dart';
import '../models/breathing_session.dart';
import '../services/hive_service.dart';
import '../widgets/breathing_pattern_selector.dart';
import '../widgets/session_timer_picker.dart';
import '../widgets/ad_banner_widget.dart';
import 'breathing_session_screen.dart';
import 'calm_sounds_screen.dart';

class BreatheScreen extends StatefulWidget {
  const BreatheScreen({super.key});

  @override
  State<BreatheScreen> createState() => _BreatheScreenState();
}

class _BreatheScreenState extends State<BreatheScreen> {
  BreathingPattern _selectedPattern = breathingPatterns[0];
  int _selectedDuration = 3;
  List<BreathingSession> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _history = HiveService.getAllBreathingSessions();
    });
  }

  void _startSession() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreathingSessionScreen(
          pattern: _selectedPattern,
          durationMinutes: _selectedDuration,
        ),
      ),
    ).then((_) => _loadHistory());
  }

  void _startQuickSession() {
    // Quick 1-minute deep belly breathing
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreathingSessionScreen(
          pattern: breathingPatterns[2], // Deep Belly
          durationMinutes: 1,
        ),
      ),
    ).then((_) => _loadHistory());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get('breathing')),
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: _showHistory,
              tooltip: L10n.get('breathingHistory'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header ──
          Icon(
            Icons.air,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          Text(
            L10n.get('guidedBreathing'),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            L10n.get('breatheSubtitle'),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),

          // ── Quick Start (Panic Button) ──
          GestureDetector(
            onTap: _startQuickSession,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.secondaryContainer,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.self_improvement, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    L10n.get('panicButtonDesc'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Pattern Selector ──
          BreathingPatternSelector(
            selectedPattern: _selectedPattern,
            onPatternSelected: (pattern) {
              setState(() => _selectedPattern = pattern);
            },
          ),
          const SizedBox(height: 24),

          // ── Duration Picker ──
          SessionTimerPicker(
            selectedDuration: _selectedDuration,
            onDurationSelected: (duration) {
              setState(() => _selectedDuration = duration);
            },
          ),
          const SizedBox(height: 32),

          // ── Start Button ──
          FilledButton.icon(
            onPressed: _startSession,
            icon: const Icon(Icons.play_arrow),
            label: Text(
              '${L10n.get('startSession')} ($_selectedDuration ${L10n.get('minAbbr')})',
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 56),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 24),

          // ── Calm Sounds ──
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalmSoundsScreen()),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.tertiaryContainer,
                    theme.colorScheme.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.headphones, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    L10n.get('calmSoundsDesc'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),

          // ── Session Stats ──
          if (_history.isNotEmpty) ...[
            Text(
              L10n.get('yourStats'),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _StatCard(
                  icon: Icons.fitness_center,
                  value: '${_history.length}',
                  label: L10n.get('sessions'),
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.timer,
                  value: '${_history.fold<int>(0, (sum, s) => sum + s.durationMinutes)}',
                  label: L10n.get('totalMin'),
                  theme: theme,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  icon: Icons.repeat,
                  value: '${_history.fold<int>(0, (sum, s) => sum + s.cyclesCompleted)}',
                  label: L10n.get('cycles'),
                  theme: theme,
                ),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: const AdBannerWidget(),
    );
  }

  void _showHistory() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (ctx, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    L10n.get('breathingHistory'),
                    style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _history.isEmpty
                        ? Center(
                            child: Text(
                              L10n.get('noBreathingSessions'),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: _history.length,
                            separatorBuilder: (_, _) => const Divider(),
                            itemBuilder: (_, i) {
                              final s = _history[i];
                              return ListTile(
                                leading: const Icon(Icons.air),
                                title: Text(s.patternName),
                                subtitle: Text(
                                  '${s.durationMinutes} min · ${s.cyclesCompleted} cycles',
                                ),
                                trailing: Text(
                                  _formatDate(s.date),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDay = DateTime(date.year, date.month, date.day);
    final diff = today.difference(entryDay).inDays;
    if (diff == 0) return L10n.get('today');
    if (diff == 1) return L10n.get('yesterday');
    return '${entryDay.day}/${entryDay.month}';
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final ThemeData theme;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}