import json

def append_cash():
    arbs = {
        'lib/l10n/app_en.arb': 'Cash',
        'lib/l10n/app_es.arb': 'Efectivo',
        'lib/l10n/app_fr.arb': 'Espèces',
        'lib/l10n/app_km.arb': 'សាច់ប្រាក់'
    }
    for filepath, val in arbs.items():
        with open(filepath, 'r') as f:
            data = json.load(f)
        data['cash'] = val
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

if __name__ == '__main__':
    append_cash()
