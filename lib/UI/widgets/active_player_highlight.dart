import 'package:flutter/material.dart';

class ActivePlayerHighlight extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color highlightColor;

  const ActivePlayerHighlight({
    super.key,
    required this.child,
    required this.isActive,
    this.highlightColor = Colors.blue,
  });

  @override
  State<ActivePlayerHighlight> createState() => _ActivePlayerHighlightState();
}

class _ActivePlayerHighlightState extends State<ActivePlayerHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ActivePlayerHighlight oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.repeat(reverse: true);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.highlightColor.withAlpha(
                  (255 * (0.3 + 0.7 * _pulseAnimation.value)).toInt()),
              width: 2.0 + _pulseAnimation.value * 2.0,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: widget.highlightColor.withAlpha(
                    ((0.15 + 0.15 * _pulseAnimation.value) * 255).toInt()),
                blurRadius: 8.0 + _pulseAnimation.value * 8.0,
                spreadRadius: 2.0 + _pulseAnimation.value * 2.0,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
