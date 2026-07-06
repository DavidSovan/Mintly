import os
import re

files_to_fix = [
    'lib/presentation/budgets/screens/add_edit_budget_screen.dart',
    'lib/presentation/settings/screens/theme_settings_screen.dart',
    'lib/presentation/transactions/screens/add_edit_transaction_screen.dart',
    'lib/presentation/transactions/widgets/transaction_item.dart'
]

for filepath in files_to_fix:
    with open(filepath, 'r') as f:
        content = f.read()

    # To fix `const [` containing AppLocalizations, we can just replace `const [` with `[` or `const  <type>[` with `<type>[` 
    # but only on lines that contain AppLocalizations, or just globally because removing const doesn't break compilation, it just removes optimization.
    
    # Let's remove `const ` if it's on the same line as AppLocalizations
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        if 'AppLocalizations.of' in line and 'const ' in line:
            line = line.replace('const ', '')
        new_lines.append(line)
        
    content = '\n'.join(new_lines)
    
    # Sometimes it's on a previous line:
    # children: const [
    #   Text(AppLocalizations...
    
    # Let's replace `const [` with `[` and `const Widget[` with `Widget[` if followed by AppLocalizations in the next few lines.
    # The safest is to just do a regex that replaces `const\s+\[` with `[` if there's AppLocalizations in the file. Since these files use AppLocalizations, we can just remove `const [` and `const <type>[`.
    
    content = re.sub(r'const\s+\[', r'[', content)
    content = re.sub(r'const\s+Widget\s*\[', r'Widget[', content)
    content = re.sub(r'const\s+Padding\(', r'Padding(', content)
    content = re.sub(r'const\s+Column\(', r'Column(', content)
    content = re.sub(r'const\s+Row\(', r'Row(', content)
    content = re.sub(r'const\s+Center\(', r'Center(', content)
    content = re.sub(r'const\s+Expanded\(', r'Expanded(', content)
    content = re.sub(r'const\s+SizedBox\(', r'SizedBox(', content)
    content = re.sub(r'const\s+Icon\(', r'Icon(', content)
    content = re.sub(r'const\s+Text\(', r'Text(', content)

    with open(filepath, 'w') as f:
        f.write(content)
