import json
import os
import re

new_strings = {
  "0 Decimals (e.g. 10)": ["zeroDecimals", "0 Decimals (e.g. 10)", "0 Decimales (ej. 10)", "0 Décimale (ex. 10)", "0 ទសភាគ (ឧ. 10)"],
  "2 Decimals (e.g. 10.00)": ["twoDecimals", "2 Decimals (e.g. 10.00)", "2 Decimales (ej. 10.00)", "2 Décimales (ex. 10.00)", "2 ទសភាគ (ឧ. 10.00)"],
  "All data deleted successfully.": ["allDataDeleted", "All data deleted successfully.", "Todos los datos eliminados con éxito.", "Toutes les données ont été supprimées avec succès.", "ទិន្នន័យទាំងអស់ត្រូវបានលុបដោយជោគជ័យ។"],
  "Application reset successfully.": ["appResetSuccess", "Application reset successfully.", "Aplicación restablecida con éxito.", "L'application a été réinitialisée avec succès.", "កម្មវិធីត្រូវបានកំណត់ឡើងវិញដោយជោគជ័យ។"],
  "Bank": ["bank", "Bank", "Banco", "Banque", "ធនាគារ"],
  "Bills": ["bills", "Bills", "Facturas", "Factures", "វិក្កយបត្រ"],
  "Bonus": ["bonus", "Bonus", "Bono", "Prime", "ប្រាក់រង្វាន់"],
  "Create Account": ["createAccount", "Create Account", "Crear Cuenta", "Créer un compte", "បង្កើតគណនី"],
  "Create Budget": ["createBudget", "Create Budget", "Crear Presupuesto", "Créer un budget", "បង្កើតថវិកា"],
  "Create Category": ["createCategory", "Create Category", "Crear Categoría", "Créer une catégorie", "បង្កើតប្រភេទ"],
  "Create Goal": ["createGoal", "Create Goal", "Crear Meta", "Créer un objectif", "បង្កើតគោលដៅ"],
  "Credit Card": ["creditCard", "Credit Card", "Tarjeta de Crédito", "Carte de crédit", "កាតឥណទាន"],
  "Data Management": ["dataManagement", "Data Management", "Gestión de Datos", "Gestion des données", "ការគ្រប់គ្រងទិន្នន័យ"],
  "Database restored successfully.": ["dbRestoredSuccess", "Database restored successfully.", "Base de datos restaurada con éxito.", "Base de données restaurée avec succès.", "មូលដ្ឋានទិន្នន័យត្រូវបានស្តារដោយជោគជ័យ។"],
  "Day": ["day", "Day", "Día", "Jour", "ថ្ងៃ"],
  "Deficit": ["deficit", "Deficit", "Déficit", "Déficit", "ឱនភាព"],
  "Delete All Data?": ["deleteAllDataPrompt", "Delete All Data?", "¿Eliminar Todos los Datos?", "Supprimer toutes les données?", "លុបទិន្នន័យទាំងអស់?"],
  "E-Wallet": ["eWallet", "E-Wallet", "Billetera Electrónica", "Portefeuille électronique", "កាបូបអេឡិចត្រូនិច"],
  "Edit Account": ["editAccount", "Edit Account", "Editar Cuenta", "Modifier le compte", "កែសម្រួលគណនី"],
  "Edit Budget": ["editBudget", "Edit Budget", "Editar Presupuesto", "Modifier le budget", "កែសម្រួលថវិកា"],
  "Edit Category": ["editCategory", "Edit Category", "Editar Categoría", "Modifier la catégorie", "កែសម្រួលប្រភេទ"],
  "Edit Goal": ["editGoal", "Edit Goal", "Editar Meta", "Modifier l'objectif", "កែសម្រួលគោលដៅ"],
  "Edit Transaction": ["editTransaction", "Edit Transaction", "Editar Transacción", "Modifier la transaction", "កែសម្រួលប្រតិបត្តិការ"],
  "Education": ["education", "Education", "Educación", "Éducation", "ការអប់រំ"],
  "Enter a valid number": ["enterValidNumber", "Enter a valid number", "Ingrese un número válido", "Entrez un nombre valide", "បញ្ចូលលេខត្រឹមត្រូវ"],
  "Enter amount": ["enterAmount", "Enter amount", "Ingrese el monto", "Entrez le montant", "បញ្ចូលចំនួនប្រាក់"],
  "Entertainment": ["entertainment", "Entertainment", "Entretenimiento", "Divertissement", "ការកម្សាន្ត"],
  "Food": ["food", "Food", "Comida", "Nourriture", "អាហារ"],
  "Freelance": ["freelance", "Freelance", "Trabajo Independiente", "Indépendant", "ការងារឯករាជ្យ"],
  "Gift": ["gift", "Gift", "Regalo", "Cadeau", "អំណោយ"],
  "Goal Contribution": ["goalContribution", "Goal Contribution", "Contribución a Meta", "Contribution à l'objectif", "ការចូលរួមគោលដៅ"],
  "Goals": ["goalsTitle", "Goals", "Metas", "Objectifs", "គោលដៅ"],
  "Health": ["health", "Health", "Salud", "Santé", "សុខភាព"],
  "Invalid amount": ["invalidAmount", "Invalid amount", "Monto inválido", "Montant invalide", "ចំនួនមិនត្រឹមត្រូវ"],
  "Invalid number": ["invalidNumber", "Invalid number", "Número inválido", "Nombre invalide", "លេខមិនត្រឹមត្រូវ"],
  "Investment": ["investment", "Investment", "Inversión", "Investissement", "ការវិនិយោគ"],
  "Month": ["month", "Month", "Mes", "Mois", "ខែ"],
  "New Account": ["newAccount", "New Account", "Nueva Cuenta", "Nouveau compte", "គណនីថ្មី"],
  "New Budget": ["newBudget", "New Budget", "Nuevo Presupuesto", "Nouveau budget", "ថវិកាថ្មី"],
  "New Category": ["newCategory", "New Category", "Nueva Categoría", "Nouvelle catégorie", "ប្រភេទថ្មី"],
  "New Goal": ["newGoal", "New Goal", "Nueva Meta", "Nouvel objectif", "គោលដៅថ្មី"],
  "No database found to export.": ["noDbFoundExport", "No database found to export.", "No se encontró base de datos para exportar.", "Aucune base de données trouvée à exporter.", "រកមិនឃើញមូលដ្ឋានទិន្នន័យដើម្បីនាំចេញទេ។"],
  "Overall": ["overall", "Overall", "General", "Global", "សរុប"],
  "Please enter a goal name": ["enterGoalName", "Please enter a goal name", "Por favor ingrese un nombre para la meta", "Veuillez entrer un nom d'objectif", "សូមបញ្ចូលឈ្មោះគោលដៅ"],
  "Please enter a name": ["enterName", "Please enter a name", "Por favor ingrese un nombre", "Veuillez entrer un nom", "សូមបញ្ចូលឈ្មោះ"],
  "Please enter a valid number": ["enterValidNumberPlease", "Please enter a valid number", "Por favor ingrese un número válido", "Veuillez entrer un nombre valide", "សូមបញ្ចូលលេខត្រឹមត្រូវ"],
  "Please enter amount": ["enterAmountPlease", "Please enter amount", "Por favor ingrese el monto", "Veuillez entrer le montant", "សូមបញ្ចូលចំនួនប្រាក់"],
  "Please enter initial balance": ["enterInitialBalance", "Please enter initial balance", "Por favor ingrese el saldo inicial", "Veuillez entrer le solde initial", "សូមបញ្ចូលសមតុល្យដំបូង"],
  "Please enter target amount": ["enterTargetAmount", "Please enter target amount", "Por favor ingrese el monto objetivo", "Veuillez entrer le montant cible", "សូមបញ្ចូលចំនួនគោលដៅ"],
  "Please select an account": ["selectAccountPlease", "Please select an account", "Por favor seleccione una cuenta", "Veuillez sélectionner un compte", "សូមជ្រើសរើសគណនី"],
  "Preferences": ["preferences", "Preferences", "Preferencias", "Préférences", "ចំណូលចិត្ត"],
  "Reset Application?": ["resetAppPrompt", "Reset Application?", "¿Restablecer Aplicación?", "Réinitialiser l'application?", "កំណត់កម្មវិធីឡើងវិញ?"],
  "Restore Database?": ["restoreDbPrompt", "Restore Database?", "¿Restaurar Base de Datos?", "Restaurer la base de données?", "ស្តារមូលដ្ឋានទិន្នន័យ?"],
  "Salary": ["salary", "Salary", "Salario", "Salaire", "ប្រាក់ខែ"],
  "Save Changes": ["saveChanges", "Save Changes", "Guardar Cambios", "Enregistrer les modifications", "រក្សាទុកការផ្លាស់ប្តូរ"],
  "Save Transaction": ["saveTransaction", "Save Transaction", "Guardar Transacción", "Enregistrer la transaction", "រក្សាទុកប្រតិបត្តិការ"],
  "Savings": ["savings", "Savings", "Ahorros", "Épargne", "ការសន្សំ"],
  "Select Currency": ["selectCurrency", "Select Currency", "Seleccionar Moneda", "Sélectionner la devise", "ជ្រើសរើសរូបិយប័ណ្ណ"],
  "Select Language": ["selectLanguage", "Select Language", "Seleccionar Idioma", "Sélectionner la langue", "ជ្រើសរើសភាសា"],
  "Shopping": ["shopping", "Shopping", "Compras", "Achats", "ការទិញទំនិញ"],
  "Surplus": ["surplus", "Surplus", "Excedente", "Surplus", "អតិរេក"],
  "This Month": ["thisMonthPeriod", "This Month", "Este Mes", "Ce mois-ci", "ខែនេះ"],
  "This will completely wipe all data and restore the application to its original state. This cannot be undone.": ["wipeDataWarning", "This will completely wipe all data and restore the application to its original state. This cannot be undone.", "Esto borrará todos los datos y restaurará la aplicación a su estado original. Esto no se puede deshacer.", "Cela effacera toutes les données et restaurera l'application à son état d'origine. Cette action est irréversible.", "វានឹងលុបទិន្នន័យទាំងអស់ទាំងស្រុង ហើយស្តារកម្មវិធីទៅស្ថានភាពដើមរបស់វាវិញ។ សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។"],
  "This will overwrite your current data with the selected backup. This action cannot be undone.": ["overwriteBackupWarning", "This will overwrite your current data with the selected backup. This action cannot be undone.", "Esto sobrescribirá sus datos actuales con la copia de seguridad seleccionada. Esto no se puede deshacer.", "Cela écrasera vos données actuelles avec la sauvegarde sélectionnée. Cette action est irréversible.", "វានឹងជំនួសទិន្នន័យបច្ចុប្បន្នរបស់អ្នកជាមួយនឹងការបម្រុងទុកដែលបានជ្រើសរើស។ សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។"],
  "This will permanently delete all transactions and budgets. Categories and accounts will remain intact.": ["deleteTransactionsBudgetsWarning", "This will permanently delete all transactions and budgets. Categories and accounts will remain intact.", "Esto eliminará permanentemente todas las transacciones y presupuestos. Las categorías y cuentas permanecerán intactas.", "Cela supprimera définitivement toutes les transactions et tous les budgets. Les catégories et les comptes resteront intacts.", "វានឹងលុបប្រតិបត្តិការ និងថវិកាទាំងអស់ជាអចិន្ត្រៃយ៍។ ប្រភេទ និងគណនីនឹងនៅដដែល។"],
  "Transport": ["transport", "Transport", "Transporte", "Transport", "ការដឹកជញ្ជូន"],
  "Unknown": ["unknown", "Unknown", "Desconocido", "Inconnu", "មិនស្គាល់"],
  "Update Transaction": ["updateTransaction", "Update Transaction", "Actualizar Transacción", "Mettre à jour la transaction", "ធ្វើបច្ចុប្បន្នភាពប្រតិបត្តិការ"],
  "Week": ["week", "Week", "Semana", "Semaine", "សប្តាហ៍"],
  "Year": ["year", "Year", "Año", "Année", "ឆ្នាំ"],
  "Yesterday": ["yesterday", "Yesterday", "Ayer", "Hier", "ម្សិលមិញ"],
  "You didn\\'t spend anything this week.": ["youDidntSpendThisWeek", "You didn\\'t spend anything this week.", "No gastaste nada esta semana.", "Vous n\\'avez rien dépensé cette semaine.", "អ្នកមិនបានចំណាយអ្វីទេនៅសប្តាហ៍នេះ។"],
  "Add Transaction": ["addTransaction", "Add Transaction", "Añadir Transacción", "Ajouter une transaction", "បន្ថែមប្រតិបត្តិការ"],
  "Monday": ["monday", "Monday", "Lunes", "Lundi", "ច័ន្ទ"],
  "Sunday": ["sunday", "Sunday", "Domingo", "Dimanche", "អាទិត្យ"]
}

def update_arb(file_path, index):
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    for en_key, items in new_strings.items():
        key = items[0]
        val = items[index]
        data[key] = val.replace("\\'", "'")
        
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
update_arb('lib/l10n/app_en.arb', 1)
update_arb('lib/l10n/app_es.arb', 2)
update_arb('lib/l10n/app_fr.arb', 3)
update_arb('lib/l10n/app_km.arb', 4)

import_statement = "import 'package:moneytrackerapp/l10n/app_localizations.dart';"

def escape_regex(s):
    return re.escape(s)

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    modified = False

    for en_key, items in new_strings.items():
        key = items[0]
        escaped_en = escape_regex(en_key).replace("\\'", "['\"]").replace("'", "['\"]")
        
        # Regex to catch Text('...'), label: '...', etc.
        pattern = r"(Text\(\s*|title:\s*|label:\s*|hintText:\s*|labelText:\s*|tooltip:\s*|message:\s*|subtitle:\s*|text:\s*|name:\s*)['\"]" + escaped_en + r"['\"]"
        repl = r"\1AppLocalizations.of(context)!." + key
        content, n = re.subn(pattern, repl, content)
        if n > 0: modified = True
        
        # for dialogs or snackbars without context easy replacement
        # e.g., showSnackBar(SnackBar(content: Text('...')))
        pattern2 = r"content:\s*Text\(['\"]" + escaped_en + r"['\"]\)"
        repl2 = r"content: Text(AppLocalizations.of(context)!." + key + r")"
        content, n = re.subn(pattern2, repl2, content)
        if n > 0: modified = True
        
        # raw strings in settings
        # {'en': 'English'} -> {'en': AppLocalizations.of(context)!.english}
        # wait I didn't add English to this list but I can manually fix settings_screen
        
    # specific fix for "You didn't spend anything this week." since it has apostrophe
    pattern3 = r"Text\(['\"]You didn\\'t spend anything this week\.['\"]\)"
    repl3 = r"Text(AppLocalizations.of(context)!.youDidntSpendThisWeek)"
    content, n = re.subn(pattern3, repl3, content)
    if n > 0: modified = True

    if modified:
        if import_statement not in content:
            imports_end = 0
            for m in re.finditer(r"^import\s+['\"].*?['\"];\s*", content, re.MULTILINE):
                imports_end = m.end()
            if imports_end > 0:
                content = content[:imports_end] + import_statement + "\n" + content[imports_end:]
            else:
                content = import_statement + "\n\n" + content
                
        with open(filepath, 'w') as f:
            f.write(content)

for root, dirs, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

# Fix default categories in domain/entities (they might not have context, so we just leave them alone, they will be translated later if they are seeded, wait... seeded data is in sqlite, so it's fine)
