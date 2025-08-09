import 'package:flutter/material.dart';

/// A simple lives indicator that always renders exactly 3 heart slots,
/// filled according to the provided lives count.
class LivesIndicator extends StatelessWidget {
  final int lives; // current lives (0..3)
  final double size;
  final Color color;

  const LivesIndicator({
    super.key,
    required this.lives,
    this.size = 18,
    this.color = const Color(0xFFEF4444),
  });

  @override
  Widget build(BuildContext context) {
    final safeLives = lives.clamp(0, 3);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        final filled = index < safeLives;
        return Padding(
          padding: const EdgeInsets.only(right: 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              filled ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: color,
              size: size,
              semanticLabel: filled
                  ? 'Life ${index + 1}: filled'
                  : 'Life ${index + 1}: empty',
            ),
          ),
        );
      }),
    );
  }
}
