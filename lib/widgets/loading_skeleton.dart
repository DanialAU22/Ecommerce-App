import 'package:flutter/material.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    this.height = 100,
    this.width = double.infinity,
    this.borderRadius = 12,
  });

  final double height;
  final double width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.25, end: 0.55),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeInOut,
      builder: (BuildContext context, double value, Widget? child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: value),
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        );
      },
      onEnd: () {},
    );
  }
}
