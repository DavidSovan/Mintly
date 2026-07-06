import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    new_content = content.replace(
        "import 'package:flutter_gen/gen_l10n/app_localizations.dart';", 
        "import 'package:moneytrackerapp/l10n/app_localizations.dart';"
    )

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed import in {filepath}")

for root, dirs, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            process_file(os.path.join(root, file))
