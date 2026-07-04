import 'package:flutter/material.dart';

class SettingsEntity {
  final String currency;
  final ThemeMode themeMode;
  final String themeId;
  final String language;
  final int decimalFormat; // 0 or 2
  final int firstDayOfWeek; // 1 for Monday, 7 for Sunday (matching DateTime.monday)
  final bool notificationsEnabled;

  const SettingsEntity({
    this.currency = 'USD',
    this.themeMode = ThemeMode.system,
    this.themeId = 'mintly_default',
    this.language = 'en',
    this.decimalFormat = 2,
    this.firstDayOfWeek = 1,
    this.notificationsEnabled = true,
  });

  SettingsEntity copyWith({
    String? currency,
    ThemeMode? themeMode,
    String? themeId,
    String? language,
    int? decimalFormat,
    int? firstDayOfWeek,
    bool? notificationsEnabled,
  }) {
    return SettingsEntity(
      currency: currency ?? this.currency,
      themeMode: themeMode ?? this.themeMode,
      themeId: themeId ?? this.themeId,
      language: language ?? this.language,
      decimalFormat: decimalFormat ?? this.decimalFormat,
      firstDayOfWeek: firstDayOfWeek ?? this.firstDayOfWeek,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }
}
