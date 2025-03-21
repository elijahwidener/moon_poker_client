import 'package:flutter/material.dart';
import 'dart:math' as math;

class ChipAnimation extends StatefulWidget {
  final int amount;
  final Offset startPosition;
  final Offset endPosition;
  final VoidCallback? onComplete;
  final Duration duration;
  final int chipCount;

  const ChipAnimation({
    super.key,
    required this.amount,
    required this.startPosition,
    required this.endPosition,
    this.onComplete,
    this.duration = const Duration(milliseconds: 500),
    // Determine number of chips to show based on amount
    this.chipCount = 5,
  });

  @override
  State<ChipAnimation> createState() => _ChipAnimationState();
}

class _ChipAnimationState extends State<ChipAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<Offset>> _positionAnimations;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Create slightly different paths for each chip
    _positionAnimations = List.generate(
      widget.chipCount,
      (index) {
        return Tween<Offset>(
          begin: widget.startPosition,
          end: widget.endPosition,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              0.0 + (index * 0.1).clamp(0.0, 0.5), // Stagger start times
              0.7 + (index * 0.1).clamp(0.0, 0.3), // Stagger end times
              curve: Curves.easeOutQuad,
            ),
          ),
        );
      },
    );

    _controller.forward().then((_) {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            for (int i = 0; i < widget.chipCount; i++)
              Positioned(
                left: _positionAnimations[i].value.dx - 12, // Half chip width
                top: _positionAnimations[i].value.dy - 12, // Half chip height
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: _buildChip(i),
                ),
              ),
            // Show amount text near the end position
            if (_controller.value > 0.7)
              Positioned(
                left: widget.endPosition.dx,
                top: widget.endPosition.dy - 20,
                child: Opacity(
                  opacity: (_controller.value - 0.7) * 3.3, // Fade in
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '\$${widget.amount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildChip(int index) {
    // Different colors for different denominations
    final colors = [
      Colors.white,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.black,
    ];

    // Assign color based on chip value
    final colorIndex = math.min(4, index % 5);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors[colorIndex],
        border: Border.all(
          color: Colors.grey.shade800,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.5 * 255).toInt()),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }
}
