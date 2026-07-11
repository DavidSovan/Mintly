import os
import re

files_to_update = [
    'lib/presentation/dashboard/widgets/dashboard_widgets.dart',
    'lib/presentation/accounts/screens/accounts_screen.dart',
    'lib/presentation/budgets/screens/budgets_screen.dart',
    'lib/presentation/reports/screens/reports_screen.dart',
    'lib/presentation/goals/screens/goals_screen.dart'
]

for filepath in files_to_update:
    with open(filepath, 'r') as f:
        content = f.read()
        
    original = content

    # Add import if missing
    import_statement = "import 'package:moneytrackerapp/presentation/settings/providers/settings_provider.dart';"
    if import_statement not in content and 'NumberFormat' in content:
        # find last import
        matches = list(re.finditer(r"^import\s+['\"].*?['\"];\s*", content, re.MULTILINE))
        if matches:
            last_match = matches[-1]
            idx = last_match.end()
            content = content[:idx] + import_statement + "\n" + content[idx:]

    content = content.replace("NumberFormat.simpleCurrency()", "NumberFormat.simpleCurrency(name: ref.watch(settingsProvider).value?.currency)")
    content = content.replace("NumberFormat.compactSimpleCurrency()", "NumberFormat.compactSimpleCurrency(name: ref.watch(settingsProvider).value?.currency)")
    content = content.replace("NumberFormat.simpleCurrency(decimalDigits: 0)", "NumberFormat.simpleCurrency(name: ref.watch(settingsProvider).value?.currency, decimalDigits: 0)")

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
            print(f"Updated {filepath}")
