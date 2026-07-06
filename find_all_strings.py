import os
import re

def find_all_strings():
    directory = 'lib'
    found = set()
    
    string_pattern = re.compile(r"(['\"])(.*?[a-zA-Z].*?)\1")
    
    for root, dirs, files in os.walk(directory):
        if 'l10n' in root or 'theme' in root or 'utils' in root:
            continue
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                
                content = re.sub(r"import\s+['\"].*?['\"];", "", content)
                content = re.sub(r"export\s+['\"].*?['\"];", "", content)
                
                for match in string_pattern.findall(content):
                    s = match[1]
                    if "package:" in s or s.startswith("/") or s.endswith(".png") or s.endswith(".svg"):
                        continue
                    if "_" in s and " " not in s: 
                        continue
                    
                    if ' ' in s or (len(s) > 0 and s[0].isupper()):
                        found.add(s)

    for s in sorted(list(found)):
        print(f'"{s}"')

if __name__ == '__main__':
    find_all_strings()
