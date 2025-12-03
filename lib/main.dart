import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui'; // For ImageFilter

// Simple global auth state for demo purposes
final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);

// Add these ValueNotifiers after isLoggedIn at the top:
enum AppLanguage { en, ro }
enum AppDesign { def, adv }
final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
final ValueNotifier<AppLanguage> selectedLanguage = ValueNotifier<AppLanguage>(AppLanguage.en);
final ValueNotifier<AppDesign> selectedDesign = ValueNotifier<AppDesign>(AppDesign.def);

// --- School Theme Constants ---
class SchoolColors {
  static const Color primaryBlue = Color(0xFF002B5C); // Deep Blue
  static const Color accentGold = Color(0xFFD4AF37); // Gold
  static const Color lightBackground = Color(0xFFF5F5F5); // Light Gray
  static const Color darkBackground = Color(0xFF121212); // Dark Gray
  
  static const List<Color> primaryGradient = [
    Color(0xFF002B5C),
    Color(0xFF004080),
  ];
  
  static const List<Color> darkGradient = [
    Color(0xFF001A38),
    Color(0xFF002B5C),
  ];
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
      'login': 'Login',
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
      'invalid_test_code': 'Invalid test code. Try "enter".',
      'type_enter_in_field_and_press_enter': 'Type "enter" in the field and press Enter.',
      'meet_the_team': 'Meet the team',
      'we_are_a_small_team_focused_on_building_simple': 'We are a small team focused on building simple,',
      'useful_tools_for_students_and_schools': 'useful tools for students and schools.',
      'dont_forget_to_remove_the_test_code_enter': 'Don\'t forget to remove the test code "enter" before release.',
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
      'login': 'Autentificare',
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
      'invalid_test_code': 'Cod de test invalid. Încearcă „enter”.',
      'type_enter_in_field_and_press_enter': 'Scrie „enter” în câmp și apasă Enter.',
      'meet_the_team': 'Cunoaște echipa',
      'we_are_a_small_team_focused_on_building_simple': 'Suntem o echipă mică, concentrată pe a crea soluții simple,',
      'useful_tools_for_students_and_schools': 'utile pentru elevi și școli.',
      'dont_forget_to_remove_the_test_code_enter': 'Nu uita să elimini codul de test „enter” înainte de lansare.',
      'ready_for_qr': 'Totul este pregătit pentru a cere coduri QR!'
    }
  };
  final code = selectedLanguage.value == AppLanguage.en ? 'en' : 'ro';
  return translations[code]![key] ?? key;
}
// ---

void main() {
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
    return ValueListenableBuilder<bool>(
      valueListenable: darkMode,
      builder: (context, isDark, _) {
        return Container(
          height: MediaQuery.of(context).size.height * heightFraction,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark ? SchoolColors.darkGradient : SchoolColors.primaryGradient,
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
                  child: Container(), // Content is overlayed
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
                                        child: Icon(
                                          Icons.school, // Changed to school icon
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
                            return buildMenuItem(
                              dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              t('theme'),
                              () => darkMode.value = !darkMode.value,
                              trailing: Switch(
                                value: dark,
                                activeColor: SchoolColors.accentGold,
                                onChanged: (v) => darkMode.value = v,
                              ),
                            );
                          },
                        ),
                        ValueListenableBuilder<AppDesign>(
                          valueListenable: selectedDesign,
                          builder: (context, design, _) {
                            return buildMenuItem(
                              Icons.design_services_rounded,
                              t('design'),
                              () => selectedDesign.value = selectedDesign.value == AppDesign.def ? AppDesign.adv : AppDesign.def,
                              trailing: Text(
                                design == AppDesign.adv ? 'ADV' : 'DEF',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: SchoolColors.primaryBlue),
                              ),
                            );
                          },
                        ),
                        buildMenuItem(
                          Icons.language_rounded,
                          t('language'),
                          () => selectedLanguage.value = selectedLanguage.value == AppLanguage.en ? AppLanguage.ro : AppLanguage.en,
                          trailing: Text(
                            lang == AppLanguage.ro ? 'RO' : 'EN',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: SchoolColors.primaryBlue),
                          ),
                        ),
                        if (isLoggedIn.value) ...[
                          const Divider(height: 32),
                          buildMenuItem(
                            Icons.logout_rounded,
                            t('logout'),
                            () {
                              Navigator.pop(context);
                              isLoggedIn.value = false;
                              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                            },
                            textColor: Colors.redAccent,
                            iconColor: Colors.redAccent,
                          ),
                        ],
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
                  // Leading automatically becomes Hamburger if drawer is present
                  title: Text(t('help')),
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
                          if (design != AppDesign.adv) const SizedBox(height: 40),
                          if (design == AppDesign.adv)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                t('help'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Icon(Icons.help_outline, size: 60, color: Colors.white.withOpacity(0.9)),
                          const SizedBox(height: 16),
                          Text(
                            t('how_to_use_app'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
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
                  title: Text(t('login')),
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
                          if (design != AppDesign.adv) const SizedBox(height: 40),
                          if (design == AppDesign.adv)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
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
                            child: Icon(Icons.school, size: 80, color: SchoolColors.accentGold),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('enter_school_code'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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

  void _tryLogin([String? codeStr]) {
    final code = codeStr ?? _controller.text;
    if (code.trim().toLowerCase() == 'enter') {
      isLoggedIn.value = true;
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 12),
              Text(t('invalid_test_code')),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
          onSubmitted: _tryLogin,
          decoration: InputDecoration(
            labelText: t('school_code_hint'),
            prefixIcon: const Icon(Icons.vpn_key_outlined, color: SchoolColors.primaryBlue),
          ),
        ),
        const SizedBox(height: 24),
        AnimatedActionButton(
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
                  title: Text(t('about_us')),
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
                          if (design != AppDesign.adv) const SizedBox(height: 40),
                          if (design == AppDesign.adv)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Text(
                                t('about_us'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Icon(Icons.info_outline, size: 60, color: Colors.white),
                          const SizedBox(height: 16),
                          Text(
                            t('meet_the_team'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.withOpacity(0.5)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                t('dont_forget_to_remove_the_test_code_enter'),
                                style: TextStyle(
                                  color: Colors.amber[900],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
class RequestQRPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(t('request_qr')), backgroundColor: SchoolColors.primaryBlue),
      body: Center(child: Text(t('temporary_notice'))),
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
