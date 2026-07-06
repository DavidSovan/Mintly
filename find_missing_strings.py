import os
import re

def find_hardcoded_strings():
    directory = 'lib/presentation'
    
    # We want to match: `Text('...')` or `title: '...'` or `label: '...'` etc.
    # Where ... does not contain AppLocalizations and does not contain interpolation `$`
    patterns = [
        r"(?:Text\(\s*|title:\s*|label:\s*|hintText:\s*|labelText:\s*|tooltip:\s*|subtitle:\s*|message:\s*|TextSpan\(\s*text:\s*)['\"]([^'\$]+)['\"]"
    ]
    
    found_strings = set()
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                    
                for pattern in patterns:
                    matches = re.findall(pattern, content)
                    for match in matches:
                        # exclude generic things or already translated
                        if len(match.strip()) > 0 and 'AppLocalizations' not in match:
                            found_strings.add(match)

    print("--- MISSING STRINGS ---")
    for s in sorted(list(found_strings)):
        print(f'"{s}",')

if __name__ == '__main__':
    find_hardcoded_strings()
