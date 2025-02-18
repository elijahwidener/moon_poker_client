import 'package:flutter/material.dart';
import 'dart:math' as math;

class DealerButton extends StatefulWidget {
  final int position; // 0-8 for 9 seats
  final double tableWidth;
  final double tableHeight;
  final Duration animationDuration;

  const DealerButton({
    super.key,
    required this.position,
    required this.tableWidth,
    required this.tableHeight,
    this.animationDuration = const Duration(milliseconds: 500),
  });

  @override
  State<DealerButton> createState() => _DealerButtonState();
}

class _DealerButtonState extends State<DealerButton> {
  late Offset _position;

  @override
  void initState() {
    super.initState();
    _position = _calculatePosition(widget.position);
  }

  @override
  void didUpdateWidget(DealerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.position != widget.position ||
        oldWidget.tableWidth != widget.tableWidth ||
        oldWidget.tableHeight != widget.tableHeight) {
      _position = _calculatePosition(widget.position);
    }
  }

  Offset _calculatePosition(int seatPosition) {
    // Calculate center of table
    final centerX = widget.tableWidth / 2;
    final centerY = widget.tableHeight / 2;

    // Calculate radius - make it slightly smaller than the table
    final radius = math.min(centerX, centerY) * 0.65;

    // Calculate angle for position (starting from top, clockwise)
    final angle = (2 * math.pi * seatPosition / 9) - (math.pi / 2);

    // Make the orbit slightly oval
    final xRadius = radius * 1.2;
    final yRadius = radius * 0.9;

    // Calculate position
    return Offset(
      centerX + xRadius * math.cos(angle),
      centerY + yRadius * math.sin(angle),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      left: _position.dx - 15, // Half of button width
      top: _position.dy - 15, // Half of button height
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.black,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'D',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

// Optional dealer button animation controller for more complex animations
class DealerButtonController {
  final ValueNotifier<int> _positionNotifier;

  DealerButtonController(int initialPosition)
      : _positionNotifier = ValueNotifier(initialPosition);

  int get position => _positionNotifier.value;

  void moveButton(int newPosition) {
    _positionNotifier.value = newPosition;
  }

  void dispose() {
    _positionNotifier.dispose();
  }
}

// Animated version that handles its own state
class AnimatedDealerButton extends StatelessWidget {
  final DealerButtonController controller;
  final double tableWidth;
  final double tableHeight;

  const AnimatedDealerButton({
    super.key,
    required this.controller,
    required this.tableWidth,
    required this.tableHeight,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: controller._positionNotifier,
      builder: (context, position, child) {
        return DealerButton(
          position: position,
          tableWidth: tableWidth,
          tableHeight: tableHeight,
        );
      },
    );
  }
}
