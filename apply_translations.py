import os
import re

keys_map = {
  "e.g., Groceries, Salary...": "eG_Groceries",
  "Please select a category": "pleaseSelectACategory",
  "Delete all data": "deleteAllData",
  "Delete Category": "deleteCategory",
  "Expenses by Category": "expensesByCategory",
  "Note (Optional)": "noteOptional",
  "Transaction deleted": "transactionDeleted",
  "Income vs Expenses": "incomeVsExpenses",
  "Account Name": "accountName",
  "Income": "income",
  "Theme Settings": "themeSettings",
  "Light": "light",
  "Expense over time": "expenseOverTime",
  "Language": "language",
  "Spending Trend": "spendingTrend",
  "Restore Database": "restoreDatabase",
  "Initial Balance": "initialBalance",
  "From Account": "fromAccount",
  "Transaction duplicated": "transactionDuplicated",
  "e.g., Vacation, Emergency Fund...": "eG_Vacation",
  "e.g., Main Checking, Cash...": "eG_MainChecking",
  "Are you sure you want to delete this budget?": "areYouSureDeleteBudget",
  "Amount": "amount",
  "Expense": "expense",
  "First day of week": "firstDayOfWeek",
  "Replace data from a backup.": "replaceDataFromBackup",
  "Spanish": "spanish",
  "Backup your data safely.": "backupYourDataSafely",
  "Notifications": "notifications",
  "French": "french",
  "Side-by-side comparison": "sideBySideComparison",
  "English": "english",
  "Mintly": "mintly",
  "Overall Budget (All)": "overallBudget",
  "Delete Account": "deleteAccount",
  "Dark": "dark",
  "Duplicate": "duplicate",
  "Category Name": "categoryName",
  "Delete": "delete",
  "Confirm": "confirm",
  "Currency": "currency",
  "Are you sure you want to delete this transaction?": "areYouSureDeleteTransaction",
  "Cancel": "cancel",
  "Export Database": "exportDatabase",
  "Where your money goes": "whereYourMoneyGoes",
  "Reset App": "resetApp",
  "Delete Transaction": "deleteTransaction",
  "Please select at least one category": "pleaseSelectAtLeastOneCategory",
  "Decimal Format": "decimalFormat",
  "System": "system",
  "Removes transactions and budgets.": "removesTransactionsAndBudgets",
  "Theme": "theme",
  "Today": "today",
  "This Week": "thisWeek",
  "This Month": "thisMonth",
  "Transfer": "transfer",
  "Save": "save",
  "Add Transaction": "addTransaction",
  "Accounts": "accounts",
  "Budgets": "budgets",
  "Reports": "reports",
  "Goals": "goals",
  "Settings": "settings",
  "Home": "home",
  "Add Budget": "addBudget",
  "Add Account": "addAccount",
  "Add Category": "addCategory",
  "Add Goal": "addGoal",
  "Recent Transactions": "recentTransactions",
  "See All": "seeAll",
  "To Account": "toAccount",
  "Monthly": "monthly",
  "Yearly": "yearly",
  "Weekly": "weekly",
  "Daily": "daily"
}

import_statement = "import 'package:flutter_gen/gen_l10n/app_localizations.dart';"

def escape_regex(s):
    return re.escape(s)

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content
    modified = False

    for eng, key in keys_map.items():
        # Build regex to match Text('Eng'), title: 'Eng', label: 'Eng', hintText: 'Eng', labelText: 'Eng', subtitle: 'Eng', SnackBar(content: Text('Eng'))
        # We need to be careful. We can just replace occurrences of 'Eng' or "Eng" if they are surrounded by specific wrappers.
        
        # 1. Text('Eng')
        pattern1 = r"Text\(\s*['\"]" + escape_regex(eng) + r"['\"]\s*\)"
        repl1 = f"Text(AppLocalizations.of(context)!.{key})"
        content, n = re.subn(pattern1, repl1, content)
        if n > 0: modified = True

        # 2. title: 'Eng' or title: "Eng"
        pattern2 = r"title:\s*['\"]" + escape_regex(eng) + r"['\"]"
        repl2 = f"title: AppLocalizations.of(context)!.{key}"
        content, n = re.subn(pattern2, repl2, content)
        if n > 0: modified = True
        
        # 3. hintText: 'Eng'
        pattern3 = r"hintText:\s*['\"]" + escape_regex(eng) + r"['\"]"
        repl3 = f"hintText: AppLocalizations.of(context)!.{key}"
        content, n = re.subn(pattern3, repl3, content)
        if n > 0: modified = True

        # 4. labelText: 'Eng'
        pattern4 = r"labelText:\s*['\"]" + escape_regex(eng) + r"['\"]"
        repl4 = f"labelText: AppLocalizations.of(context)!.{key}"
        content, n = re.subn(pattern4, repl4, content)
        if n > 0: modified = True

        # 5. subtitle: 'Eng' (Except when inside our map in settings_screen)
        pattern5 = r"subtitle:\s*['\"]" + escape_regex(eng) + r"['\"]"
        repl5 = f"subtitle: AppLocalizations.of(context)!.{key}"
        content, n = re.subn(pattern5, repl5, content)
        if n > 0: modified = True
        
        # 6. label: 'Eng'
        pattern6 = r"label:\s*['\"]" + escape_regex(eng) + r"['\"]"
        repl6 = f"label: AppLocalizations.of(context)!.{key}"
        content, n = re.subn(pattern6, repl6, content)
        if n > 0: modified = True
        
        # 7. SnackBar content
        pattern7 = r"SnackBar\(\s*content:\s*Text\(\s*['\"]" + escape_regex(eng) + r"['\"]\s*\)"
        repl7 = f"SnackBar(content: Text(AppLocalizations.of(context)!.{key})"
        content, n = re.subn(pattern7, repl7, content)
        if n > 0: modified = True

    if modified:
        # Add import if missing
        if import_statement not in content:
            # Find the last import statement
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

for root, dirs, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
