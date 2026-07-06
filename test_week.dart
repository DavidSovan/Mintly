void main() {
  final now = DateTime(2026, 7, 6); // Monday
  
  // Test Monday as first day
  int daysToSubtractMon = 1 == 1 ? now.weekday - 1 : now.weekday % 7;
  print('Monday start, today is Monday: subtract $daysToSubtractMon, start: ${now.subtract(Duration(days: daysToSubtractMon))}');

  // Test Sunday as first day
  int daysToSubtractSun = 7 == 1 ? now.weekday - 1 : now.weekday % 7;
  print('Sunday start, today is Monday: subtract $daysToSubtractSun, start: ${now.subtract(Duration(days: daysToSubtractSun))}');
}
