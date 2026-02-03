import 'package:flutter/material.dart';
import 'dart:ui'; // For ImageFilter
import 'shared.dart';

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
                final effectiveIconColor = iconColor ?? SchoolColors.getMenuIconColor(selectedThemeOption.value, darkMode.value);
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
                  ValueListenableBuilder3<ThemeOption, bool, bool>(
                    first: selectedThemeOption,
                    second: gradientDirection,
                    third: darkMode,
                    builder: (context, theme, direction, isDark, _) {
                      return DrawerHeader(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: SchoolColors.getGradient(theme, isDark, direction),
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
                                ValueListenableBuilder<bool>(
                                  valueListenable: darkMode,
                                  builder: (context, isDark, _) {
                                    return Text(
                                      t('menu'),
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                      ),
                                    );
                                  }
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: isLoggedIn,
                      builder: (context, loggedIn, _) {
                        return ListView(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          children: [
                            if (loggedIn) ...[
                              buildMenuItem(Icons.home_rounded, t('home'), () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/");
                              }),
                              buildMenuItem(Icons.history, t('scans'), () {
                                Navigator.pop(context);
                                Navigator.pushNamed(context, "/scans");
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
                                              design == AppDesign.def ? "SIM" : "ADV",
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
                              ValueListenableBuilder<ThemeOption>(
                                valueListenable: selectedThemeOption,
                                builder: (context, theme, _) {
                                  final iconColor = SchoolColors.getMenuIconColor(theme, darkMode.value);
                                  return Theme(
                                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                    child: ExpansionTile(
                                      leading: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: iconColor.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(Icons.color_lens, color: iconColor, size: 20),
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
                                                        Icon(Icons.rotate_right, color: iconColor),
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
                                  );
                                }
                              ),

                              const Divider(height: 32, thickness: 1),
                            ],

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
                            
                            if (loggedIn) ...[
                              const Divider(height: 32, thickness: 1),
                              buildMenuItem(Icons.logout_rounded, t('logout'), () {
                                isLoggedIn.value = false;
                                // Navigate to home and remove all previous routes to prevent back navigation
                                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                              }, textColor: Colors.redAccent, iconColor: Colors.redAccent),
                            ],
                          ],
                        );
                      }
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
                  ? SchoolColors.getAccentColor(option, Theme.of(context).brightness == Brightness.dark)
                  : Colors.grey, // Grey for unselected as requested
              border: Border.all(color: Colors.grey.withOpacity(0.3)),
            ),
          ),
        ],
      ),
    );
  }
}
