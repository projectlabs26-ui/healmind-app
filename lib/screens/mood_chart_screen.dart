import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/mood.dart';
import '../models/mood_entry.dart';
import '../services/hive_service.dart';

class MoodChartScreen extends StatefulWidget {
  const MoodChartScreen({super.key});

  @override
  State<MoodChartScreen> createState() => _MoodChartScreenState();
}

class _MoodChartScreenState extends State<MoodChartScreen> {
  bool _isWeekly = true;
  List<MoodEntry> _moods = [];

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  void _loadMoods() {
    setState(() {
      _moods = HiveService.getAllMoods();
    });
  }

  // ─────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────

  static int moodScore(Mood m) {
    switch (m) {
      case Mood.great: return 5;
      case Mood.okay:  return 4;
      case Mood.tired: return 3;
      case Mood.sad:   return 2;
      case Mood.angry: return 1;
    }
  }

  static Color moodColor(Mood m) {
    switch (m) {
      case Mood.great: return const Color(0xFF4CAF50);
      case Mood.okay:  return const Color(0xFFFFC107);
      case Mood.tired: return const Color(0xFF9E9E9E);
      case Mood.sad:   return const Color(0xFF42A5F5);
      case Mood.angry: return const Color(0xFFEF5350);
    }
  }

  List<MoodEntry> filteredEntries() {
    final days = _isWeekly ? 7 : 30;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _moods.where((m) => m.date.isAfter(cutoff)).toList();
  }

  Map<Mood, int> distribution() {
    final map = <Mood, int>{};
    for (final m in Mood.values) { map[m] = 0; }
    for (final e in filteredEntries()) { map[e.mood] = (map[e.mood] ?? 0) + 1; }
    return map;
  }

  double avgScore() {
    final entries = filteredEntries();
    if (entries.isEmpty) return 0;
    return entries.map((e) => moodScore(e.mood)).reduce((a, b) => a + b) / entries.length;
  }

  Mood? mostCommonMood() {
    final dist = distribution();
    final max = dist.values.fold(0, (a, b) => a > b ? a : b);
    if (max == 0) return null;
    return dist.entries.firstWhere((e) => e.value == max).key;
  }

  // ─────────────────────────────────────────────────────────
  // Insights
  // ─────────────────────────────────────────────────────────

  List<_Insight> generateInsights() {
    final insights = <_Insight>[];
    final entries = filteredEntries();
    if (entries.length < 2) return insights;

    // Trend
    final half = entries.length ~/ 2;
    final firstHalf = entries.take(half).map((e) => moodScore(e.mood)).reduce((a, b) => a + b) / half;
    final secondHalf = entries.skip(half).map((e) => moodScore(e.mood)).reduce((a, b) => a + b) / (entries.length - half);
    final diff = (secondHalf - firstHalf).abs();

    if (diff > 0.5) {
      if (secondHalf > firstHalf) {
        insights.add(_Insight(emoji: '📈', text: 'Mood kamu sedang naik! Keep it up!'));
      } else {
        insights.add(_Insight(emoji: '📉', text: 'Mood kamu sedikit menurun. Coba latihan breathing atau CBT.'));
      }
    } else {
      insights.add(_Insight(emoji: '📊', text: 'Mood kamu stabil — bagus untuk kesehatan mental.'));
    }

    // Day of week
    final dayScores = <int, List<int>>{};
    for (final e in entries) {
      dayScores.putIfAbsent(e.date.weekday, () => []).add(moodScore(e.mood));
    }
    if (dayScores.length >= 2) {
      final averages = dayScores.map((k, v) => MapEntry(k, v.reduce((a, b) => a + b) / v.length));
      final bestDay = averages.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      final worstDay = averages.entries.reduce((a, b) => a.value < b.value ? a : b).key;
      const dayNames = {1: 'Senin', 2: 'Selasa', 3: 'Rabu', 4: 'Kamis', 5: 'Jumat', 6: 'Sabtu', 7: 'Minggu'};
      insights.add(_Insight(emoji: '🌟', text: 'Hari terbaik: ${dayNames[bestDay]} — ${dayNames[worstDay]} butuh perhatian lebih.'));
    }

    // Most common mood
    final common = mostCommonMood();
    if (common != null) {
      final emoji = common.emoji;
      insights.add(_Insight(emoji: emoji, text: 'Mood paling sering: ${common.emoji} ${common.label}'));
    }

    return insights;
  }

  // ─────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = filteredEntries();
    final streak = HiveService.getCurrentStreak();
    final avg = avgScore();
    final common = mostCommonMood();
    final insights = generateInsights();

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get('moodChart')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Toggle ──
          SegmentedButton<bool>(
            segments: [
              ButtonSegment(value: true, label: Text(L10n.get('weekly'))),
              ButtonSegment(value: false, label: Text(L10n.get('monthly'))),
            ],
            selected: {_isWeekly},
            onSelectionChanged: (v) => setState(() => _isWeekly = v.first),
          ),
          const SizedBox(height: 20),

          // ── Summary Cards ──
          Row(
            children: [
              _StatCard(icon: Icons.edit_note, value: '${filtered.length}', label: 'Entries', color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              _StatCard(icon: Icons.local_fire_department, value: '$streak', label: 'Streak', color: Colors.orange),
              const SizedBox(width: 10),
              _StatCard(icon: Icons.trending_up, value: avg > 0 ? avg.toStringAsFixed(1) : '-', label: 'Avg', color: Colors.green),
              const SizedBox(width: 10),
              _StatCard(icon: Icons.star, value: common?.emoji ?? '-', label: 'Most', color: Colors.amber),
            ],
          ),
          const SizedBox(height: 24),

          if (filtered.isEmpty)
            _EmptyState()
          else ...[
            // ── Distribution Pie Chart ──
            Text('Mood Distribution', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: _buildPieChart(),
            ),
            const SizedBox(height: 8),
            _buildPieLegend(),
            const SizedBox(height: 28),

            // ── Trend Bar Chart ──
            Text('${_isWeekly ? "Weekly" : "Monthly"} Trend', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: _buildTrendChart(theme),
            ),
            const SizedBox(height: 28),

            // ── Day of Week ──
            if (_moods.length >= 5) ...[
              Text('Mood by Day of Week', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: _buildDayOfWeekChart(theme),
              ),
              const SizedBox(height: 28),
            ],

            // ── Insights ──
            if (insights.isNotEmpty) ...[
              Text('Insights', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...insights.map((i) => _InsightCard(insight: i)),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Pie Chart
  // ─────────────────────────────────────────────────────────

  Widget _buildPieChart() {
    final dist = distribution();
    final total = dist.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    final sections = <PieChartSectionData>[];
    for (final mood in Mood.values) {
      final count = dist[mood] ?? 0;
      if (count == 0) continue;
      sections.add(PieChartSectionData(
        color: moodColor(mood),
        value: count.toDouble(),
        title: '${(count / total * 100).round()}%',
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 30,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildPieLegend() {
    final dist = distribution();
    final total = dist.values.fold(0, (a, b) => a + b);
    if (total == 0) return const SizedBox.shrink();

    return Wrap(
      spacing: 12,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: Mood.values.map((mood) {
        final count = dist[mood] ?? 0;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 10, height: 10, decoration: BoxDecoration(color: moodColor(mood), shape: BoxShape.circle)),
            const SizedBox(width: 4),
            Text('${mood.emoji} $count', style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Trend Bar Chart
  // ─────────────────────────────────────────────────────────

  Widget _buildTrendChart(ThemeData theme) {
    final days = _isWeekly ? 7 : 30;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final data = List.generate(days, (i) {
      final day = today.subtract(Duration(days: days - 1 - i));
      final entry = _moods.where((m) {
        final ed = DateTime(m.date.year, m.date.month, m.date.day);
        return ed == day;
      }).firstOrNull;
      return _DayPoint(
        label: _isWeekly ? ['M', 'T', 'W', 'T', 'F', 'S', 'S'][day.weekday - 1] : '${day.day}',
        score: entry != null ? moodScore(entry.mood).toDouble() : 0,
        mood: entry?.mood,
        isToday: day == today,
      );
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5.5,
        minY: 0,
        barGroups: data.asMap().entries.map((e) {
          final d = e.value;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: d.score,
                color: d.mood != null ? moodColor(d.mood!) : Colors.grey.shade200,
                width: _isWeekly ? 22 : 7,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              interval: _isWeekly ? 1 : 3,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                return Text(data[idx].label, style: TextStyle(fontSize: 10, fontWeight: data[idx].isToday ? FontWeight.bold : FontWeight.normal, color: data[idx].isToday ? theme.colorScheme.primary : Colors.grey));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 24,
              getTitlesWidget: (value, meta) {
                final labels = {1: '😡', 2: '😢', 3: '😴', 4: '😐', 5: '😊'};
                return Text(labels[value.toInt()] ?? '', style: const TextStyle(fontSize: 12));
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  // Day of Week Chart
  // ─────────────────────────────────────────────────────────

  Widget _buildDayOfWeekChart(ThemeData theme) {
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayScores = <int, List<int>>{};
    for (final e in _moods) {
      dayScores.putIfAbsent(e.date.weekday, () => []).add(moodScore(e.mood));
    }

    final data = List.generate(7, (i) {
      final weekday = i + 1;
      final scores = dayScores[weekday];
      return scores != null ? scores.reduce((a, b) => a + b) / scores.length : 0.0;
    });

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 5,
        minY: 0,
        barGroups: data.asMap().entries.map((e) {
          final val = e.value;
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: val,
                color: val >= 4 ? const Color(0xFF4CAF50) : val >= 3 ? const Color(0xFFFFC107) : const Color(0xFFEF5350),
                width: 18,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) => Text(dayNames[value.toInt()], style: const TextStyle(fontSize: 10)),
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (v) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayPoint {
  final String label;
  final double score;
  final Mood? mood;
  final bool isToday;
  const _DayPoint({required this.label, required this.score, required this.mood, required this.isToday});
}

class _Insight {
  final String emoji;
  final String text;
  const _Insight({required this.emoji, required this.text});
}

class _InsightCard extends StatelessWidget {
  final _Insight insight;
  const _InsightCard({required this.insight});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Text(insight.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(child: Text(insight.text, style: const TextStyle(fontSize: 14))),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          Icon(Icons.show_chart, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(L10n.get('noMoodData'), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}