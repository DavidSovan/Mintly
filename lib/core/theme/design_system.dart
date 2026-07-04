import 'package:flutter/material.dart';
import 'app_theme.dart';

class DesignSystem {
  static BoxDecoration cardDecoration({Color accentColor = AppTheme.primaryLight}) {
    return BoxDecoration(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: AppTheme.primaryTeal.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        )
      ],
      border: Border(
        left: BorderSide(color: accentColor, width: 6),
      ),
    );
  }

  static BoxDecoration glowCardDecoration({Color shadowColor = AppTheme.primaryTeal}) {
    return BoxDecoration(
      color: AppTheme.surfaceCard,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 4),
        )
      ],
    );
  }
}

class StyledCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color accentColor;
  final VoidCallback? onTap;

  const StyledCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accentColor = AppTheme.primaryLight,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: DesignSystem.cardDecoration(accentColor: accentColor),
        child: child,
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const PrimaryButton({Key? key, required this.text, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          colors: [AppTheme.accentLight, AppTheme.accentGold],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
