import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    original = content
    
    # 1. Add design_system import
    if "import 'package:moneytrackerapp/core/theme/design_system.dart';" not in content:
        content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:moneytrackerapp/core/theme/design_system.dart';")

    # 2. Replace basic Scaffold background color logic if it exists
    content = re.sub(r'backgroundColor: Theme\.of\(context\)\.colorScheme\.surface,', r'backgroundColor: Theme.of(context).colorScheme.surface,', content)

    # 3. FloatingActionButton elevation & shape
    # handled by app_theme.dart

    if content != original:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"Updated {filepath}")

for root, _, files in os.walk('lib/presentation'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
