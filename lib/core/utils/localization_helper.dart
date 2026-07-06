import 'package:flutter/material.dart';
import 'package:moneytrackerapp/l10n/app_localizations.dart';

extension LocalizedName on String {
  String getLocalized(BuildContext context) {
    final loc = AppLocalizations.of(context);
    if (loc == null) return this;
    
    switch (this) {
      case 'Bank': return loc.bank;
      case 'Bills': return loc.bills;
      case 'Bonus': return loc.bonus;
      case 'Cash': return loc.cash;
      case 'Credit Card': return loc.creditCard;
      case 'E-Wallet': return loc.eWallet;
      case 'Education': return loc.education;
      case 'Entertainment': return loc.entertainment;
      case 'Food': return loc.food;
      case 'Freelance': return loc.freelance;
      case 'Gift': return loc.gift;
      case 'Health': return loc.health;
      case 'Investment': return loc.investment;
      case 'Salary': return loc.salary;
      case 'Shopping': return loc.shopping;
      case 'Transport': return loc.transport;
      case 'Unknown': return loc.unknown;
      default: return this;
    }
  }
}
