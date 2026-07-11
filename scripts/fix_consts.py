import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original_content = content
    
    # Replace `const Text(AppLocalizations` with `Text(AppLocalizations`
    content = re.sub(r'const\s+Text\(AppLocalizations', r'Text(AppLocalizations', content)
    
    # Sometimes it's `const [ ... AppLocalizations ... ]` -> we might need to remove const on lists.
    # We can just remove `const` if it's before a widget that uses AppLocalizations, but standard regex might fail for complex brackets.
    # Instead, we remove `const ` from any line that contains AppLocalizations if it's causing an issue.
    # Or specifically:
    # `const TabBarView` -> `TabBarView` if inside it has AppLocalizations.
    # For now, let's just do a greedy replace for `const Text(AppLocalizations` and see.
    # Wait, in the errors:
    # lib/presentation/settings/screens/theme_settings_screen.dart:17:27 `invalid_constant`
    # lib/presentation/settings/screens/theme_settings_screen.dart:58:23 `non_constant_list_element`

    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)

for root, dirs, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
