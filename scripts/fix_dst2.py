import os
import glob

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    new_content = content.replace(
        "startOfWeek.subtract(const Duration(days: 1))",
        "DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day - 1)"
    )
    new_content = new_content.replace(
        "endOfWeek.add(const Duration(days: 1))",
        "DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day + 1)"
    )

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for filepath in glob.glob("lib/**/*.dart", recursive=True):
    process_file(filepath)
