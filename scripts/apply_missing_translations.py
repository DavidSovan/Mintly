import json
import os

new_strings = {
  "0.00": ["zeroAmount", "0.00", "0.00", "0.00", "0.00"],
  "Account": ["account", "Account", "Cuenta", "Compte", "គណនី"],
  "Accounts": ["accountsTitle", "Accounts", "Cuentas", "Comptes", "គណនី"],
  "Add": ["add", "Add", "Añadir", "Ajouter", "បន្ថែម"],
  "Add Account": ["addAccountAction", "Add Account", "Añadir Cuenta", "Ajouter un compte", "បន្ថែមគណនី"],
  "Add Budget": ["addBudgetAction", "Add Budget", "Añadir Presupuesto", "Ajouter un budget", "បន្ថែមថវិកា"],
  "Add Category": ["addCategoryAction", "Add Category", "Añadir Categoría", "Ajouter une catégorie", "បន្ថែមប្រភេទ"],
  "Add Funds": ["addFunds", "Add Funds", "Añadir Fondos", "Ajouter des fonds", "បន្ថែមមូលនិធិ"],
  "Add Goal": ["addGoalAction", "Add Goal", "Añadir Meta", "Ajouter un objectif", "បន្ថែមគោលដៅ"],
  "Add a goal to start tracking!": ["addGoalToStart", "Add a goal to start tracking!", "¡Añade una meta para empezar!", "Ajoutez un objectif pour commencer!", "បន្ថែមគោលដៅដើម្បីចាប់ផ្តើមតាមដាន!"],
  "Add your first income or expense!": ["addFirstIncomeExpense", "Add your first income or expense!", "¡Añade tu primer ingreso o gasto!", "Ajoutez votre premier revenu ou dépense!", "បន្ថែមចំណូលឬចំណាយដំបូងរបស់អ្នក!"],
  "App": ["app", "App", "App", "App", "កម្មវិធី"],
  "Appearance": ["appearance", "Appearance", "Apariencia", "Apparence", "រូបរាង"],
  "Approaching Limit!": ["approachingLimit", "Approaching Limit!", "¡Acercándose al límite!", "Limite d'approche!", "ជិតដល់ដែនកំណត់ហើយ!"],
  "Are you sure you want to delete ": ["areYouSureDeletePrefix", "Are you sure you want to delete ", "¿Seguro que quieres eliminar ", "Voulez-vous vraiment supprimer ", "តើអ្នកពិតជាចង់លុប "],
  "Budget": ["budget", "Budget", "Presupuesto", "Budget", "ថវិកា"],
  "Budget Amount": ["budgetAmount", "Budget Amount", "Monto del Presupuesto", "Montant du budget", "ចំនួនថវិកា"],
  "Budget Exceeded!": ["budgetExceeded", "Budget Exceeded!", "¡Presupuesto superado!", "Budget dépassé!", "លើសថវិកាហើយ!"],
  "Budgets": ["budgetsTitle", "Budgets", "Presupuestos", "Budgets", "ថវិកា"],
  "Calendar": ["calendarTitle", "Calendar", "Calendario", "Calendrier", "ប្រតិទិន"],
  "Categories": ["categoriesTitle", "Categories", "Categorías", "Catégories", "ប្រភេទ"],
  "Categories (Select one or more)": ["categoriesSelect", "Categories (Select one or more)", "Categorías (Seleccione una o más)", "Catégories (Sélectionnez une ou plusieurs)", "ប្រភេទ (ជ្រើសរើសមួយឬច្រើន)"],
  "Category": ["category", "Category", "Categoría", "Catégorie", "ប្រភេទ"],
  "Color": ["color", "Color", "Color", "Couleur", "ពណ៌"],
  "Color Theme": ["colorTheme", "Color Theme", "Tema de Color", "Thème de couleur", "ពណ៌ស្បែក"],
  "Current Balance": ["currentBalance", "Current Balance", "Saldo Actual", "Solde actuel", "សមតុល្យបច្ចុប្បន្ន"],
  "Deadline": ["deadline", "Deadline", "Fecha Límite", "Date limite", "ថ្ងៃកំណត់"],
  "Delete": ["deleteBtn", "Delete", "Eliminar", "Supprimer", "លុប"],
  "Delete Budget": ["deleteBudgetAction", "Delete Budget", "Eliminar Presupuesto", "Supprimer le budget", "លុបថវិកា"],
  "Delete Goal": ["deleteGoalAction", "Delete Goal", "Eliminar Meta", "Supprimer l'objectif", "លុបគោលដៅ"],
  "Deletes all data and restores defaults.": ["deletesAllData", "Deletes all data and restores defaults.", "Borra todos los datos y restaura valores.", "Supprime toutes les données et restaure.", "លុបទិន្នន័យទាំងអស់និងស្តារលំនាំដើម។"],
  "Expense": ["expenseType", "Expense", "Gasto", "Dépense", "ចំណាយ"],
  "Expenses": ["expensesTitle", "Expenses", "Gastos", "Dépenses", "ចំណាយ"],
  "Expenses in this budget:": ["expensesInBudget", "Expenses in this budget:", "Gastos en este presupuesto:", "Dépenses dans ce budget:", "ចំណាយក្នុងថវិកានេះ៖"],
  "Goal Name": ["goalName", "Goal Name", "Nombre de la Meta", "Nom de l'objectif", "ឈ្មោះគោលដៅ"],
  "Icon": ["icon", "Icon", "Ícono", "Icône", "រូបតំណាង"],
  "Income": ["incomeType", "Income", "Ingreso", "Revenu", "ចំណូល"],
  "Mintly": ["mintlyTitle", "Mintly", "Mintly", "Mintly", "Mintly"],
  "Monthly": ["monthlyPeriod", "Monthly", "Mensual", "Mensuel", "ប្រចាំខែ"],
  "Net Balance": ["netBalance", "Net Balance", "Saldo Neto", "Solde net", "សមតុល្យសុទ្ធ"],
  "No accounts yet": ["noAccountsYet", "No accounts yet", "Aún no hay cuentas", "Pas encore de comptes", "មិនទាន់មានគណនីទេ"],
  "No budgets configured.": ["noBudgetsConfigured", "No budgets configured.", "No hay presupuestos.", "Aucun budget configuré.", "មិនមានថវិកាទេ"],
  "No categories yet": ["noCategoriesYet", "No categories yet", "Aún no hay categorías", "Pas encore de catégories", "មិនទាន់មានប្រភេទទេ"],
  "No data for this period": ["noDataForPeriod", "No data for this period", "Sin datos para este período", "Pas de données pour cette période", "មិនមានទិន្នន័យសម្រាប់រយៈពេលនេះទេ"],
  "No expenses in this period": ["noExpensesPeriod", "No expenses in this period", "Sin gastos en este período", "Pas de dépenses dans cette période", "គ្មានចំណាយក្នុងរយៈពេលនេះទេ"],
  "No savings goals yet.": ["noSavingsGoals", "No savings goals yet.", "Aún no hay metas de ahorro.", "Pas encore d'objectifs d'épargne.", "មិនទាន់មានគោលដៅសន្សំទេ"],
  "No transactions": ["noTransactions", "No transactions", "Sin transacciones", "Aucune transaction", "គ្មានប្រតិបត្តិការ"],
  "No transactions yet": ["noTransactionsYet", "No transactions yet", "Aún no hay transacciones", "Pas encore de transactions", "មិនទាន់មានប្រតិបត្តិការទេ"],
  "No trend data available": ["noTrendData", "No trend data available", "No hay datos de tendencias", "Pas de données de tendance", "មិនមានទិន្នន័យនិន្នាការទេ"],
  "Overview": ["overview", "Overview", "Resumen", "Aperçu", "ទិដ្ឋភាពទូទៅ"],
  "Period": ["period", "Period", "Período", "Période", "រយៈពេល"],
  "Personal Finance": ["personalFinance", "Personal Finance", "Finanzas Personales", "Finances Personnelles", "ហិរញ្ញវត្ថុផ្ទាល់ខ្លួន"],
  "Recent Transactions": ["recentTransactionsTitle", "Recent Transactions", "Transacciones Recientes", "Transactions récentes", "ប្រតិបត្តិការថ្មីៗ"],
  "Remaining": ["remaining", "Remaining", "Restante", "Restant", "នៅសល់"],
  "Reports": ["reportsTitle", "Reports", "Reportes", "Rapports", "របាយការណ៍"],
  "Savings Goals": ["savingsGoalsTitle", "Savings Goals", "Metas de Ahorro", "Objectifs d'épargne", "គោលដៅសន្សំ"],
  "See All": ["seeAllBtn", "See All", "Ver Todo", "Voir Tout", "មើលទាំងអស់"],
  "Set a budget to manage your spending!": ["setBudgetToManage", "Set a budget to manage your spending!", "¡Establece un presupuesto para tus gastos!", "Définissez un budget pour gérer!", "កំណត់ថវិកាដើម្បីគ្រប់គ្រងការចំណាយ!"],
  "Settings": ["settingsTitle", "Settings", "Ajustes", "Paramètres", "ការកំណត់"],
  "Spending vs Income (Month)": ["spendingVsIncome", "Spending vs Income (Month)", "Gastos vs Ingresos (Mes)", "Dépenses vs Revenus", "ចំណាយ ធៀបនឹង ចំណូល (ខែ)"],
  "Spent": ["spent", "Spent", "Gastado", "Dépensé", "បានចំណាយ"],
  "Tap the + button to create one.": ["tapPlusToCreate", "Tap the + button to create one.", "Toca el botón + para crear una.", "Appuyez sur + pour créer.", "ចុចប៊ូតុង + ដើម្បីបង្កើតមួយ។"],
  "Target Amount": ["targetAmount", "Target Amount", "Monto Objetivo", "Montant cible", "ចំនួនគោលដៅ"],
  "This Week": ["thisWeekPeriod", "This Week", "Esta Semana", "Cette semaine", "សប្តាហ៍នេះ"],
  "Total Balance": ["totalBalance", "Total Balance", "Saldo Total", "Solde total", "សមតុល្យសរុប"],
  "Total Expenses": ["totalExpenses", "Total Expenses", "Gastos Totales", "Dépenses totales", "ចំណាយសរុប"],
  "Transactions": ["transactionsTitle", "Transactions", "Transacciones", "Transactions", "ប្រតិបត្តិការ"],
  "Updated just now": ["updatedJustNow", "Updated just now", "Actualizado ahora", "Mis à jour à l'instant", "បានធ្វើបច្ចុប្បន្នភាពអម្បាញ់មិញ"],
  "Weekly": ["weeklyPeriod", "Weekly", "Semanal", "Hebdomadaire", "ប្រចាំសប្តាហ៍"],
  "You didn\\'t spend anything this week.": ["youDidntSpendAnything", "You didn't spend anything this week.", "No gastaste nada esta semana.", "Vous n'avez rien dépensé cette semaine.", "អ្នកមិនបានចំណាយអ្វីទេនៅសប្តាហ៍នេះ។"]
}

def update_arb(file_path, index):
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    for en_key, items in new_strings.items():
        key = items[0]
        val = items[index]
        data[key] = val
        
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
update_arb('lib/l10n/app_en.arb', 1)
update_arb('lib/l10n/app_es.arb', 2)
update_arb('lib/l10n/app_fr.arb', 3)
update_arb('lib/l10n/app_km.arb', 4)

# Now, update the dart files!
import re

import_statement = "import 'package:moneytrackerapp/l10n/app_localizations.dart';"

def escape_regex(s):
    return re.escape(s)

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    modified = False

    for en_key, items in new_strings.items():
        key = items[0]
        # Match inside Text( or label: or title: or tooltip: or message: or subtitle:
        # e.g., Text('Budget') -> Text(AppLocalizations.of(context)!.budget)
        
        # We need a regex that matches `(prefix) 'String' (suffix)`
        # Prefix could be `Text(`, `title:`, `label:`, `hintText:`, `labelText:`, `tooltip:`, `message:`, `subtitle:`, `TextSpan(\s*text:\s*`
        # We replace the quoted string with `AppLocalizations.of(context)!.key`
        
        # We handle single quotes and double quotes. We must be careful if the string has escaped quotes inside, but our strings generally don't except "You didn\'t...". 
        
        escaped_en = escape_regex(en_key).replace("\\'", "['\"]").replace("'", "['\"]")
        # For simplicity, just search for the exact string surrounded by quotes and preceded by a UI keyword
        
        pattern = r"(Text\(\s*|title:\s*|label:\s*|hintText:\s*|labelText:\s*|tooltip:\s*|message:\s*|subtitle:\s*|text:\s*)['\"]" + escape_regex(en_key.replace("\\'", "'")) + r"['\"]"
        repl = r"\1AppLocalizations.of(context)!." + key
        
        content, n = re.subn(pattern, repl, content)
        if n > 0:
            modified = True
            
        # specifically handle "Are you sure you want to delete "
        if "delete" in en_key.lower():
            # Sometimes it's string interpolation: Text('Are you sure you want to delete "${x}"?')
            # we can't just do the above. Let's do a direct replacement for this specific one:
            # `'Are you sure you want to delete "${' -> `AppLocalizations.of(context)!.areYouSureDeletePrefix + '"${'
            pattern2 = r"['\"]Are you sure you want to delete \['\"]"
            repl2 = r"AppLocalizations.of(context)!.areYouSureDeletePrefix"
            content, n = re.subn(pattern2, repl2, content)
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
        print(f"Updated {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

