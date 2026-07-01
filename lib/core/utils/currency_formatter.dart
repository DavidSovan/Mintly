import 'package:intl/intl.dart';
import 'package:moneytrackerapp/domain/entities/settings.dart';

class CurrencyFormatter {
  static String format(double amount, SettingsEntity settings) {
    final formatCurrency = NumberFormat.currency(
      name: settings.currency,
      decimalDigits: settings.decimalFormat,
    );
    return formatCurrency.format(amount);
  }
}
