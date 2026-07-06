import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    # Fix broken syntax:
    # `Text(AppLocalizations.of(context)!.areYouSureDeletePrefix${` -> `Text('${AppLocalizations.of(context)!.areYouSureDeletePrefix} "${`
    content = content.replace("Text(AppLocalizations.of(context)!.areYouSureDeletePrefix${", "Text('${AppLocalizations.of(context)!.areYouSureDeletePrefix} \"${")
    content = content.replace("title: Text(AppLocalizations.of(context)!.areYouSureDeletePrefix${", "title: Text('${AppLocalizations.of(context)!.areYouSureDeletePrefix} \"${")
    
    # Also fix some specific ones that might have `Text(AppLocalizations.of(context)!.areYouSureDeletePrefix`
    content = re.sub(r'AppLocalizations\.of\(context\)!\.areYouSureDeletePrefix\$\{([^}]+)\}"\?', r"'${AppLocalizations.of(context)!.areYouSureDeletePrefix} \"${\1}\"?'", content)

    # Let's fix the remaining consts:
    # Just run regex to remove `const ` in front of `Text(` if `AppLocalizations` is in the line
    lines = content.split('\n')
    new_lines = []
    for line in lines:
        if 'AppLocalizations' in line and 'const ' in line:
            line = line.replace('const ', '')
        new_lines.append(line)
        
    content = '\n'.join(new_lines)

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)

for root, dirs, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))

