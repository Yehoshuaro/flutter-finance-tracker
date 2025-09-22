import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_prefs_service.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'themeMode';
  late SharedPreferences _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  bool _useSystemTheme = true;
  final UserPrefsService _userPrefsService = UserPrefsService(); // Создаем экземпляр сервиса

  // Custom gradient theme flag
  bool _isSunset = false; // оранжево-красный градиент

  ThemeProvider() {
    // _loadThemeMode(); // Удаляем прямой вызов загрузки
    _initTheme(); // Добавляем новый метод инициализации
    // Слушаем изменения состояния авторизации
    // FirebaseAuth.instance.authStateChanges().listen((user) {
    //   _initTheme(); // Переинициализируем тему при изменении пользователя
    // });
  }

  ThemeMode get themeMode => _useSystemTheme ? ThemeMode.system : _themeMode;
  bool get useSystemTheme => _useSystemTheme;
  bool get isSunset => !_useSystemTheme && _isSunset;

  void toggleTheme() {
    if (_useSystemTheme) {
      _useSystemTheme = false;
      _themeMode = ThemeMode.light;
      _isSunset = false;
    } else {
      // toggle only between light and dark when not using custom theme
      if (_isSunset) {
        _isSunset = false;
        _themeMode = ThemeMode.light;
      } else {
        _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      }
    }
    notifyListeners();
    _savePrefs();
  }

  Future<void> _initTheme() async {
     _prefs = await SharedPreferences.getInstance(); // Убедимся, что prefs инициализирован
     // final user = FirebaseAuth.instance.currentUser;
     // Гость/локальный режим
     final guestData = await _userPrefsService.loadGuestData();
     final guestTheme = guestData['theme'] as String;
      if (guestTheme == 'system') {
           _useSystemTheme = true;
           _isSunset = false;
        } else if (guestTheme == 'sunset') {
           _useSystemTheme = false;
           _isSunset = true;
        } else {
           _useSystemTheme = false;
           _isSunset = false;
           _themeMode = ThemeMode.values.firstWhere(
              (e) => e.toString().split('.').last == guestTheme,
              orElse: () => ThemeMode.system,
           );
        }
     notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (_themeMode == themeMode && !_useSystemTheme && !_isSunset) return; // Проверяем также системные

    _useSystemTheme = false; // При ручной установке темы отключаем системные
    _isSunset = false; // Выключаем кастомную тему при выборе стандартных
    _themeMode = themeMode;
    await _prefs.setString(_themeModeKey, themeMode.toString()); // Сохраняем в SharedPreferences (на всякий случай)
    _savePrefs(); // Сохраняем в Firebase (если авторизован)
    notifyListeners();
  }

  Future<void> setSunsetTheme() async {
    if (_isSunset && !_useSystemTheme) return;
    _useSystemTheme = false;
    _isSunset = true;
    notifyListeners();
    _savePrefs();
  }

  void useSystemSettings() {
     if (_useSystemTheme) return; // Если уже системные, выходим

    _useSystemTheme = true;
    _isSunset = false;
     // Не сохраняем в SharedPreferences, так как используем системные
    _savePrefs(); // Сохраняем 'system' в Firebase
    notifyListeners();
  }

  void _savePrefs() {
    // Всегда сохраняем для гостя в SharedPreferences
    _userPrefsService.saveGuestTheme(_useSystemTheme
        ? 'system'
        : (_isSunset ? 'sunset' : _themeMode.toString().split('.').last));
  }

  void setThemeFromString(String theme) {
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
      _useSystemTheme = false;
      _isSunset = false;
    } else if (theme == 'light') {
      _themeMode = ThemeMode.light;
      _useSystemTheme = false;
      _isSunset = false;
    } else if (theme == 'sunset') {
      _isSunset = true;
      _useSystemTheme = false;
    } else {
      _useSystemTheme = true;
      _isSunset = false;
    }
    notifyListeners();
  }

  ThemeData get themeData {
    if (_useSystemTheme) {
      // Use system theme
      return ThemeData.fallback();
    }
    if (_isSunset) {
      return _buildSunsetTheme();
    }
    return _themeMode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light();
  }

  ThemeData _buildSunsetTheme() {
    // Оранжево-красная палитра с акцентами
    const seed = Color(0xFFFF7043); // deep orange
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      primary: const Color(0xFFFF6F00), // orange 800
      secondary: const Color(0xFFE53935), // red 600
      brightness: Brightness.light,
    );

    return ThemeData(
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFF3E0),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(8),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.primary.withOpacity(0.6),
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
} 