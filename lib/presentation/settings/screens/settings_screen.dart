import 'dart:io';
import 'package:flutter/material.dart';
import 'package:moneytrackerapp/core/theme/design_system.dart';
import 'package:moneytrackerapp/core/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:go_router/go_router.dart';
import 'package:moneytrackerapp/core/providers/global_providers.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';
import 'package:moneytrackerapp/presentation/accounts/providers/account_provider.dart';
import 'package:moneytrackerapp/presentation/budgets/providers/budgets_provider.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';

import 'package:moneytrackerapp/l10n/app_localizations.dart';
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _refreshAll(WidgetRef ref) {
    ref.invalidate(transactionsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(accountsProvider);
    ref.invalidate(budgetsProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsTitle, style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: settingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionHeader(context, 'Preferences'),
              Card(
                elevation: 2,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.attach_money,
                      iconColor: colorScheme.primary,
                      title: AppLocalizations.of(context)!.currency,
                      subtitle: settings.currency,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final newCurrency = await _showOptionsDialog(
                          context, 
                          AppLocalizations.of(context)!.selectCurrency, 
                          ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'AUD', 'CAD']
                        );
                        if (newCurrency != null) {
                          ref.read(settingsProvider.notifier).updateCurrency(newCurrency);
                        }
                      },
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.brightness_6,
                      iconColor: colorScheme.secondary,
                      title: AppLocalizations.of(context)!.theme,
                      subtitle: AppThemeManager.getTheme(settings.themeId).name,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/theme-settings'),
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.language,
                      iconColor: colorScheme.primary,
                      title: AppLocalizations.of(context)!.language,
                      subtitle: {'en': AppLocalizations.of(context)!.english, 'es': AppLocalizations.of(context)!.spanish, 'fr': AppLocalizations.of(context)!.french, 'km': AppLocalizations.of(context)!.khmer}[settings.language] ?? settings.language,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        final langMap = {'en': AppLocalizations.of(context)!.english, 'es': AppLocalizations.of(context)!.spanish, 'fr': AppLocalizations.of(context)!.french, 'km': AppLocalizations.of(context)!.khmer};
                        final newLangName = await _showOptionsDialog(
                          context, 
                          AppLocalizations.of(context)!.selectLanguage, 
                          langMap.values.toList()
                        );
                        if (newLangName != null) {
                          final newLang = langMap.entries.firstWhere((e) => e.value == newLangName).key;
                          ref.read(settingsProvider.notifier).updateLanguage(newLang);
                        }
                      },
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.numbers,
                      iconColor: colorScheme.secondary,
                      title: AppLocalizations.of(context)!.decimalFormat,
                      subtitle: settings.decimalFormat == 2 ? AppLocalizations.of(context)!.twoDecimals : AppLocalizations.of(context)!.zeroDecimals,
                      trailing: Switch(
                        value: settings.decimalFormat == 2,
                        activeColor: colorScheme.primary,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).updateDecimalFormat(value ? 2 : 0);
                        },
                      ),
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.calendar_today,
                      iconColor: colorScheme.primary,
                      title: AppLocalizations.of(context)!.firstDayOfWeek,
                      subtitle: settings.firstDayOfWeek == 1 ? AppLocalizations.of(context)!.monday : AppLocalizations.of(context)!.sunday,
                      trailing: Switch(
                        value: settings.firstDayOfWeek == 1,
                        activeColor: colorScheme.primary,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).updateFirstDayOfWeek(value ? 1 : 7);
                        },
                      ),
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.notifications,
                      iconColor: colorScheme.secondary,
                      title: AppLocalizations.of(context)!.notifications,
                      trailing: Switch(
                        value: settings.notificationsEnabled,
                        activeColor: colorScheme.primary,
                        onChanged: (value) {
                          ref.read(settingsProvider.notifier).updateNotifications(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              _buildSectionHeader(context, 'Data Management'),
              
              Card(
                elevation: 2,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  children: [
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.upload_file,
                      iconColor: colorScheme.primary,
                      title: AppLocalizations.of(context)!.exportDatabase,
                      subtitle: AppLocalizations.of(context)!.backupYourDataSafely,
                      onTap: () async {
                        final service = ref.read(dataManagementServiceProvider);
                        final dbPath = await service.getDatabasePath();
                        final dbFile = File(dbPath);

                        if (!await dbFile.exists()) {
                          if (context.mounted) _showSnackBar(context, 'No database found to export.');
                          return;
                        }

                        String? selectedDirectory = await FilePicker.getDirectoryPath();
                        
                        if (selectedDirectory != null) {
                          try {
                            final destPath = p.join(selectedDirectory, 'mintly_backup_${DateTime.now().millisecondsSinceEpoch}.db');
                            await dbFile.copy(destPath);
                            if (context.mounted) _showSnackBar(context, AppLocalizations.of(context)!.exportSuccess(destPath));
                          } catch (e) {
                            if (context.mounted) _showSnackBar(context, AppLocalizations.of(context)!.exportFailed(e.toString()));
                          }
                        }
                      },
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.download,
                      iconColor: colorScheme.secondary,
                      title: AppLocalizations.of(context)!.restoreDatabase,
                      subtitle: AppLocalizations.of(context)!.replaceDataFromBackup,
                      onTap: () async {
                        FilePickerResult? result = await FilePicker.pickFiles(
                          type: FileType.custom,
                          allowedExtensions: ['db'],
                        );

                        if (result != null && result.files.single.path != null) {
                          final confirm = await _showConfirmDialog(
                            context, 
                            AppLocalizations.of(context)!.restoreDbPrompt, 
                            AppLocalizations.of(context)!.overwriteBackupWarning
                          );

                          if (confirm == true) {
                            try {
                              final backupPath = result.files.single.path!;
                              final service = ref.read(dataManagementServiceProvider);
                              
                              await service.resetApp();
                              
                              final targetDbPath = await service.getDatabasePath();
                              await File(backupPath).copy(targetDbPath);
                              
                              _refreshAll(ref);
                              
                              if (context.mounted) _showSnackBar(context, AppLocalizations.of(context)!.dbRestoredSuccess);
                            } catch (e) {
                              if (context.mounted) _showSnackBar(context, AppLocalizations.of(context)!.restoreFailed(e.toString()));
                            }
                          }
                        }
                      },
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.delete_sweep,
                      iconColor: colorScheme.error,
                      title: AppLocalizations.of(context)!.deleteAllData,
                      subtitle: AppLocalizations.of(context)!.removesTransactionsAndBudgets,
                      onTap: () async {
                        final confirm = await _showConfirmDialog(
                          context, 
                          AppLocalizations.of(context)!.deleteAllDataPrompt, 
                          AppLocalizations.of(context)!.deleteTransactionsBudgetsWarning
                        );
                        if (confirm == true) {
                          final service = ref.read(dataManagementServiceProvider);
                          await service.deleteAllData();
                          _refreshAll(ref);
                          if (context.mounted) _showSnackBar(context, AppLocalizations.of(context)!.allDataDeleted);
                        }
                      },
                    ),
                    _buildDivider(context),
                    _buildSettingsTile(
                      context: context,
                      icon: Icons.warning,
                      iconColor: colorScheme.error,
                      title: AppLocalizations.of(context)!.resetApp,
                      subtitle: AppLocalizations.of(context)!.deletesAllData,
                      titleColor: colorScheme.error,
                      onTap: () async {
                        final confirm = await _showConfirmDialog(
                          context, 
                          AppLocalizations.of(context)!.resetAppPrompt, 
                          AppLocalizations.of(context)!.wipeDataWarning
                        );
                        if (confirm == true) {
                          final service = ref.read(dataManagementServiceProvider);
                          await service.resetApp();
                          _refreshAll(ref);
                          if (context.mounted) _showSnackBar(context, AppLocalizations.of(context)!.appResetSuccess);
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0, top: 16.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          letterSpacing: 1.2,
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      indent: 64,
      color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title, 
        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor ?? colorScheme.onSurface)
      ),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: colorScheme.onSurfaceVariant)) : null,
      trailing: trailing,
      onTap: onTap,
    );
  }

  Future<String?> _showOptionsDialog(BuildContext context, String title, List<String> options) {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          contentPadding: const EdgeInsets.only(top: 16, bottom: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: options.map((option) {
              return ListTile(
                title: Text(option),
                onTap: () => Navigator.pop(context, option),
                hoverColor: colorScheme.primary.withValues(alpha: 0.1),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(AppLocalizations.of(context)!.confirm),
            ),
          ],
        );
      },
    );
  }
  
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      )
    );
  }
}
