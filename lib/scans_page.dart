import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'shared.dart';
import 'drawer.dart';

class ScansPage extends StatefulWidget {
  @override
  _ScansPageState createState() => _ScansPageState();
}

class _ScansPageState extends State<ScansPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _scans = [];
  Timer? _refreshTimer;
  Duration _timeUntilNextScan = Duration.zero;
  String _selectedRange = 'All'; // 'Today', 'Week', 'Month', 'All'


  @override
  void initState() {
    super.initState();
    _fetchScans();
    // Update countdown every second
    _refreshTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _recalculateCountdown();
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchScans() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null) {
        setState(() {
          _errorMessage = "Not logged in";
          _isLoading = false;
        });
        return;
      }

      final now = DateTime.now();
      String start;
      String end = now.add(const Duration(days: 1)).toUtc().toIso8601String();

      switch (_selectedRange) {
        case 'Today':
          final startOfDay = DateTime(now.year, now.month, now.day);
          start = startOfDay.toUtc().toIso8601String();
          break;
        case 'Week':
          start = now.subtract(const Duration(days: 7)).toUtc().toIso8601String();
          break;
        case 'Month':
          start = now.subtract(const Duration(days: 30)).toUtc().toIso8601String();
          break;
        case 'All':
        default:
          start = DateTime(2020).toUtc().toIso8601String();
          break;
      }

      final uri = Uri.parse('https://api.pontaj.binarysquad.club/mobile/enrolled_student_scans')
          .replace(queryParameters: {
        'start': start,
        'end': end,
      });

      final response = await http.get(
        uri,
        headers: {
          'accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        // Handle case where API returns a Map with a 'data' field or similar
        if (data is Map<String, dynamic>) {
           // Common wrapper patterns
           if (data.containsKey('data') && data['data'] is List) {
             data = data['data'];
           } else if (data.containsKey('scans') && data['scans'] is List) {
             data = data['scans'];
           }
        }

        if (data is List) {
          // Sort descending by time
          List<dynamic> scans = List.from(data);
          
          scans.sort((a, b) {
            DateTime? dateA = _parseDate(a);
            DateTime? dateB = _parseDate(b);
            if (dateA == null || dateB == null) return 0;
            return dateB.compareTo(dateA); // Descending
          });

          setState(() {
            _scans = scans;
            _isLoading = false;
          });
          _recalculateCountdown();
        } else {
           setState(() {
            _errorMessage = "Unexpected data type: ${data.runtimeType}";
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = "Error ${response.statusCode}";
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Network error: $e";
        _isLoading = false;
      });
    }
  }

  DateTime? _parseDate(dynamic scanItem) {
    if (scanItem is String) {
      // Parse as UTC and convert to local
      final parsed = DateTime.tryParse(scanItem);
      if (parsed != null) {
        // If the string doesn't have 'Z' at the end, assume it's UTC
        if (!scanItem.endsWith('Z') && !scanItem.contains('+')) {
          return DateTime.utc(parsed.year, parsed.month, parsed.day, 
                             parsed.hour, parsed.minute, parsed.second);
        }
        return parsed;
      }
    } else if (scanItem is Map) {
      // Try to find a date field
      for (var key in ['created_at', 'timestamp', 'time', 'date', 'scan_time']) {
        if (scanItem[key] != null) {
          final dateStr = scanItem[key].toString();
          final parsed = DateTime.tryParse(dateStr);
          if (parsed != null) {
            // If the string doesn't have 'Z' at the end, assume it's UTC
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

  void _recalculateCountdown() {
    if (_scans.isEmpty) {
      if (mounted) setState(() => _timeUntilNextScan = Duration.zero);
      return;
    }

    final lastScanDate = _parseDate(_scans.first);
    if (lastScanDate != null) {
      // Convert UTC time from API to local time (UTC+2)
      final lastScanLocal = lastScanDate.toLocal();
      
      // Next scan allowed 1 hour after last scan
      final nextAllowed = lastScanLocal.add(const Duration(hours: 1));
      final now = DateTime.now();
      final diff = nextAllowed.difference(now);
      
      if (mounted) {
        setState(() {
          _timeUntilNextScan = diff.isNegative ? Duration.zero : diff;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLanguage>(
      valueListenable: selectedLanguage,
      builder: (context, lang, _) {
        return ValueListenableBuilder3<AppDesign, bool, ThemeOption>(
          first: selectedDesign,
          second: darkMode,
          third: selectedThemeOption,
          builder: (context, design, isDark, themeOption, _) {
           return Scaffold(
             key: _scaffoldKey,
             extendBodyBehindAppBar: true,
             drawer: const AppMenuDrawer(),
             appBar: AppBar(
                leading: IconButton(
                  icon: Icon(Icons.menu, color: isDark ? Colors.white : Colors.black),
                  onPressed: () {
                    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
                      _scaffoldKey.currentState?.closeDrawer();
                    } else {
                      _scaffoldKey.currentState?.openDrawer();
                    } 
                  }, 
                ),
                title: Text(t('my_scans')),
                centerTitle: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
                titleTextStyle: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
             ),
             body: Stack(
               children: [
                 SchoolGradientBackground(
                   child: SafeArea(
                     child: Column(
                       children: [
                          // Filter Buttons
                          _buildFilterButtons(),
                          // Header / Countdown
                          _buildHeader(context),
                          Expanded(
                            child: _isLoading 
                              ? Center(child: CircularProgressIndicator(color: isDark ? Colors.white : Colors.black))
                              : _errorMessage != null
                                ? Center(child: Text(_errorMessage!, style: TextStyle(color: isDark ? Colors.white : Colors.black)))
                                : _buildScansList(),
                          ),
                       ],
                     ),
                   ),
                 ),
               ],
             ),
           );
          }
        );
      }
    );
  }

  Widget _buildHeader(BuildContext context) {
    String timerText = "00:00:00";
    if (_timeUntilNextScan.inSeconds > 0) {
      final h = _timeUntilNextScan.inHours.toString().padLeft(2, '0');
      final m = (_timeUntilNextScan.inMinutes % 60).toString().padLeft(2, '0');
      final s = (_timeUntilNextScan.inSeconds % 60).toString().padLeft(2, '0');
      timerText = "$h:$m:$s";
    }

    bool canScan = _timeUntilNextScan.inSeconds <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: (darkMode.value ? Colors.white : Colors.black).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: (darkMode.value ? Colors.white : Colors.black).withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(
            canScan ? t('scan_ready') : t('next_scan_in'),
            style: TextStyle(color: darkMode.value ? Colors.white70 : Colors.black54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            canScan ? "GO" : timerText,
            style: TextStyle(
              color: canScan ? Colors.greenAccent : (darkMode.value ? Colors.white : Colors.black),
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          if (canScan)
             Padding(
               padding: const EdgeInsets.only(top: 10.0),
               child: Column(
                 children: [
                   Text(
                     t('ready_for_qr'),
                     style: TextStyle(color: darkMode.value ? Colors.white : Colors.black, fontSize: 16),
                   ),
                   const SizedBox(height: 12),
                   ElevatedButton.icon(
                     onPressed: () {
                       Navigator.pushNamed(context, '/request-qr');
                     },
                     icon: const Icon(Icons.qr_code_2),
                     label: Text(t('request_qr')),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: SchoolColors.getButtonColor(selectedThemeOption.value, darkMode.value),
                       foregroundColor: SchoolColors.getButtonTextColor(selectedThemeOption.value, darkMode.value),
                       padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                       shape: RoundedRectangleBorder(
                         borderRadius: BorderRadius.circular(12),
                       ),
                     ),
                   ),
                 ],
               ),
             )
        ],
      ),
    );
  }

  Widget _buildFilterButtons() {
    // Map of internal filter values to translation keys
    final filterMap = {
      'All': 'filter_all',
      'Month': 'filter_month',
      'Week': 'filter_week',
      'Today': 'filter_today',
    };
    
    final filters = ['All', 'Month', 'Week', 'Today'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: filters.map((filter) {
          final isSelected = _selectedRange == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(t(filterMap[filter]!)),
              selected: isSelected,
              selectedColor: SchoolColors.getButtonColor(selectedThemeOption.value, darkMode.value),
              backgroundColor: Colors.white.withOpacity(0.1),
              labelStyle: TextStyle(
                color: isSelected ? SchoolColors.getButtonTextColor(selectedThemeOption.value, darkMode.value) : (darkMode.value ? Colors.white : Colors.black),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              onSelected: (bool selected) {
                if (selected) {
                  setState(() {
                    _selectedRange = filter;
                  });
                  _fetchScans();
                }
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildScansList() {
    if (_scans.isEmpty) {
      return Center(child: Text(t('no_scans_yet') ?? "No scans yet", style: TextStyle(color: darkMode.value ? Colors.white70 : Colors.black54)));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _scans.length,
      itemBuilder: (context, index) {
        final scan = _scans[index];
        final date = _parseDate(scan);
        // Convert UTC to local time and format nicely
        final localDate = date?.toLocal();
        final dateStr = localDate != null 
            ? "${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')} ${localDate.hour.toString().padLeft(2, '0')}:${localDate.minute.toString().padLeft(2, '0')}:${localDate.second.toString().padLeft(2, '0')}"
            : "Unknown date";
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: SchoolColors.primaryBlue.withOpacity(0.1),
              child: const Icon(Icons.check, color: SchoolColors.primaryBlue),
            ),
            title: Text(t('scanned_at'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
            subtitle: Text(dateStr, style: const TextStyle(color: Colors.black54)),
          ),
        );
      },
    );
  }
}
