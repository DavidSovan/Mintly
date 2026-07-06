import os
import glob

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    new_content = content.replace(
        "t.date.isAfter(DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day - 1))",
        "(t.date.compareTo(startOfWeek) >= 0)"
    )

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for filepath in glob.glob("lib/**/*.dart", recursive=True):
    process_file(filepath)
