import 'package:flutter/material.dart';

enum CustomButtonStyle {
  primary,
  secondary,
}

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = CustomButtonStyle.primary,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final CustomButtonStyle style;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final Widget button = style == CustomButtonStyle.primary
        ? ElevatedButton(onPressed: onPressed, child: child)
        : OutlinedButton(onPressed: onPressed, child: child);

    if (!expanded) {
      return button;
    }

    return SizedBox(width: double.infinity, child: button);
  }
}