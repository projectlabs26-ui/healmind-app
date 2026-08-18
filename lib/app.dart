import 'services/locale_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'services/hive_service.dart';
import 'services/admob_service.dart';
import 'constants/colors.dart';
import 'constants/themes.dart';
import 'screens/home_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/breathe_screen.dart';
import 'screens/cbt_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';

class HealMindApp extends StatefulWidget {
  const HealMindApp({super.key});

  @override
  State<HealMindApp> createState() => _HealMindAppState();
}

class _HealMindAppState extends State<HealMindApp> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isDarkMode = false;
  int _dataVersion = 0;
  String _themeId = 'default';

  bool _showOnboarding = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSettings();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Show app open ad when app comes to foreground
      AdMobService.showAppOpenIfReady();
    }
  }

  void _loadSettings() {
    final settings = HiveService.getSettings();
    _isDarkMode = settings.darkMode;
    _themeId = settings.selectedThemeId;
    _showOnboarding = !settings.onboardingComplete;
  }

  void _onThemeChanged(String themeId) {
    setState(() {
      _themeId = themeId;
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onDataReset() {
    setState(() {
      _dataVersion++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: L10n.get('appName'),
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(_themeId),
      darkTheme: _buildDarkTheme(_themeId),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: _showOnboarding
          ? OnboardingScreen(onComplete: () => setState(() => _showOnboarding = false))
          : _MainShell(
        key: ValueKey(_dataVersion),
        currentIndex: _currentIndex,
        onTabChanged: _onTabChanged,
        onThemeChanged: _onThemeChanged,
        onDarkModeChanged: _onDarkModeChanged,
        isDarkMode: _isDarkMode,
        themeId: _themeId,
        onDataReset: _onDataReset,
      ),
    );
  }

  void _onDarkModeChanged(bool darkMode) {
    setState(() {
      _isDarkMode = darkMode;
    });
  }

  ThemeData _buildLightTheme(String themeId) {
    final appTheme = AppThemes.byId(themeId);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: appTheme.seedColor,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.surface,
      textTheme: GoogleFonts.interTextTheme(),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme(String themeId) {
    final appTheme = AppThemes.byId(themeId);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: appTheme.seedColor,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class _MainShell extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabChanged;
  final ValueChanged<String> onThemeChanged;
  final ValueChanged<bool> onDarkModeChanged;
  final VoidCallback onDataReset;
  final bool isDarkMode;
  final String themeId;

  const _MainShell({
    super.key,
    required this.currentIndex,
    required this.onTabChanged,
    required this.onThemeChanged,
    required this.onDarkModeChanged,
    required this.isDarkMode,
    required this.themeId,
    required this.onDataReset,
  });

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(onDarkModeChanged: onDarkModeChanged),
      const JournalScreen(),
      const BreatheScreen(),
      const CBTScreen(),
      SettingsScreen(
        onDarkModeChanged: onDarkModeChanged,
        onThemeChanged: onThemeChanged,
        isDarkMode: isDarkMode,
        themeId: themeId,
        onDataReset: onDataReset,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: onTabChanged,
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: L10n.get('navHome'),
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: L10n.get('navJournal'),
          ),
          NavigationDestination(
            icon: Icon(Icons.air_outlined),
            selectedIcon: Icon(Icons.air),
            label: L10n.get('navBreathe'),
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: L10n.get('navCBT'),
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: L10n.get('navProfile'),
          ),
        ],
      ),
    );
  }
}