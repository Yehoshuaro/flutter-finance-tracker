import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_prefs_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  bool _useSystemTheme = true;
  final UserPrefsService _userPrefsService = UserPrefsService();

  bool _isSunset = false;
  bool _isCyanDark = false;
  bool _isForestDark = false;

  ThemeProvider() {
    _initTheme();
  }

  ThemeMode get themeMode => _useSystemTheme ? ThemeMode.system : _themeMode;
  bool get useSystemTheme => _useSystemTheme;
  bool get isSunset => !_useSystemTheme && _isSunset;
  bool get isCyanDark => !_useSystemTheme && _isCyanDark;
  bool get isForestDark => !_useSystemTheme && _isForestDark;

  void toggleTheme() {
    if (_useSystemTheme) {
      _useSystemTheme = false;
      _themeMode = ThemeMode.light;
      _isSunset = false;
      _isCyanDark = false;
      _isForestDark = false;
    } else {
      if (_isSunset || _isCyanDark || _isForestDark) {
        _isSunset = false;
        _isCyanDark = false;
        _isForestDark = false;
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      }
    }
    notifyListeners();
    _savePrefs();
  }

  Future<void> _initTheme() async {
     _prefs = await SharedPreferences.getInstance();
     final guestData = await _userPrefsService.loadGuestData();
     final guestTheme = guestData['theme'] as String;
      if (guestTheme == 'system') {
           _useSystemTheme = true;
           _isSunset = false;
           _isCyanDark = false;
           _isForestDark = false;
        } else if (guestTheme == 'sunset') {
           _useSystemTheme = false;
           _isSunset = true;
           _isCyanDark = false;
           _isForestDark = false;
        } else if (guestTheme == 'cyanDark') {
           _useSystemTheme = false;
           _isSunset = false;
           _isCyanDark = true;
           _isForestDark = false;
        } else if (guestTheme == 'forestDark') {
           _useSystemTheme = false;
           _isSunset = false;
           _isCyanDark = false;
           _isForestDark = true;
        } else {
           _useSystemTheme = false;
           _isSunset = false;
           _isCyanDark = false;
           _isForestDark = false;
           _themeMode = ThemeMode.values.firstWhere(
              (e) => e.toString().split('.').last == guestTheme,
              orElse: () => ThemeMode.system,
           );
        }
     notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode && !_useSystemTheme && !_isSunset && !_isCyanDark && !_isForestDark) return;

    _useSystemTheme = false;
    _isSunset = false;
    _isCyanDark = false;
    _isForestDark = false;
    _themeMode = themeMode;
    await _prefs.setString(_themeModeKey, themeMode.toString());
    _savePrefs();
    notifyListeners();
  }

  Future<void> setSunsetTheme() async {
    if (_isSunset && !_useSystemTheme) return;
    _useSystemTheme = false;
    _isSunset = true;
    _isCyanDark = false;
    _isForestDark = false;
    notifyListeners();
    _savePrefs();
  }

  Future<void> setCyanDarkTheme() async {
    if (_isCyanDark && !_useSystemTheme) return;
    _useSystemTheme = false;
    _isSunset = false;
    _isCyanDark = true;
    _isForestDark = false;
    notifyListeners();
    _savePrefs();
  }

  Future<void> setForestDarkTheme() async {
    if (_isForestDark && !_useSystemTheme) return;
    _useSystemTheme = false;
    _isSunset = false;
    _isCyanDark = false;
    _isForestDark = true;
    notifyListeners();
    _savePrefs();
  }

  void useSystemSettings() {
     if (_useSystemTheme) return;

    _useSystemTheme = true;
    _isSunset = false;
    _isCyanDark = false;
    _isForestDark = false;
    _savePrefs();
    notifyListeners();
  }

  void _savePrefs() {
    _userPrefsService.saveGuestTheme(
      _useSystemTheme
        ? 'system'
        : (_isSunset
            ? 'sunset'
            : _isCyanDark
                ? 'cyanDark'
                : _isForestDark
                    ? 'forestDark'
                    : _themeMode.toString().split('.').last),
    );
  }

  void setThemeFromString(String theme) {
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
      _useSystemTheme = false;
      _isSunset = false;
      _isCyanDark = false;
      _isForestDark = false;
    } else if (theme == 'light') {
      _themeMode = ThemeMode.light;
      _useSystemTheme = false;
      _isSunset = false;
      _isCyanDark = false;
      _isForestDark = false;
    } else if (theme == 'sunset') {
      _isSunset = true;
      _useSystemTheme = false;
      _isCyanDark = false;
      _isForestDark = false;
    } else if (theme == 'cyanDark') {
      _isCyanDark = true;
      _useSystemTheme = false;
      _isSunset = false;
      _isForestDark = false;
    } else if (theme == 'forestDark') {
      _isForestDark = true;
      _useSystemTheme = false;
      _isSunset = false;
      _isCyanDark = false;
    } else {
      _useSystemTheme = true;
      _isSunset = false;
      _isCyanDark = false;
      _isForestDark = false;
    }
    notifyListeners();
  }

  ThemeData get themeData {
    if (_useSystemTheme) {
      return ThemeData.fallback();
    }
    if (_isSunset) {
      return _buildSunsetTheme();
    }
    if (_isCyanDark) {
      return _buildCyanDarkTheme();
    }
    if (_isForestDark) {
      return _buildForestDarkTheme();
    }
    return _themeMode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light();
  }

  ThemeData _buildSunsetTheme() {
    const seed = Color(0xFF6C2000); // more vivid deep orange
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      primary: const Color(0xFF631501), // vivid orange-red
      secondary: const Color(0xFFD32F2F), // strong red
      tertiary: const Color(0xFFD72F00),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFF0E6),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      chipTheme: ChipThemeData(
        selectedColor: colorScheme.primary.withOpacity(0.15),
        secondarySelectedColor: colorScheme.secondary.withOpacity(0.15),
        labelStyle: TextStyle(color: colorScheme.primary),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 3,
        shadowColor: colorScheme.primary.withOpacity(0.25),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        margin: const EdgeInsets.all(8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.primary.withOpacity(0.7),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
    );
  }

  ThemeData _buildCyanDarkTheme() {
    const seed = Color(0xFF008191); // cyan
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      primary: const Color(0xFF00ACC1), // cyan 600
      secondary: const Color(0xFF26C6DA), // cyan 400
      tertiary: const Color(0xFF00838F), // cyan 800
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121D21),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF152C33),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0B1316),
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF122126),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }

  ThemeData _buildForestDarkTheme() {
    const seed = Color(0xFF2E7D32); // green 800
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      primary: const Color(0xFF1B5E20), // deep green
      secondary: const Color(0xFF43A047), // green 600
      tertiary: const Color(0xFF66BB6A),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF111C1A),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardTheme(
        color: const Color(0xFF122312),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0A120B),
        selectedItemColor: colorScheme.secondary,
        unselectedItemColor: Colors.white70,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0F1811),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.secondary, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.secondary,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
    );
  }
} 