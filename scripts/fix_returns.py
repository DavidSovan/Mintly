import os
import re

def fix_returns():
    directory = 'lib/presentation'
    
    replacements = {
        "'Please enter a goal name'": "AppLocalizations.of(context)!.enterGoalName",
        "'Please enter a name'": "AppLocalizations.of(context)!.enterName",
        "'Please enter a valid number'": "AppLocalizations.of(context)!.enterValidNumberPlease",
        "'Please enter amount'": "AppLocalizations.of(context)!.enterAmountPlease",
        "'Please enter initial balance'": "AppLocalizations.of(context)!.enterInitialBalance",
        "'Please enter target amount'": "AppLocalizations.of(context)!.enterTargetAmount",
        "'Please select an account'": "AppLocalizations.of(context)!.selectAccountPlease",
        "'Please select a category'": "AppLocalizations.of(context)!.pleaseSelectACategory",
        "'Please select at least one category'": "AppLocalizations.of(context)!.pleaseSelectAtLeastOneCategory",
        "'Invalid amount'": "AppLocalizations.of(context)!.invalidAmount",
        "'Invalid number'": "AppLocalizations.of(context)!.invalidNumber",
        "'Unknown'": "AppLocalizations.of(context)!.unknown"
    }

    import_stmt = "import 'package:moneytrackerapp/l10n/app_localizations.dart';"

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()

                modified = False
                for old, new in replacements.items():
                    if old in content:
                        content = content.replace(old, new)
                        modified = True

                if modified:
                    if import_stmt not in content:
                        imports_end = 0
                        for m in re.finditer(r"^import\s+['\"].*?['\"];\s*", content, re.MULTILINE):
                            imports_end = m.end()
                        if imports_end > 0:
                            content = content[:imports_end] + import_stmt + "\n" + content[imports_end:]
                        else:
                            content = import_stmt + "\n\n" + content
                    
                    with open(filepath, 'w') as f:
                        f.write(content)
                        print(f"Fixed returns in {filepath}")

if __name__ == '__main__':
    fix_returns()
