import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../constants/affirmations.dart';
import '../models/mood_entry.dart';
import '../services/hive_service.dart';
import '../widgets/affirmation_card.dart';
import '../widgets/streak_badge.dart';
import 'mood_check_screen.dart';
import 'journal_screen.dart';
import 'mood_chart_screen.dart';
import 'breathing_session_screen.dart';
import '../constants/breathing_patterns.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<bool>? onDarkModeChanged;

  const HomeScreen({super.key, this.onDarkModeChanged});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MoodEntry? _todayMood;
  int _affirmationIndex = 0;
  int _streak = 0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _checkRatingPrompt();
  }

  void _checkRatingPrompt() {
    final settings = HiveService.getSettings();
    final firstLaunch = settings.firstLaunchDate;
    if (firstLaunch == null) return;

    final daysSinceLaunch = DateTime.now().difference(firstLaunch).inDays;
    if (daysSinceLaunch < 7) return;

    final lastPrompt = settings.lastRatingPromptDate;
    if (lastPrompt != null) {
      final daysSinceLastPrompt = DateTime.now().difference(lastPrompt).inDays;
      if (daysSinceLastPrompt < 30) return; // Don't ask more than once per month
    }

    // Show rating prompt after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRatingPrompt();
    });
  }

  void _showRatingPrompt() {
    final settings = HiveService.getSettings();
    settings.lastRatingPromptDate = DateTime.now();
    HiveService.saveSettings(settings);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            Text(L10n.get('rateTitle')),
          ],
        ),
        content: Text(L10n.get('rateMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(L10n.get('rateLater')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${L10n.get('thankYou')} ⭐')),
              );
            },
            child: Text('${L10n.get('rateNow')} ⭐'),
          ),
        ],
      ),
    );
  }

  void _refreshData() {
    final settings = HiveService.getSettings();
    final now = DateTime.now();
    _todayMood = HiveService.getMoodForDay(now);
    _streak = HiveService.getCurrentStreak();
    _affirmationIndex = settings.lastAffirmationIndex;
    _isFavorite = settings.favoriteAffirmations
        .contains(affirmations[_affirmationIndex]);
    setState(() {});
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return L10n.get('greetingMorning');
    if (hour < 17) return L10n.get('greetingAfternoon');
    return L10n.get('greetingEvening');
  }

  void _nextAffirmation() {
    final settings = HiveService.getSettings();
    final nextIndex = (_affirmationIndex + 1) % affirmations.length;
    settings.lastAffirmationIndex = nextIndex;
    HiveService.saveSettings(settings);
    setState(() {
      _affirmationIndex = nextIndex;
      _isFavorite = settings.favoriteAffirmations
          .contains(affirmations[nextIndex]);
    });
  }

  void _toggleFavorite() {
    final settings = HiveService.getSettings();
    final text = affirmations[_affirmationIndex];
    if (settings.favoriteAffirmations.contains(text)) {
      settings.favoriteAffirmations.remove(text);
    } else {
      settings.favoriteAffirmations.add(text);
    }
    HiveService.saveSettings(settings);
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getGreeting(),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MoodChartScreen(),
                ),
              );
            },
            tooltip: L10n.get('moodChart'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Streak & Mood Status Row ──
            Row(
              children: [
                StreakBadge(streak: _streak),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildMoodStatusCard(theme),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Affirmation Card ──
            Text(
              L10n.get('todayAffirmation'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            AffirmationCard(
              affirmation: affirmations[_affirmationIndex],
              onNext: _nextAffirmation,
              onFavorite: _toggleFavorite,
              isFavorite: _isFavorite,
            ),
            const SizedBox(height: 20),

            // ── Quick Actions ──
            Text(
              L10n.get('quickActions'),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.mood,
                    label: L10n.get('checkIn'),
                    color: AppColors.primary,
                    onTap: () => _openMoodCheck(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.book,
                    label: L10n.get('navJournal'),
                    color: AppColors.secondary,
                    onTap: () => _openJournal(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.air,
                    label: L10n.get('panicBreathing'),
                    color: const Color(0xFF64B5F6),
                    onTap: () => _openPanicBreathing(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 80), // Space for banner
          ],
        ),
      ),
    );
  }

  Widget _buildMoodStatusCard(ThemeData theme) {
    return Card(
      child: InkWell(
        onTap: () => _openMoodCheck(),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              if (_todayMood != null) ...[
                Text(_todayMood!.mood.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'You feel ${_todayMood!.mood.label}',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_todayMood!.note != null && _todayMood!.note!.isNotEmpty)
                        Text(
                          _todayMood!.note!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
              ] else ...[
                const Icon(Icons.add_circle_outline, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    L10n.get('tapToCheckIn'),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  void _openMoodCheck() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const MoodCheckScreen()),
    );
    if (result == true) {
      _refreshData();
    }
  }

  void _openJournal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const JournalScreen()),
    );
  }

  void _openPanicBreathing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BreathingSessionScreen(
          pattern: breathingPatterns[2], // Deep Belly
          durationMinutes: 1,
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}