import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'controllers/app_controller.dart';
import 'core/theme.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';

class DroneAtlasApp extends StatefulWidget {
  const DroneAtlasApp({super.key});

  @override
  State<DroneAtlasApp> createState() => _DroneAtlasAppState();
}

class _DroneAtlasAppState extends State<DroneAtlasApp> {
  final AppController _controller = AppController();
  static const String _themePreferenceKey = 'appearance.darkMode';

  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _controller.initialize();
    _loadSavedTheme();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadSavedTheme() async {
    final darkMode = await _prefs.getBool(_themePreferenceKey) ?? false;
    if (!mounted) return;
    setState(() {
      _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _toggleTheme() {
    final next = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    setState(() => _themeMode = next);
    _prefs.setBool(_themePreferenceKey, next == ThemeMode.dark);
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      controller: _controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Drone Atlas Academy • Novateur221',
        themeMode: _themeMode,
        theme: buildDroneTheme(Brightness.light),
        darkTheme: buildDroneTheme(Brightness.dark),
        builder: (context, child) {
          final mediaQuery = MediaQuery.of(context);
          final systemScale = mediaQuery.textScaler.scale(1.0);
          final safeScale = systemScale.clamp(0.95, 1.05).toDouble();

          return MediaQuery(
            data: mediaQuery.copyWith(
              textScaler: TextScaler.linear(safeScale),
            ),
            child: ColoredBox(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                top: false,
                left: false,
                right: false,
                bottom: true,
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          );
        },
        home: SplashScreen(
          child: _AppEntryGate(
            isDark: _themeMode == ThemeMode.dark,
            onToggleTheme: _toggleTheme,
          ),
        ),
      ),
    );
  }
}

class _AppEntryGate extends StatelessWidget {
  const _AppEntryGate({
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    if (!controller.contentInitialized) {
      return const Scaffold(
        backgroundColor: navy,
        body: Center(
          child: CircularProgressIndicator(color: cyan),
        ),
      );
    }

    if (!controller.onboardingComplete) {
      return const OnboardingScreen();
    }

    return MainShell(
      isDark: isDark,
      onToggleTheme: onToggleTheme,
    );
  }
}
