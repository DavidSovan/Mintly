import os
import glob

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Replace subtract(Duration(days: daysToSubtract)) with DateTime(now.year, now.month, now.day - daysToSubtract)
    new_content = content.replace(
        "DateTime(now.year, now.month, now.day).subtract(Duration(days: daysToSubtract))",
        "DateTime(now.year, now.month, now.day - daysToSubtract)"
    )
    
    # Replace endOfWeek logic
    new_content = new_content.replace(
        "startOfWeek.add(const Duration(days: 6))",
        "DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + 6)"
    )

    # Replace currentWeekDays list generation
    new_content = new_content.replace(
        "startOfWeek.add(Duration(days: i))",
        "DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i)"
    )

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for filepath in glob.glob("lib/**/*.dart", recursive=True):
    process_file(filepath)
