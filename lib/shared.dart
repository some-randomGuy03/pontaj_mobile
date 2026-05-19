import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:ui'; // For ImageFilter

// --- Enums ---
enum AppDesign { def, adv }
enum AppLanguage { en, ro }
enum ThemeOption { yellowBlue, blueWhite, yellowWhite }

// --- Global State ---
final ValueNotifier<AppLanguage> selectedLanguage = ValueNotifier<AppLanguage>(AppLanguage.ro);
final ValueNotifier<bool> isLoggedIn = ValueNotifier<bool>(false);
final ValueNotifier<AppDesign> selectedDesign = ValueNotifier<AppDesign>(AppDesign.adv);
final ValueNotifier<bool> darkMode = ValueNotifier<bool>(false);
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

  // Helper for specific dynamic colors
  static Color getButtonColor(ThemeOption option, bool isDark) {
    switch (option) {
      case ThemeOption.yellowWhite:
        return isDark ? _darkGold : _gold;
      case ThemeOption.blueWhite:
        // "Light blue in light theme, dark blue in dark theme"
        // We use a lighter blue for light mode to be distinct from the primary navy
        return isDark ? _blue : const Color(0xFF4A90E2); 
      case ThemeOption.yellowBlue:
        // Pages: Yellow in light mode, Blue in dark mode
        return isDark ? _blue : _gold;
    }
  }

  static Color getButtonTextColor(ThemeOption option, bool isDark) {
    switch (option) {
       case ThemeOption.yellowWhite:
         return isDark ? _white : _black; // White text on dark gold, black on light gold
       case ThemeOption.blueWhite:
         return isDark ? _white : Colors.black87; // White text in dark mode, black in light mode
       case ThemeOption.yellowBlue:
         return isDark ? _white : _blue;  // White text in dark mode, blue text in light mode
    }
  }

  static Color getMenuIconColor(ThemeOption option, bool isDark) {
    switch (option) {
       case ThemeOption.yellowWhite:
         return isDark ? _darkGold : _gold;
       case ThemeOption.blueWhite:
         return isDark ? _blue : const Color(0xFF4A90E2);
       case ThemeOption.yellowBlue:
         // Drawer icons: Blue in light mode, Yellow in dark mode
         return isDark ? _gold : primaryBlue;
    }
  }

  static Color getAccentColor(ThemeOption option, bool isDark) {
    switch (option) {
      case ThemeOption.yellowWhite:
        return isDark ? _darkGold : _gold;
      case ThemeOption.blueWhite:
        return isDark ? _blue : const Color(0xFF4A90E2);
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

// --- Localization ---
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
      'enter_school_code': 'Log in with your school code',
      'tap_start_to_sign_in': 'Use the button in the menu to create a QR code',
      'use_app_to_manage_attendance': 'Scan the QR code at the exit camera to exit',
      'invalid_credentials': 'Invalid credentials. Please check your code.',
      'enrollment_success': 'Enrollment successful!',
      'network_error': 'Network error. Please try again.',
      'enter_code_first': 'Please enter your school code first.',
      'validating': 'Validating...',
      'meet_the_team': 'Meet the team',
      'we_are_a_small_team_focused_on_building_simple': 'We are a small team focused on building simple,',
      'useful_tools_for_students_and_schools': 'useful tools for students and schools.',
      'ready_for_qr': 'All set up for requesting QRs!',
      'scans': 'Scans',
      'my_scans': 'My Scans',
      'next_scan_in': 'Next scan available in:',
      'scan_ready': 'Scan Ready',
      'scanned_at': 'Scanned at',
      'filter_all': 'All',
      'filter_month': 'Month',
      'filter_week': 'Week',
      'filter_today': 'Today',
      'help_note_title': 'Note:',
      'help_note_desc': 'Once logged in, you never have to log out. Remember to check the cooldown for requesting QR codes.',
      'qr_cooldown_error': 'Check your QR cooldown'
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
      'enter_school_code': 'Autentifică-te cu codul școlii',
      'tap_start_to_sign_in': 'Folosește butonul din meniu pentru a genera un cod QR',
      'use_app_to_manage_attendance': 'Scanează codul QR la camera de la ieșire pentru a ieși',
      'invalid_credentials': 'Credențiale invalide. Verifică codul.',
      'enrollment_success': 'Înrolare reușită!',
      'network_error': 'Eroare de rețea. Încearcă din nou.',
      'enter_code_first': 'Te rugăm să introduci codul școlii mai întâi.',
      'validating': 'Se verifică...',
      'meet_the_team': 'Cunoaște echipa',
      'we_are_a_small_team_focused_on_building_simple': 'Suntem o echipă mică, concentrată pe a crea soluții simple,',
      'useful_tools_for_students_and_schools': 'utile pentru elevi și școli.',
      'ready_for_qr': 'Totul este pregătit pentru a cere coduri QR!',
      'scans': 'Scanări',
      'my_scans': 'Scanările mele',
      'next_scan_in': 'Următoarea scanare în:',
      'scan_ready': 'Poți scana acum',
      'scanned_at': 'Scanat la',
      'filter_all': 'Toate',
      'filter_month': 'Luna',
      'filter_week': 'Săptămâna',
      'filter_today': 'Astăzi',
      'help_note_title': 'Notă:',
      'help_note_desc': 'Odată autentificat, nu trebuie să te deconectezi niciodată. Amintește-ți să verifici timpul de așteptare pentru generarea de noi coduri QR.',
      'qr_cooldown_error': 'Verifică timpul de așteptare pentru QR'
    }
  };
  final code = selectedLanguage.value == AppLanguage.en ? 'en' : 'ro';
  return translations[code]![key] ?? key;
}

DateTime? parseScanDate(dynamic scanItem) {
  if (scanItem is String) {
    final parsed = DateTime.tryParse(scanItem);
    if (parsed != null) {
      if (!scanItem.endsWith('Z') && !scanItem.contains('+')) {
        return DateTime.utc(parsed.year, parsed.month, parsed.day, 
                           parsed.hour, parsed.minute, parsed.second);
      }
      return parsed;
    }
  } else if (scanItem is Map) {
    for (var key in ['created_at', 'timestamp', 'time', 'date', 'scan_time']) {
      if (scanItem[key] != null) {
        final dateStr = scanItem[key].toString();
        final parsed = DateTime.tryParse(dateStr);
        if (parsed != null) {
          if (!dateStr.endsWith('Z') && !dateStr.contains('+')) {
            return DateTime.utc(parsed.year, parsed.month, parsed.day, 
                               parsed.hour, parsed.minute, parsed.second);
          }
          return parsed;
        }
      }
    }
  }
  return null;
}


// --- Reusable Components ---

class SchoolGradientBackground extends StatelessWidget {
  final Widget child;
  final double heightFraction;

  const SchoolGradientBackground({
    Key? key,
    required this.child,
    this.heightFraction = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<ThemeOption, bool>(
      first: selectedThemeOption,
      second: gradientDirection,
      builder: (context, theme, direction, _) {
       return ValueListenableBuilder<bool>(
         valueListenable: darkMode,
         builder: (context, isDark, _) {
            final gradientColors = SchoolColors.getGradient(theme, isDark, direction);
            return Stack(
              children: [
                // Background Gradient
                Container(
                  height: MediaQuery.of(context).size.height * heightFraction,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: heightFraction < 1.0 
                      ? const BorderRadius.vertical(bottom: Radius.circular(40)) 
                      : null,
                  ),
                ),
                // Overlay Pattern (Subtle)
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.05,
                    child: CustomPaint(
                      painter: PatternPainter(),
                    ),
                  ),
                ),
                child,
              ],
            );
         }
       );
      },
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double step = 40;
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AnimatedActionButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final int delayMs; // Animation delay

  const AnimatedActionButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.delayMs = 0,
  }) : super(key: key);

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<ThemeOption, bool>(
      first: selectedThemeOption,
      second: darkMode,
      builder: (context, theme, isDark, _) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: SchoolColors.getButtonColor(theme, isDark),
                foregroundColor: SchoolColors.getButtonTextColor(theme, isDark),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
                shadowColor: SchoolColors.getButtonColor(theme, isDark).withOpacity(0.5),
              ),
              child: Text(
                widget.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class BreadcrumbBar extends StatelessWidget {
  final List<String> path;

  const BreadcrumbBar({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkMode,
      builder: (context, isDark, _) {
        final textColor = isDark ? Colors.white : Colors.black;
        final dividerColor = isDark ? Colors.white70 : Colors.black54;
        
        return Row(
          children: path.asMap().entries.map((entry) {
            final int index = entry.key;
            final String item = entry.value;
            final bool isLast = index == path.length - 1;

            return Row(
              children: [
                if (index > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(Icons.chevron_right, color: dividerColor, size: 16),
                  ),
                Text(
                  item,
                  style: TextStyle(
                    color: isLast ? textColor : dividerColor,
                    fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }).toList(),
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
