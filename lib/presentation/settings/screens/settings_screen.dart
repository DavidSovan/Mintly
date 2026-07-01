import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:moneytrackerapp/core/providers/global_providers.dart';
import 'package:moneytrackerapp/presentation/dashboard/providers/dashboard_provider.dart';
import 'package:moneytrackerapp/presentation/categories/providers/category_provider.dart';
import 'package:moneytrackerapp/presentation/accounts/providers/account_provider.dart';
import 'package:moneytrackerapp/presentation/budgets/providers/budgets_provider.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';

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
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: settingsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (settings) {
          return ListView(
            children: [
              _buildSectionHeader(context, 'Preferences'),
              ListTile(
                leading: const Icon(Icons.attach_money),
                title: const Text('Currency'),
                subtitle: Text(settings.currency),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final newCurrency = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Select Currency'),
                      children: ['USD', 'EUR', 'GBP', 'JPY', 'INR', 'AUD', 'CAD']
                          .map((c) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, c),
                                child: Text(c),
                              ))
                          .toList(),
                    ),
                  );
                  if (newCurrency != null) {
                    ref.read(settingsProvider.notifier).updateCurrency(newCurrency);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('Theme'),
                subtitle: Text(settings.themeMode.name.toUpperCase()),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final newTheme = await showDialog<ThemeMode>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Select Theme'),
                      children: ThemeMode.values
                          .map((m) => SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, m),
                                child: Text(m.name.toUpperCase()),
                              ))
                          .toList(),
                    ),
                  );
                  if (newTheme != null) {
                    ref.read(settingsProvider.notifier).updateThemeMode(newTheme);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Language'),
                subtitle: Text(settings.language == 'en' ? 'English' : settings.language),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final newLang = await showDialog<String>(
                    context: context,
                    builder: (context) => SimpleDialog(
                      title: const Text('Select Language'),
                      children: [
                        SimpleDialogOption(onPressed: () => Navigator.pop(context, 'en'), child: const Text('English')),
                        SimpleDialogOption(onPressed: () => Navigator.pop(context, 'es'), child: const Text('Spanish')),
                        SimpleDialogOption(onPressed: () => Navigator.pop(context, 'fr'), child: const Text('French')),
                      ],
                    ),
                  );
                  if (newLang != null) {
                    ref.read(settingsProvider.notifier).updateLanguage(newLang);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.numbers),
                title: const Text('Decimal Format'),
                subtitle: Text(settings.decimalFormat == 2 ? '2 Decimals (e.g. 10.00)' : '0 Decimals (e.g. 10)'),
                trailing: Switch(
                  value: settings.decimalFormat == 2,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateDecimalFormat(value ? 2 : 0);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('First day of week'),
                subtitle: Text(settings.firstDayOfWeek == 1 ? 'Monday' : 'Sunday'),
                trailing: Switch(
                  value: settings.firstDayOfWeek == 1,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateFirstDayOfWeek(value ? 1 : 7);
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notifications'),
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateNotifications(value);
                  },
                ),
              ),
              
              const Divider(height: 32),
              _buildSectionHeader(context, 'Data Management'),
              
              ListTile(
                leading: const Icon(Icons.delete_sweep, color: Colors.orange),
                title: const Text('Delete all data'),
                subtitle: const Text('Removes all transactions and budgets.'),
                onTap: () async {
                  final confirm = await _showConfirmDialog(
                    context, 
                    'Delete All Data?', 
                    'This will permanently delete all transactions and budgets. Categories and accounts will remain intact.'
                  );
                  if (confirm == true) {
                    final service = ref.read(dataManagementServiceProvider);
                    await service.deleteAllData();
                    _refreshAll(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All data deleted successfully.')));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Reset App'),
                subtitle: const Text('Deletes all data and restores defaults.'),
                onTap: () async {
                  final confirm = await _showConfirmDialog(
                    context, 
                    'Reset Application?', 
                    'This will completely wipe all data and restore the application to its original state. This cannot be undone.'
                  );
                  if (confirm == true) {
                    final service = ref.read(dataManagementServiceProvider);
                    await service.resetApp();
                    _refreshAll(ref);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Application reset successfully.')));
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.upload_file),
                title: const Text('Export Database'),
                subtitle: const Text('Backup your database to a safe location.'),
                onTap: () async {
                  final service = ref.read(dataManagementServiceProvider);
                  final dbPath = await service.getDatabasePath();
                  final dbFile = File(dbPath);

                  if (!await dbFile.exists()) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No database found to export.')));
                    }
                    return;
                  }

                  String? selectedDirectory = await FilePicker.getDirectoryPath();
                  
                  if (selectedDirectory != null) {
                    try {
                      final destPath = p.join(selectedDirectory, 'money_tracker_backup_${DateTime.now().millisecondsSinceEpoch}.db');
                      await dbFile.copy(destPath);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Database exported to: $destPath')));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Export failed: $e')));
                      }
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Restore Database'),
                subtitle: const Text('Replace the current data with a previous backup.'),
                onTap: () async {
                  FilePickerResult? result = await FilePicker.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['db'],
                  );

                  if (result != null && result.files.single.path != null) {
                    final confirm = await _showConfirmDialog(
                      context, 
                      'Restore Database?', 
                      'This will overwrite your current data with the selected backup. This action cannot be undone.'
                    );

                    if (confirm == true) {
                      try {
                        final backupPath = result.files.single.path!;
                        final service = ref.read(dataManagementServiceProvider);
                        
                        await service.resetApp();
                        
                        final targetDbPath = await service.getDatabasePath();
                        await File(backupPath).copy(targetDbPath);
                        
                        _refreshAll(ref);
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Database restored successfully.')));
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Restore failed: $e')));
                        }
                      }
                    }
                  }
                },
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, String title, String content) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
