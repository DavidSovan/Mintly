import json
import os

new_strings = {
  "savedAmount": ["Saved {amount}", "Ahorrado {amount}", "Économisé {amount}", "សន្សំបាន {amount}"],
  "savedHidden": ["Saved ••••", "Ahorrado ••••", "Économisé ••••", "សន្សំបាន ••••"]
}

def update_arb(file_path, index):
    with open(file_path, 'r') as f:
        data = json.load(f)
    
    for key, items in new_strings.items():
        val = items[index]
        data[key] = val
        if '{amount}' in val:
            data['@'+key] = {'placeholders': {'amount': {'type': 'String'}}}
        
    with open(file_path, 'w') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        
update_arb('lib/l10n/app_en.arb', 0)
update_arb('lib/l10n/app_es.arb', 1)
update_arb('lib/l10n/app_fr.arb', 2)
update_arb('lib/l10n/app_km.arb', 3)
