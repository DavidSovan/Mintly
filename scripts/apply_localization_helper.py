import os
import re

def fix_names():
    directory = 'lib/presentation'
    
    import_stmt = "import 'package:moneytrackerapp/core/utils/localization_helper.dart';"
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()

                original = content
                
                # Replace in Text()
                content = re.sub(r'Text\((cat\.name)\)', r'Text(\1.getLocalized(context))', content)
                content = re.sub(r'Text\((category\.name)\)', r'Text(\1.getLocalized(context))', content)
                content = re.sub(r'Text\((acc\.name)\)', r'Text(\1.getLocalized(context))', content)
                content = re.sub(r'Text\((c\.name)\)', r'Text(\1.getLocalized(context))', content)
                content = re.sub(r'Text\((goal\.name)\)', r'Text(\1)', content) # no getLocalized for user-typed goals
                
                # Replace in string interpolation '${cat.name}' -> '${cat.name.getLocalized(context)}'
                content = re.sub(r'\$\{(cat\.name)\}', r'${\1.getLocalized(context)}', content)
                content = re.sub(r'\$\{(category\.name)\}', r'${\1.getLocalized(context)}', content)
                content = re.sub(r'\$\{(acc\.name)\}', r'${\1.getLocalized(context)}', content)
                
                # specific cases
                content = content.replace("catName = selectedCats.map((c) => c.name).join(', ');", "catName = selectedCats.map((c) => c.name.getLocalized(context)).join(', ');")
                content = content.replace("String name = cat?.name ?? 'Unknown';", "String name = cat?.name.getLocalized(context) ?? AppLocalizations.of(context)!.unknown;")
                
                if content != original:
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
                        print(f"Added getLocalized in {filepath}")

if __name__ == '__main__':
    fix_names()
