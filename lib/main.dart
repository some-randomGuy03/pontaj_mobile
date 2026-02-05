import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import 'dart:ui'; // For ImageFilter
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'floating_background.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'shared.dart';
import 'drawer.dart';
import 'scans_page.dart';

// Globals, SchoolColors, and t() moved to shared.dart

// ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  
  // Load Auth Logic
  if (prefs.containsKey('auth_token')) {
    isLoggedIn.value = true;
  }

  // Load Settings
  if (prefs.containsKey('selectedDesign')) {
    selectedDesign.value = AppDesign.values[prefs.getInt('selectedDesign')!];
  } else {
    selectedDesign.value = AppDesign.adv; // Default
  }

  if (prefs.containsKey('selectedLanguage')) {
    selectedLanguage.value = AppLanguage.values[prefs.getInt('selectedLanguage')!];
  }

  if (prefs.containsKey('darkMode')) {
    darkMode.value = prefs.getBool('darkMode') ?? false;
  }

  if (prefs.containsKey('selectedThemeOption')) {
    selectedThemeOption.value = ThemeOption.values[prefs.getInt('selectedThemeOption')!];
  }

  if (prefs.containsKey('gradientDirection')) {
    gradientDirection.value = prefs.getBool('gradientDirection') ?? true;
  }

  // Add Persistence Listeners
  selectedDesign.addListener(() {
    prefs.setInt('selectedDesign', selectedDesign.value.index);
  });
  selectedLanguage.addListener(() {
    prefs.setInt('selectedLanguage', selectedLanguage.value.index);
  });
  darkMode.addListener(() {
    prefs.setBool('darkMode', darkMode.value);
  });
  selectedThemeOption.addListener(() {
    prefs.setInt('selectedThemeOption', selectedThemeOption.value.index);
  });
  gradientDirection.addListener(() {
    prefs.setBool('gradientDirection', gradientDirection.value);
  });

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ThemeData _buildTheme(bool isDark, ThemeOption themeOption) {
    final baseColor = SchoolColors.primaryBlue;
    final accentColor = SchoolColors.getButtonColor(themeOption, isDark);
    final buttonTextColor = SchoolColors.getButtonTextColor(themeOption, isDark);

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
          iconTheme: const IconThemeData(color: Colors.black),
          titleTextStyle: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentColor,
            foregroundColor: buttonTextColor,
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
          foregroundColor: buttonTextColor,
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
    return ValueListenableBuilder3<AppLanguage, bool, ThemeOption>(
      first: selectedLanguage,
      second: darkMode,
      third: selectedThemeOption,
      builder: (context, _, isDark, themeOption, __) {
        final ThemeData lightTheme = _buildTheme(false, themeOption);
        final ThemeData darkThemeData = _buildTheme(true, themeOption);
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
            "/scans": (context) => ScansPage(),
          },
        );
      },
    );
  }
}

// --- Reusable Components ---

// SchoolGradientBackground moved to shared.dart


// AnimatedActionButton moved to shared.dart


// BreadcrumbBar moved to shared.dart


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
    return ValueListenableBuilder<bool>(
      valueListenable: isLoggedIn,
      builder: (context, loggedIn, _) {
        return Scaffold(
          key: _scaffoldKey,
          extendBodyBehindAppBar: true,
          drawer: const AppMenuDrawer(),
          drawerEnableOpenDragGesture: true,
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
                            ValueListenableBuilder<bool>(
                              valueListenable: isLoggedIn,
                              builder: (context, loggedIn, _) {
                                return ValueListenableBuilder<bool>(
                                  valueListenable: darkMode,
                                  builder: (context, isDark, _) {
                                    return IconButton(
                                      icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                                      onPressed: _toggleDrawer,
                                    );
                                  }
                                );
                              },
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
                              ValueListenableBuilder<bool>(
                                valueListenable: isLoggedIn,
                                builder: (context, loggedIn, _) {
                                  return ValueListenableBuilder<bool>(
                                    valueListenable: darkMode,
                                    builder: (context, isDark, _) {
                                      return IconButton(
                                        icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                                        onPressed: _toggleDrawer,
                                      );
                                    }
                                  );
                                },
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
                                    ValueListenableBuilder<bool>(
                                      valueListenable: darkMode,
                                      builder: (context, isDark, _) {
                                        return AnimatedSwitcher(
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
                                                  color: isDark ? Colors.white : Colors.black,
                                                  fontSize: 36,
                                                  shadows: [
                                                    Shadow(
                                                      color: (isDark ? Colors.black : Colors.white).withOpacity(0.3),
                                                      offset: const Offset(0, 4),
                                                      blurRadius: 10,
                                                    ),
                                                  ],
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }
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
                                                child: Container(
                                                  color: Colors.transparent,
                                                  child: Image.network(
                                                    'https://cnvga.ro/wp-content/uploads/2023/11/colegiu-vasile-goldis-arad-logo-512.png',
                                                    height: 80,
                                                    width: 80,
                                                    fit: BoxFit.contain,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return Icon(
                                                        Icons.school,
                                                        size: 80,
                                                        color: SchoolColors.accentGold,
                                                      );
                                                    },
                                                  ),
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
      },
    );
  }
}

// AppMenuDrawer moved to drawer.dart


class HelpPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<AppDesign, bool>(
      first: selectedDesign,
      second: darkMode,
      builder: (context, design, isDark, _) {
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
                  iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
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
                          
                          Column(
                            children: [
                              Text(
                                t('help'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 110.0),
                                child: Text(
                                  t('how_to_use_app'),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
                            icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(child: BreadcrumbBar(path: [t('app_title'), t('help')])),
                          Icon(
                            Icons.help_outline,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 8),
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
                          ValueListenableBuilder<bool>(
                            valueListenable: darkMode,
                            builder: (context, isDark, _) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Text(
                                      t('login'),
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
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
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }
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
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: darkMode,
                            builder: (context, isDark, _) {
                              return IconButton(
                                icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                              );
                            }
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
           if (decoded is String) {
             token = decoded;
           } else if (decoded is Map<String, dynamic>) {
             // Handle case where API returns {"token": "..."} or similar
             if (decoded.containsKey('token')) {
               token = decoded['token'].toString();
             } else if (decoded.containsKey('access_token')) {
               token = decoded['access_token'].toString();
             }
           }
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
    return ValueListenableBuilder2<AppDesign, bool>(
      first: selectedDesign,
      second: darkMode,
      builder: (context, design, isDark, _) {
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
                  iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
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
                          Column(
                            children: [
                              Text(
                                t('about_us'),
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.only(left: 95.0),
                                child: Text(
                                  t('meet_the_team'),
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
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
                            icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                          ),
                          Expanded(child: BreadcrumbBar(path: [t('app_title'), t('about')])),
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 8),
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;
  int _remainingSeconds = 30;
  Uint8List? _qrImageBytes;

  @override
  void initState() {
    super.initState();
    // Automatically generate QR when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateQR();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

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
          _remainingSeconds = 30;
        });
        
        // Start 30s countdown
        _timer?.cancel(); // Cancel any existing
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) {
            timer.cancel();
            return;
          }
          setState(() {
            _remainingSeconds--;
          });
          if (_remainingSeconds <= 0) {
            timer.cancel();
            // Automatically renew the QR code
            _generateQR();
          }
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
        return ValueListenableBuilder<bool>(
          valueListenable: darkMode,
          builder: (context, isDark, _) {
            return Scaffold(
              key: _scaffoldKey,
              drawer: const AppMenuDrawer(),
              appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                  onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                ),
                title: Text(t('request_qr')), 
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
                titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
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
                              const SizedBox(height: 16),
                              const Text("Scan this at the entrance", style: TextStyle(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Text(
                                "Closing in $_remainingSeconds s",
                                style: TextStyle(
                                  color: _remainingSeconds <= 5 ? Colors.red : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),
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
                      const CircularProgressIndicator(color: SchoolColors.accentGold),
                  ],
                ),
              ),
            ),
          );
        }
       );
      }
     );
  }
}

// Helpers moved to shared.dart

