import 'package:flutter/material.dart';
import '../services/hive_service.dart';
import '../services/locale_service.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  List<_OnboardingPage> get _pages => [
    _OnboardingPage(
      emoji: '🧘',
      title: L10n.get('onboardingTitle1'),
      description: L10n.get('onboardingDesc1'),
      color: const Color(0xFF4FC3F7),
    ),
    _OnboardingPage(
      emoji: '📝',
      title: L10n.get('onboardingTitle2'),
      description: L10n.get('onboardingDesc2'),
      color: const Color(0xFF81C784),
    ),
    _OnboardingPage(
      emoji: '🌬️',
      title: L10n.get('onboardingTitle3'),
      description: L10n.get('onboardingDesc3'),
      color: const Color(0xFFCE93D8),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    final settings = HiveService.getSettings();
    settings.onboardingComplete = true;
    settings.firstLaunchDate ??= DateTime.now();
    HiveService.saveSettings(settings);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finish,
                child: Text(L10n.get('onboardingSkip')),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: _pages.map((p) => _buildPage(p)).toList(),
              ),
            ),
            // Dots + Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i ? _pages[i].color : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Button
                  FilledButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _finish();
                      }
                    },
                    child: Text(_currentPage < _pages.length - 1 ? L10n.get('onboardingNext') : L10n.get('onboardingGetStarted')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(page.emoji, style: const TextStyle(fontSize: 56)),
            ),
          ),
          const SizedBox(height: 40),
          Text(
            page.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: page.color,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  const _OnboardingPage({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}