import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:runner/game/utils/constants.dart';
import 'package:runner/screens/game_screen.dart';
import 'package:runner/screens/info_screen.dart';
import 'package:runner/screens/main_menu_screen.dart';
import 'package:runner/screens/settings_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: GameColors.darkBg,
    ),
  );
  runApp(const RunnerApp());
}

class RunnerApp extends StatelessWidget {
  const RunnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pixel Runner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: GameColors.darkBg,
        textTheme: GoogleFonts.pressStart2pTextTheme(
          ThemeData.dark().textTheme,
        ),
        colorScheme: const ColorScheme.dark(
          primary: GameColors.neonCyan,
          secondary: GameColors.pixelGreen,
          surface: GameColors.darkBg,
        ),
      ),
      home: const AppNavigator(),
    );
  }
}

enum AppScreen { menu, game, settings, info }

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  AppScreen _currentScreen = AppScreen.menu;
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  void _navigateTo(AppScreen screen) {
    setState(() => _currentScreen = screen);
    if (screen == AppScreen.menu) _loadHighScore();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _buildCurrentScreen(),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case AppScreen.menu:
        return MainMenuScreen(
          key: const ValueKey('menu'),
          onPlay: () => _navigateTo(AppScreen.game),
          onSettings: () => _navigateTo(AppScreen.settings),
          onInfo: () => _navigateTo(AppScreen.info),
          highScore: _highScore,
        );
      case AppScreen.game:
        return GameScreen(
          key: UniqueKey(),
          onMainMenu: () => _navigateTo(AppScreen.menu),
        );
      case AppScreen.settings:
        return SettingsScreen(
          key: const ValueKey('settings'),
          onBack: () => _navigateTo(AppScreen.menu),
        );
      case AppScreen.info:
        return InfoScreen(
          key: const ValueKey('info'),
          onBack: () => _navigateTo(AppScreen.menu),
        );
    }
  }
}
