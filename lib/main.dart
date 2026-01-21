import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui'; // For ImageFilter
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'floating_background.dart';

import 'package:shared_preferences/shared_preferences.dart';

// Simple global auth state for demo purposes
final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

// Add these ValueNotifiers after isLoggedIn at the top:
enum AppLanguage { en, ro }
enum AppDesign { def, adv }
enum ThemeOption { yellowWhite, blueWhite, yellowBlue }

final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
final ValueNotifier<AppLanguage> selectedLanguage = ValueNotifier<AppLanguage>(AppLanguage.en);
final ValueNotifier<AppDesign> selectedDesign = ValueNotifier<AppDesign>(AppDesign.def);
final ValueNotifier<ThemeOption> selectedThemeOption = ValueNotifier<ThemeOption>(ThemeOption.yellowBlue);
final ValueNotifier<bool> gradientDirection = ValueNotifier<bool>(true); // true = top-down, false = bottom-up

// --- School Theme Constants ---
class SchoolColors {
  // Base colors
  static const Color _blue = Color(0xFF002B5C);
  static const Color _gold = Color(0xFFD4AF37);
  static const Color _white = Colors.white;
  static const Color _black = Color(0xFF121212);
  
  // Dark mode variants
  static const Color _darkBlue = Color(0xFF001A38);
  static const Color _darkGold = Color(0xFFB8962E);

  static const Color primaryBlue = _blue;
  static const Color accentGold = _gold;
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = _black;
  static const List<Color> primaryGradient = [_blue, _gold];

  static Color getThemeColor(ThemeOption option, bool isDark) {
    switch (option) {
      case ThemeOption.yellowWhite:
        return isDark ? _black : _white; // Background/Main
      case ThemeOption.blueWhite:
        return isDark ? _black : _white;
      case ThemeOption.yellowBlue:
        return isDark ? _darkBlue : _blue;
    }
  }

  static Color getAccentColor(ThemeOption option, bool isDark) {
    switch (option) {
      case ThemeOption.yellowWhite:
        return isDark ? _darkBlue : _blue; // Accents
      case ThemeOption.blueWhite:
        return isDark ? _darkGold : _gold;
      case ThemeOption.yellowBlue:
        return isDark ? Colors.white70 : _white;
    }
  }

  static List<Color> getGradient(ThemeOption option, bool isDark, bool direction) {
    List<Color> colors;
    switch (option) {
      case ThemeOption.yellowWhite:
        // Yellow with White (or Dark variants)
        colors = isDark 
            ? [_darkGold, _black] 
            : [_gold, _white];
        break;
      case ThemeOption.blueWhite:
        // Blue with White
        colors = isDark 
            ? [_darkBlue, _black] 
            : [_blue, _white];
        break;
      case ThemeOption.yellowBlue:
        // Blue top, Yellow bottom (Default)
        colors = isDark 
            ? [_darkBlue, _darkGold] 
            : [_blue, _gold];
        break;
    }
    return direction ? colors : colors.reversed.toList();
  }
}
// ------------------------------

String t(String key) {
  const translations = {
    'en': {
      'home': 'Home',
      'welcome': 'Welcome!',
      'app_title': 'Pontaj App',
      'help': 'Help',
      'about': 'About',
      'about_us': 'About Us',
      'sign_in': 'Sign in',
      'school_code_hint': 'School Code',
      'design': 'Design',
      'design_settings_coming_soon': 'Design settings coming soon',
      'theme': 'Theme',
      'logout': 'Logout',
      'login': 'Enroll',
      'request_qr': 'Request QR',
      'temporary_notice': 'Temporary notice',
      'language': 'Language',
      'language_settings_coming_soon': 'Language settings coming soon',
      'menu': 'Menu',
      'how_to_use_app': 'How to use the app',
      'step_1': 'Step 1',
      'step_2': 'Step 2',
      'step_3': 'Step 3',
      'enter_school_code': 'Enter your school code',
      'tap_start_to_sign_in': 'Tap start to sign in',
      'use_app_to_manage_attendance': 'Use the app to manage attendance',
      'invalid_credentials': 'Invalid credentials. Please check your code.',
      'enrollment_success': 'Enrollment successful!',
      'network_error': 'Network error. Please try again.',
      'enter_code_first': 'Please enter your school code first.',
      'validating': 'Validating...',
      'meet_the_team': 'Meet the team',
      'we_are_a_small_team_focused_on_building_simple': 'We are a small team focused on building simple,',
      'useful_tools_for_students_and_schools': 'useful tools for students and schools.',
      'ready_for_qr': 'All set up for requesting QRs!'
    },
    'ro': {
      'home': 'Acasă',
      'welcome': 'Bine ai venit!',
      'app_title': 'Pontaj App',
      'help': 'Ajutor',
      'about': 'Despre',
      'about_us': 'Despre noi',
      'sign_in': 'Autentificare',
      'school_code_hint': 'Codul școlii',
      'design': 'Design',
      'design_settings_coming_soon': 'Setările de design vor fi disponibile în curând',
      'theme': 'Temă',
      'logout': 'Deconectare',
      'login': 'Enroll',
      'request_qr': 'Cere cod QR',
      'temporary_notice': 'Anunț temporar',
      'language': 'Limbă',
      'language_settings_coming_soon': 'Setările de limbă vor fi disponibile în curând',
      'menu': 'Meniu',
      'how_to_use_app': 'Cum folosești aplicația',
      'step_1': 'Pasul 1',
      'step_2': 'Pasul 2',
      'step_3': 'Pasul 3',
      'enter_school_code': 'Introdu codul școlii',
      'tap_start_to_sign_in': 'Apasă start pentru a te autentifica',
      'use_app_to_manage_attendance': 'Folosește aplicația pentru a gestiona prezența',
      'invalid_credentials': 'Credențiale invalide. Verifică codul.',
      'enrollment_success': 'Înrolare reușită!',
      'network_error': 'Eroare de rețea. Încearcă din nou.',
      'enter_code_first': 'Te rugăm să introduci codul școlii mai întâi.',
      'validating': 'Se verifică...',
      'meet_the_team': 'Cunoaște echipa',
      'we_are_a_small_team_focused_on_building_simple': 'Suntem o echipă mică, concentrată pe a crea soluții simple,',
      'useful_tools_for_students_and_schools': 'utile pentru elevi și școli.',
      'ready_for_qr': 'Totul este pregătit pentru a cere coduri QR!'
    }
  };
  final code = selectedLanguage.value == AppLanguage.en ? 'en' : 'ro';
  return translations[code]![key] ?? key;
}
// ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('auth_token')) {
    isLoggedIn.value = true;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme(bool isDark) {
    final baseColor = SchoolColors.primaryBlue;
    final accentColor = SchoolColors.accentGold;

    if (!isDark) {
      final colorScheme = ColorScheme.fromSeed(
        seedColor: baseColor,
        primary: baseColor,
        secondary: accentColor,
        brightness: Brightness.light,
        surface: SchoolColors.lightBackground,
      );
      return ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: SchoolColors.lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            minimumSize: const Size(240, 56),
            elevation: 4,
            shadowColor: accentColor.withOpacity(0.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: SchoolColors.primaryBlue, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(color: SchoolColors.primaryBlue, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black87),
        ),
      );
    }

    final colorScheme = ColorScheme.fromSeed(
      seedColor: baseColor,
      primary: baseColor,
      secondary: accentColor,
      brightness: Brightness.dark,
      surface: SchoolColors.darkBackground,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: SchoolColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.black, // Gold needs dark text for contrast
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size(240, 56),
          elevation: 4,
          shadowColor: accentColor.withOpacity(0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SchoolColors.accentGold, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.surface,
        contentTextStyle: TextStyle(color: colorScheme.onSurface),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<AppLanguage, bool>(
      first: selectedLanguage,
      second: darkMode,
      builder: (context, _, isDark, __) {
        final ThemeData lightTheme = _buildTheme(false);
        final ThemeData darkThemeData = _buildTheme(true);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Pontaj App",
          theme: lightTheme,
          darkTheme: darkThemeData,
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: HomePage(),
          routes: {
            "/help": (context) => HelpPage(),
            "/login": (context) => LoginPage(),
            "/about": (context) => AboutPage(),
            "/request-qr": (context) => RequestQRPage(),
          },
        );
      },
    );
  }
}

// --- Reusable Components ---

class SchoolGradientBackground extends StatelessWidget {
  final Widget child;
  final double heightFraction;

  const SchoolGradientBackground({
    Key? key,
    required this.child,
    this.heightFraction = 0.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder3<bool, ThemeOption, bool>(
      first: darkMode,
      second: selectedThemeOption,
      third: gradientDirection,
      builder: (context, isDark, themeOption, direction, _) {
        return Container(
          height: MediaQuery.of(context).size.height * heightFraction,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: SchoolColors.getGradient(themeOption, isDark, direction),
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class AnimatedActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final int delayMs;

  const AnimatedActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.delayMs = 0,
  }) : super(key: key);

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: ElevatedButton(
            onPressed: widget.onPressed, // Keep for accessibility
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

class BreadcrumbBar extends StatelessWidget {
  final List<String> path;
  const BreadcrumbBar({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            // Back button removed, handled by parent with Menu button
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: path.map((segment) {
                    final isLast = segment == path.last;
                    return Row(
                      children: [
                        Text(
                          segment,
                          style: TextStyle(
                            color: isLast ? Colors.white : Colors.white70,
                            fontWeight: isLast ? FontWeight.bold : FontWeight.normal,
                            fontSize: 16,
                          ),
                        ),
                        if (!isLast)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0),
                            child: Icon(Icons.chevron_right, color: Colors.white54, size: 16),
                          ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Pages ---

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleDrawer() {
    if (_scaffoldKey.currentState!.isDrawerOpen) {
      _scaffoldKey.currentState!.closeDrawer();
    } else {
      _scaffoldKey.currentState!.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      extendBodyBehindAppBar: true,
      drawer: const AppMenuDrawer(),
      drawerEdgeDragWidth: MediaQuery.of(context).size.width,
      body: Stack(
        children: [
          // Background
          Column(
            children: [
              Expanded(
                flex: 55,
                child: SchoolGradientBackground(
                  heightFraction: 1.0, // Fills this expanded part
                  child: ValueListenableBuilder<AppDesign>(
                    valueListenable: selectedDesign,
                    builder: (context, design, _) {
                      if (design == AppDesign.adv) {
                        return const FloatingBackgroundLetters();
                      }
                      return Container();
                    },
                  ),
                ),
              ),
              Expanded(
                flex: 45,
                child: Container(color: Theme.of(context).scaffoldBackgroundColor),
              ),
            ],
          ),
          
          // Content
          SafeArea(
            child: ValueListenableBuilder<AppDesign>(
              valueListenable: selectedDesign,
              builder: (context, design, _) {
                return Column(
                  children: [
                    // Header Area
                    if (design == AppDesign.adv)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: _toggleDrawer,
                            ),
                            Expanded(
                              child: BreadcrumbBar(path: [t('app_title'), t('home')]),
                            ),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white),
                              onPressed: _toggleDrawer,
                            ),
                            // Optional: Add School Logo here if available
                          ],
                        ),
                      ),
                    
                    // Main Hero Section
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: isLoggedIn,
                              builder: (context, loggedIn, _) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 500),
                                      transitionBuilder: (Widget child, Animation<double> animation) {
                                        return FadeTransition(opacity: animation, child: SlideTransition(
                                          position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(animation),
                                          child: child,
                                        ));
                                      },
                                      child: Text(
                                        loggedIn ? t('welcome') : t('app_title'),
                                        key: ValueKey<bool>(loggedIn),
                                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 36,
                                              shadows: [
                                                Shadow(
                                                  color: Colors.black.withOpacity(0.3),
                                                  offset: const Offset(0, 4),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Hero(
                                      tag: 'app_icon',
                                      child: Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.15),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
                                        ),
                                        child: design == AppDesign.adv
                                            ? ClipOval(
                                                child: Image.network(
                                                  'https://cnvga.ro/wp-content/uploads/2023/11/colegiu-vasile-goldis-arad-logo-512.png',
                                                  height: 80,
                                                  width: 80,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error, stackTrace) {
                                                    return Icon(
                                                      Icons.school,
                                                      size: 80,
                                                      color: SchoolColors.accentGold,
                                                    );
                                                  },
                                                ),
                                              )
                                            : Icon(
                                                Icons.school,
                                                size: 80,
                                                color: SchoolColors.accentGold,
                                              ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),

                    // Action Section
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ValueListenableBuilder<bool>(
                              valueListenable: isLoggedIn,
                              builder: (context, loggedIn, _) {
                                return Column(
                                  children: [
                                    if (loggedIn && design == AppDesign.adv)
                                      Container(
                                        margin: const EdgeInsets.only(bottom: 24),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.green.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(color: Colors.green),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.check_circle, color: Colors.green),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                t('ready_for_qr'),
                                                style: TextStyle(
                                                  color: Colors.green[700],
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 400),
                                      child: loggedIn
                                          ? AnimatedActionButton(
                                              key: const ValueKey('request_qr'),
                                              label: t('request_qr'),
                                              onPressed: () => Navigator.pushNamed(context, '/request-qr'),
                                            )
                                          : AnimatedActionButton(
                                              key: const ValueKey('login'),
                                              label: t('login'),
                                              onPressed: () => Navigator.pushNamed(context, '/login'),
                                            ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Colegiul Național \"Vasile Goldiș\" Arad",
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.6),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect( // Clip for the blur effect
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.85),
            border: Border(right: BorderSide(color: Colors.white.withOpacity(0.2))),
          ),
          child: ValueListenableBuilder<AppLanguage>(
            valueListenable: selectedLanguage,
            builder: (context, lang, _) {
              const tilePadding = EdgeInsets.symmetric(horizontal: 20.0, vertical: 8);
              
              Widget buildMenuItem(IconData icon, String title, VoidCallback onTap, {Widget? trailing, Color? textColor, Color? iconColor}) {
                final effectiveIconColor = iconColor ?? SchoolColors.primaryBlue;
                // Determine text color: explicit > dark mode white > default black
                final effectiveTextColor = textColor ?? (darkMode.value ? Colors.white : Colors.black87);

                return ListTile(
                  contentPadding: tilePadding,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: effectiveIconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: effectiveIconColor, size: 20),
                  ),
                  title: Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: effectiveTextColor),
                  ),
                  trailing: trailing,
                  onTap: onTap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                );
              }

              return Column(
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: SchoolColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.school, color: SchoolColors.accentGold, size: 48),
                          const SizedBox(height: 12),
                          Text(
                            t('menu'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      children: [
                        buildMenuItem(Icons.home_rounded, t('home'), () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "/");
                        }),
                        buildMenuItem(Icons.info_outline_rounded, t('about'), () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "/about");
                        }),
                        buildMenuItem(Icons.help_outline_rounded, t('help'), () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, "/help");
                        }),
                        const Divider(height: 32, thickness: 1),
                        
                        ValueListenableBuilder<bool>(
                          valueListenable: darkMode,
                          builder: (context, dark, _) {
                            return Column(
                              children: [
                                buildMenuItem(
                                  dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                                  t('theme'),
                                  () => darkMode.value = !darkMode.value,
                                  trailing: Switch(
                                    value: dark,
                                    activeColor: SchoolColors.accentGold,
                                    onChanged: (v) => darkMode.value = v,
                                  ),
                                ),
                                ValueListenableBuilder<AppDesign>(
                                  valueListenable: selectedDesign,
                                  builder: (context, design, _) {
                                    return buildMenuItem(
                                      Icons.design_services,
                                      t('design'),
                                      () => selectedDesign.value = design == AppDesign.def ? AppDesign.adv : AppDesign.def,
                                      trailing: Text(
                                        design == AppDesign.def ? "DEF" : "ADV",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: dark ? Colors.white : Colors.black87
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),

                        // Colors Menu
                        Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: SchoolColors.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.color_lens, color: SchoolColors.primaryBlue, size: 20),
                            ),
                            title: Text(
                              "Colors",
                              style: TextStyle(
                                fontWeight: FontWeight.w600, 
                                fontSize: 16, 
                                color: darkMode.value ? Colors.white : Colors.black87
                              ),
                            ),
                            childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                            children: [
                              ValueListenableBuilder2<ThemeOption, bool>(
                                first: selectedThemeOption,
                                second: gradientDirection,
                                builder: (context, theme, direction, _) {
                                  return Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _buildThemeOptionRect(ThemeOption.yellowWhite, theme, direction, context),
                                          _buildThemeOptionRect(ThemeOption.blueWhite, theme, direction, context),
                                          _buildThemeOptionRect(ThemeOption.yellowBlue, theme, direction, context),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      InkWell(
                                        onTap: () => gradientDirection.value = !gradientDirection.value,
                                        borderRadius: BorderRadius.circular(12),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.rotate_right, color: SchoolColors.primaryBlue),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Rotate Gradient",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: darkMode.value ? Colors.white : Colors.black87,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 32, thickness: 1),

                        ValueListenableBuilder<AppLanguage>(
                          valueListenable: selectedLanguage,
                          builder: (context, lang, _) {
                            return buildMenuItem(Icons.language, t('language'), () {
                              selectedLanguage.value = lang == AppLanguage.en ? AppLanguage.ro : AppLanguage.en;
                            }, trailing: Text(
                              lang == AppLanguage.en ? "EN" : "RO",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: darkMode.value ? Colors.white : Colors.black87
                              ),
                            ));
                          },
                        ),
                        
                        ValueListenableBuilder<bool>(
                          valueListenable: isLoggedIn,
                          builder: (context, loggedIn, _) {
                            if (!loggedIn) return const SizedBox.shrink();
                            return Column(
                              children: [
                                const Divider(height: 32, thickness: 1),
                                buildMenuItem(Icons.logout_rounded, t('logout'), () {
                                  isLoggedIn.value = false;
                                  Navigator.pop(context);
                                }, textColor: Colors.redAccent, iconColor: Colors.redAccent),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOptionRect(ThemeOption option, ThemeOption selected, bool direction, BuildContext context) {
    final bool isSelected = option == selected;
    // Use the actual gradient colors for the preview
    final List<Color> colors = SchoolColors.getGradient(option, false, direction);

    return GestureDetector(
      onTap: () => selectedThemeOption.value = option,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
              boxShadow: isSelected
                  ? [BoxShadow(color: SchoolColors.accentGold.withOpacity(0.4), blurRadius: 8, spreadRadius: 1)]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                  ? SchoolColors.primaryBlue 
                  : (Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87),
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }
}

class HelpPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppDesign>(
      valueListenable: selectedDesign,
      builder: (context, design, _) {
        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          drawer: const AppMenuDrawer(),
          appBar: design == AppDesign.adv
              ? null
              : AppBar(
                  title: null, // Title is now in body
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          body: Stack(
            children: [
              Column(
                children: [
                  SchoolGradientBackground(
                    heightFraction: 0.35,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Top spacing for AppBar/Breadcrumb
                          const SizedBox(height: kToolbarHeight + 16),
                          
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              t('help'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Icon(Icons.help_outline, size: 50, color: Colors.white.withOpacity(0.9)),
                          const SizedBox(height: 8),
                          Text(
                            t('how_to_use_app'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 40), // Shift content up
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildHelpStep(context, '1', t('step_1'), t('enter_school_code')),
                      _buildHelpStep(context, '2', t('step_2'), t('tap_start_to_sign_in')),
                      _buildHelpStep(context, '3', t('step_3'), t('use_app_to_manage_attendance')),
                    ],
                  ),
                ),
              ),
              if (design == AppDesign.adv)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(child: BreadcrumbBar(path: [t('app_title'), t('help')])),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHelpStep(BuildContext context, String number, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: SchoolColors.primaryBlue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: SchoolColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppDesign>(
      valueListenable: selectedDesign,
      builder: (context, design, _) {
        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          drawer: const AppMenuDrawer(),
          appBar: design == AppDesign.adv
              ? null
              : AppBar(
                  title: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          body: Stack(
            children: [
              Column(
                children: [
                  SchoolGradientBackground(
                    heightFraction: 0.4,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: kToolbarHeight + 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              t('login'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Hero(
                            tag: 'app_icon',
                            child: Icon(Icons.school, size: 70, color: SchoolColors.accentGold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            t('enter_school_code'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 40), // Shift content up
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              Center(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Card(
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                t('sign_in'),
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : SchoolColors.primaryBlue,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              _SchoolCodeFieldWithButton(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (design == AppDesign.adv)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(child: BreadcrumbBar(path: [t('app_title'), t('login')])),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SchoolCodeFieldWithButton extends StatefulWidget {
  @override
  State<_SchoolCodeFieldWithButton> createState() => _SchoolCodeFieldWithButtonState();
}

class _SchoolCodeFieldWithButtonState extends State<_SchoolCodeFieldWithButton> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _tryLogin([String? codeStr]) async {
    final code = (codeStr ?? _controller.text).trim();
    
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.warning_amber, color: Colors.white),
              const SizedBox(width: 12),
              Text(t('enter_code_first')),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://api.pontaj.binarysquad.club/mobile/enroll'),
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'codmatricol': code}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        // Success - API returns a string token
        // If it's a JSON string, decode it. If raw string, use as is.
        String token = response.body;
        try {
           final decoded = jsonDecode(token);
           if (decoded is String) token = decoded;
        } catch (_) {
           // Not JSON, use raw body
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);

        if (!mounted) return;

        isLoggedIn.value = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(t('enrollment_success')),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      } else if (response.statusCode == 409) {
        // User already enrolled
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(child: Text("User already enrolled")), // Hardcoded as per request or use translation if available
              ],
            ),
            backgroundColor: Colors.orangeAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        // Invalid credentials or other error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(t('invalid_credentials'))),
              ],
            ),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.wifi_off, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(child: Text(t('network_error'))),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: _isLoading ? null : _tryLogin,
          decoration: InputDecoration(
            labelText: t('school_code_hint'),
            prefixIcon: const Icon(Icons.vpn_key_outlined, color: SchoolColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 24),
        _isLoading
            ? Center(
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(SchoolColors.accentGold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      t('validating'),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : AnimatedActionButton(
                delayMs: 0,
                label: t('sign_in'),
                onPressed: () => _tryLogin(),
              ),
      ],
    );
  }
}

class AboutPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppDesign>(
      valueListenable: selectedDesign,
      builder: (context, design, _) {
        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          drawer: const AppMenuDrawer(),
          appBar: design == AppDesign.adv
              ? null
              : AppBar(
                  title: null,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  iconTheme: const IconThemeData(color: Colors.white),
                ),
          body: Stack(
            children: [
              Column(
                children: [
                  SchoolGradientBackground(
                    heightFraction: 0.35,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: kToolbarHeight + 16),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              t('about_us'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(Icons.info_outline, size: 50, color: Colors.white),
                          const SizedBox(height: 8),
                          Text(
                            t('meet_the_team'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 40), // Shift content up
                        ],
                      ),
                    ),
                  ),
                  Expanded(child: Container()),
                ],
              ),
              Positioned.fill(
                top: MediaQuery.of(context).size.height * 0.3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(32),
                    children: [
                      Text(
                        t('we_are_a_small_team_focused_on_building_simple'),
                        style: const TextStyle(fontSize: 18, height: 1.5),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        t('useful_tools_for_students_and_schools'),
                        style: const TextStyle(fontSize: 18, height: 1.5, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
              if (design == AppDesign.adv)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(child: BreadcrumbBar(path: [t('app_title'), t('about')])),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// Placeholder for RequestQRPage
class RequestQRPage extends StatefulWidget {
  @override
  State<RequestQRPage> createState() => _RequestQRPageState();
}

class _RequestQRPageState extends State<RequestQRPage> {
  Uint8List? _qrImageBytes;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _generateQR() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _qrImageBytes = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        _handleLogout();
        return;
      }

      final response = await http.post(
        Uri.parse('https://api.pontaj.binarysquad.club/mobile/qr_image'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _qrImageBytes = response.bodyBytes;
        });
      } else if (response.statusCode == 401) {
        _handleLogout();
      } else {
        setState(() {
          _errorMessage = 'Error: ${response.statusCode}';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate QR: ${response.statusCode}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
        setState(() {
          _errorMessage = 'Network Error';
        });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t('network_error'))),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    isLoggedIn.value = false;
    if (mounted) {
       Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Session expired. Please log in again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
     return ValueListenableBuilder<AppDesign>(
      valueListenable: selectedDesign,
      builder: (context, design, _) {
          return Scaffold(
            appBar: AppBar(
              title: Text(t('request_qr')), 
              backgroundColor: SchoolColors.primaryBlue,
              iconTheme: const IconThemeData(color: Colors.white),
              titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_qrImageBytes != null)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: SchoolColors.primaryBlue, width: 2),
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Expanded(child: Image.memory(_qrImageBytes!, fit: BoxFit.contain)),
                              const SizedBox(height: 8),
                              const Text("Scan this at the entrance", style: TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    else if (_errorMessage != null)
                       Expanded(
                         child: Center(
                           child: Column(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                               const Icon(Icons.error_outline, size: 48, color: Colors.redAccent),
                               const SizedBox(height: 16),
                               Text(_errorMessage!, style: const TextStyle(color: Colors.redAccent)),
                             ],
                           ),
                         ),
                       )
                    else
                      const Expanded(
                        child: Center(
                          child: Icon(Icons.qr_code_scanner, size: 100, color: Colors.grey),
                        ),
                      ),
                    
                    const SizedBox(height: 32),
                    
                    if (_isLoading)
                      const CircularProgressIndicator(color: SchoolColors.accentGold)
                    else
                      AnimatedActionButton(
                        label: t('request_qr'), // Reusing the same string key "Request QR"
                        onPressed: _generateQR,
                      ),
                  ],
                ),
              ),
            ),
          );
      }
     );
  }
}

// Helper for ValueListenableBuilder2
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final Widget Function(BuildContext, A, B, Widget?) builder;
  final Widget? child;

  const ValueListenableBuilder2({
    Key? key,
    required this.first,
    required this.second,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder<B>(
          valueListenable: second,
          builder: (context, b, __) {
            return builder(context, a, b, child);
          },
        );
      },
    );
  }
}

class ValueListenableBuilder3<A, B, C> extends StatelessWidget {
  final ValueListenable<A> first;
  final ValueListenable<B> second;
  final ValueListenable<C> third;
  final Widget Function(BuildContext context, A a, B b, C c, Widget? child) builder;
  final Widget? child;

  const ValueListenableBuilder3({
    Key? key,
    required this.first,
    required this.second,
    required this.third,
    required this.builder,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: first,
      builder: (_, a, __) {
        return ValueListenableBuilder2<B, C>(
          first: second,
          second: third,
          builder: (context, b, c, __) {
            return builder(context, a, b, c, child);
          },
        );
      },
    );
  }
}
