import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';

class SettingsNotifier extends AsyncNotifier<SettingsEntity> {
  @override
  Future<SettingsEntity> build() async {
    final prefs = await SharedPreferences.getInstance();
    
    final currency = prefs.getString('currency') ?? 'USD';
    
    final themeIndex = prefs.getInt('themeMode') ?? ThemeMode.system.index;
    final themeMode = ThemeMode.values[themeIndex];
    
    final language = prefs.getString('language') ?? 'en';
    final decimalFormat = prefs.getInt('decimalFormat') ?? 2;
    final firstDayOfWeek = prefs.getInt('firstDayOfWeek') ?? 1;
    final notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;

    return SettingsEntity(
      currency: currency,
      themeMode: themeMode,
      language: language,
      decimalFormat: decimalFormat,
      firstDayOfWeek: firstDayOfWeek,
      notificationsEnabled: notificationsEnabled,
    );
  }

  Future<void> updateSettings(SettingsEntity newSettings) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('currency', newSettings.currency);
    await prefs.setInt('themeMode', newSettings.themeMode.index);
    await prefs.setString('language', newSettings.language);
    await prefs.setInt('decimalFormat', newSettings.decimalFormat);
    await prefs.setInt('firstDayOfWeek', newSettings.firstDayOfWeek);
    await prefs.setBool('notificationsEnabled', newSettings.notificationsEnabled);

    state = AsyncData(newSettings);
  }
  
  Future<void> updateThemeMode(ThemeMode mode) async {
    final current = state.value ?? const SettingsEntity();
    await updateSettings(current.copyWith(themeMode: mode));
  }

  Future<void> updateCurrency(String currency) async {
    final current = state.value ?? const SettingsEntity();
    await updateSettings(current.copyWith(currency: currency));
  }

  Future<void> updateLanguage(String language) async {
    final current = state.value ?? const SettingsEntity();
    await updateSettings(current.copyWith(language: language));
  }

  Future<void> updateDecimalFormat(int format) async {
    final current = state.value ?? const SettingsEntity();
    await updateSettings(current.copyWith(decimalFormat: format));
  }

  Future<void> updateFirstDayOfWeek(int day) async {
    final current = state.value ?? const SettingsEntity();
    await updateSettings(current.copyWith(firstDayOfWeek: day));
  }

  Future<void> updateNotifications(bool enabled) async {
    final current = state.value ?? const SettingsEntity();
    await updateSettings(current.copyWith(notificationsEnabled: enabled));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, SettingsEntity>(() {
  return SettingsNotifier();
});
