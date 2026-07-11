import os
import re
import json

def extract_strings():
    directory = 'lib/presentation'
    
    # We will look for Text('...'), title: '...', hintText: '...', labelText: '...', subtitle: '...'
    # For simplicity, we only match strings without interpolation or escaped quotes.
    patterns = [
        r"Text\(\s*'([^'\$]+)'\s*\)",
        r"Text\(\s*\"([^\”\$]+)\"\s*\)",
        r"title:\s*'([^'\$]+)'",
        r"hintText:\s*'([^'\$]+)'",
        r"labelText:\s*'([^'\$]+)'",
        r"label:\s*Text\(\s*'([^'\$]+)'\s*\)",
        r"subtitle:\s*'([^'\$]+)'"
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
                        # Exclude obvious non-UI strings like 'en', 'es', or very short things if needed
                        # But most matches will be valid UI text
                        if len(match.strip()) > 0:
                            found_strings.add(match)

    # Let's also check for generic string assignments in specific known widgets?
    # This should be good enough for a 90% pass.
    
    # Also add standard things we know we need
    found_strings.update(['English', 'Spanish', 'French', 'Language', 'Theme', 'Mintly'])

    # Write to a JSON file
    with open('extracted_strings.json', 'w') as f:
        json.dump(list(found_strings), f, indent=2)

if __name__ == '__main__':
    extract_strings()
