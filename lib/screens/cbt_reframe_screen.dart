import '../services/locale_service.dart';
import 'package:flutter/material.dart';
import '../models/cbt_entry.dart';
import '../services/hive_service.dart';
import '../services/admob_service.dart';
import '../widgets/distortion_checklist.dart';
import '../widgets/intensity_slider.dart';

/// 4-step CBT reframe wizard.
class CBTReframeScreen extends StatefulWidget {
  final CBTEntry? existingEntry;

  const CBTReframeScreen({super.key, this.existingEntry});

  @override
  State<CBTReframeScreen> createState() => _CBTReframeScreenState();
}

class _CBTReframeScreenState extends State<CBTReframeScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1: Thought
  final _thoughtController = TextEditingController();

  // Step 2: Distortions
  List<String> _selectedDistortions = [];

  // Step 3: Intensity
  int _intensity = 5;

  // Step 4: Reframe
  final _reframeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      _thoughtController.text = widget.existingEntry!.thought;
      _selectedDistortions = List.from(widget.existingEntry!.distortions);
      _intensity = widget.existingEntry!.intensity;
      _reframeController.text = widget.existingEntry!.reframedThought;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thoughtController.dispose();
    _reframeController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep++);
    } else {
      _saveEntry();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentStep--);
    }
  }

  void _saveEntry() {
    final thought = _thoughtController.text.trim();
    final reframed = _reframeController.text.trim();

    if (thought.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write the negative thought first.')),
      );
      return;
    }
    if (reframed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reframed thought.')),
      );
      return;
    }

    final entry = CBTEntry(
      id: widget.existingEntry?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: widget.existingEntry?.date ?? DateTime.now(),
      thought: thought,
      intensity: _intensity,
      distortions: _selectedDistortions,
      reframedThought: reframed,
    );

    HiveService.saveCBTEntry(entry);
    AdMobService.trackActionAndShowInterstitial();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEntry != null
              ? L10n.get('viewEntry')
              : L10n.get('thoughtCatcher'),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // ── Step Indicator ──
          _StepIndicator(currentStep: _currentStep, totalSteps: 4),
          const SizedBox(height: 8),

          // ── Pages ──
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(theme),
                _buildStep2(theme),
                _buildStep3(theme),
                _buildStep4(theme),
              ],
            ),
          ),

          // ── Navigation Buttons ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentStep > 0)
                  OutlinedButton(
                    onPressed: _prevStep,
                    child: Text(L10n.get('back')),
                  )
                else
                  const SizedBox(width: 80),
                const Spacer(),
                FilledButton(
                  onPressed: _nextStep,
                  child: Text(
                    _currentStep == 3 ? L10n.get('saveCBT') : L10n.get('next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.edit_note, size: 36, color: theme.colorScheme.secondary),
          const SizedBox(height: 12),
          Text(
            L10n.get('catchYourThought'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Write down the negative thought exactly as it appears in your mind.',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _thoughtController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: L10n.get('thoughtHint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.checklist, size: 36, color: theme.colorScheme.secondary),
          const SizedBox(height: 12),
          Text(
            L10n.get('identifyDistortions'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            L10n.get('distortionsPrompt'),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DistortionChecklist(
              selectedDistortions: _selectedDistortions,
              onChanged: (list) {
                setState(() => _selectedDistortions = list);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.speed, size: 36, color: theme.colorScheme.secondary),
          const SizedBox(height: 12),
          Text(
            L10n.get('rateIntensity'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            L10n.get('intensityPrompt'),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          IntensitySlider(
            intensity: _intensity,
            onChanged: (v) => setState(() => _intensity = v),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_fix_high, size: 36, color: theme.colorScheme.secondary),
          const SizedBox(height: 12),
          Text(
            L10n.get('reframe'),
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            L10n.get('reframePrompt'),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _reframeController,
            maxLines: 5,
            minLines: 3,
            decoration: InputDecoration(
              hintText: L10n.get('reframeHint'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontal step indicator widget.
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Text(
            '${L10n.get('step')} ${currentStep + 1} ${L10n.get('of')} $totalSteps',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          ...List.generate(totalSteps, (i) {
            return Container(
              width: 24,
              height: 4,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= currentStep
                    ? theme.colorScheme.secondary
                    : Colors.grey.shade300,
              ),
            );
          }),
        ],
      ),
    );
  }
}