import 'package:flutter/material.dart';

class DesignSystem {
  static BoxDecoration cardDecoration(BuildContext context, {Color? accentColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    final fallbackAccent = colorScheme.primaryContainer;
    
    return BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        )
      ],
      border: Border(
        left: BorderSide(color: accentColor ?? fallbackAccent, width: 6),
      ),
    );
  }

  static BoxDecoration glowCardDecoration(BuildContext context, {Color? shadowColor}) {
    final colorScheme = Theme.of(context).colorScheme;
    return BoxDecoration(
      color: Theme.of(context).cardTheme.color,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: (shadowColor ?? colorScheme.primary).withOpacity(0.3),
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
  final Color? accentColor;
  final VoidCallback? onTap;

  const StyledCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.accentColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: DesignSystem.cardDecoration(context, accentColor: accentColor),
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [colorScheme.secondary.withOpacity(0.8), colorScheme.secondary],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.secondary.withOpacity(0.4),
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
          style: TextStyle(
            color: colorScheme.onSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
