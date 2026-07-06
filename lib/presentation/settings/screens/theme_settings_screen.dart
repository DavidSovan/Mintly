import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneytrackerapp/core/theme/app_theme.dart';
import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';

import 'package:moneytrackerapp/l10n/app_localizations.dart';
class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.themeSettings),
      ),
      body: settingsAsync.when(
        data: (settings) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                AppLocalizations.of(context)!.appearance,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              _buildAppearanceSelector(context, ref, settings.themeMode),
              SizedBox(height: 32),
              Text(
                AppLocalizations.of(context)!.colorTheme,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: 16),
              _buildThemeGrid(context, ref, settings.themeId),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading settings: $e')),
      ),
    );
  }

  Widget _buildAppearanceSelector(BuildContext context, WidgetRef ref, ThemeMode currentMode) {
    return SegmentedButton<ThemeMode>(
      segments: [
        ButtonSegment(
          value: ThemeMode.system,
          icon: Icon(Icons.brightness_auto),
          label: Text(AppLocalizations.of(context)!.system),
        ),
        ButtonSegment(
          value: ThemeMode.light,
          icon: Icon(Icons.light_mode),
          label: Text(AppLocalizations.of(context)!.light),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          icon: Icon(Icons.dark_mode),
          label: Text(AppLocalizations.of(context)!.dark),
        ),
      ],
      selected: {currentMode},
      onSelectionChanged: (Set<ThemeMode> newSelection) {
        ref.read(settingsProvider.notifier).updateThemeMode(newSelection.first);
      },
      style: ButtonStyle(
        padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 16)),
      ),
    );
  }

  Widget _buildThemeGrid(BuildContext context, WidgetRef ref, String currentThemeId) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: AppThemeManager.themes.length,
      itemBuilder: (context, index) {
        final appTheme = AppThemeManager.themes[index];
        final isSelected = appTheme.id == currentThemeId;

        return _ThemePreviewCard(
          appTheme: appTheme,
          isSelected: isSelected,
          onTap: () {
            ref.read(settingsProvider.notifier).updateThemeId(appTheme.id);
          },
        );
      },
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final AppThemeData appTheme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.appTheme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    final previewThemeData = brightness == Brightness.dark ? appTheme.darkTheme : appTheme.lightTheme;
    final colorScheme = previewThemeData.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: previewThemeData.cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected ? colorScheme.primary.withOpacity(0.3) : Colors.black.withOpacity(0.05),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17), // 20 - 3 (border)
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  color: previewThemeData.scaffoldBackgroundColor,
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Fake App Bar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.menu, size: 14, color: colorScheme.onSurface),
                          Text(AppLocalizations.of(context)!.app, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
                          Icon(Icons.person, size: 14, color: colorScheme.onSurface),
                        ],
                      ),
                      const Spacer(),
                      // Fake Card
                      Container(
                        height: 30,
                        decoration: BoxDecoration(
                          color: previewThemeData.cardTheme.color,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      // Fake FAB
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, size: 16, color: colorScheme.onSecondary),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  color: previewThemeData.cardTheme.color,
                  alignment: Alignment.center,
                  child: Text(
                    appTheme.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: previewThemeData.textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
