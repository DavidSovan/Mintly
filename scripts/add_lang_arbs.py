import json

new_strings = {
  "english": ["English", "Inglés", "Anglais", "អង់គ្លេស"],
  "spanish": ["Spanish", "Español", "Espagnol", "អេស្ប៉ាញ"],
  "french": ["French", "Francés", "Français", "បារាំង"],
  "khmer": ["Khmer", "Khmer", "Khmer", "ខ្មែរ"]
}

def update_arb(file_path, index):
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    for key, items in new_strings.items():
        val = items[index]
        data[key] = val
        
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
if __name__ == '__main__':
    update_arb('lib/l10n/app_en.arb', 0)
    update_arb('lib/l10n/app_es.arb', 1)
    update_arb('lib/l10n/app_fr.arb', 2)
    update_arb('lib/l10n/app_km.arb', 3)
