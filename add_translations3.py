import json
import os
import re

new_strings = {
  "exportSuccess": ["Database exported to: {path}", "Base de datos exportada a: {path}", "Base de données exportée vers: {path}", "មូលដ្ឋានទិន្នន័យនាំចេញទៅកាន់៖ {path}"],
  "exportFailed": ["Export failed: {error}", "Exportación fallida: {error}", "Échec de l'exportation: {error}", "ការនាំចេញបរាជ័យ៖ {error}"],
  "restoreFailed": ["Restore failed: {error}", "Restauración fallida: {error}", "Échec de la restauration: {error}", "ការស្តារបរាជ័យ៖ {error}"],
  "errorLoadingAccounts": ["Error loading accounts: {error}", "Error cargando cuentas: {error}", "Erreur de chargement des comptes: {error}", "មានបញ្ហាក្នុងការទាញយកគណនី៖ {error}"],
  "errorLoadingCategories": ["Error loading categories: {error}", "Error cargando categorías: {error}", "Erreur de chargement des catégories: {error}", "មានបញ្ហាក្នុងការទាញយកប្រភេទ៖ {error}"],
  "errorLoadingSettings": ["Error loading settings: {error}", "Error cargando configuraciones: {error}", "Erreur de chargement des paramètres: {error}", "មានបញ្ហាក្នុងការទាញយកការកំណត់៖ {error}"],
  "errorMsg": ["Error: {error}", "Error: {error}", "Erreur: {error}", "មានបញ្ហា៖ {error}"]
}

def update_arb(file_path, index):
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    for key, items in new_strings.items():
        val = items[index]
        data[key] = val
        if '{path}' in val:
            data['@'+key] = {'placeholders': {'path': {'type': 'String'}}}
        if '{error}' in val:
            data['@'+key] = {'placeholders': {'error': {'type': 'String'}}}
        
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
update_arb('lib/l10n/app_en.arb', 0)
update_arb('lib/l10n/app_es.arb', 1)
update_arb('lib/l10n/app_fr.arb', 2)
update_arb('lib/l10n/app_km.arb', 3)

def fix_settings_screen():
    filepath = 'lib/presentation/settings/screens/settings_screen.dart'
    with open(filepath, 'r') as f:
        content = f.read()

    replacements = {
        "'Database exported to: $destPath'": "AppLocalizations.of(context)!.exportSuccess(destPath)",
        "'Export failed: $e'": "AppLocalizations.of(context)!.exportFailed(e.toString())",
        "'Restore Database?'": "AppLocalizations.of(context)!.restoreDbPrompt",
        "'This will overwrite your current data with the selected backup. This action cannot be undone.'": "AppLocalizations.of(context)!.overwriteBackupWarning",
        "'Database restored successfully.'": "AppLocalizations.of(context)!.dbRestoredSuccess",
        "'Restore failed: $e'": "AppLocalizations.of(context)!.restoreFailed(e.toString())",
        "'Delete All Data?'": "AppLocalizations.of(context)!.deleteAllDataPrompt",
        "'This will permanently delete all transactions and budgets. Categories and accounts will remain intact.'": "AppLocalizations.of(context)!.deleteTransactionsBudgetsWarning",
        "'All data deleted successfully.'": "AppLocalizations.of(context)!.allDataDeleted",
        "'Reset Application?'": "AppLocalizations.of(context)!.resetAppPrompt",
        "'This will completely wipe all data and restore the application to its original state. This cannot be undone.'": "AppLocalizations.of(context)!.wipeDataWarning",
        "'Application reset successfully.'": "AppLocalizations.of(context)!.appResetSuccess",
    }
    
    for old, new in replacements.items():
        content = content.replace(old, new)
        
    with open(filepath, 'w') as f:
        f.write(content)

fix_settings_screen()
