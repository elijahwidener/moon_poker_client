// lib/UI/widgets/card_widgets.dart

import 'package:flutter/material.dart';
import '../../models/card_display.dart';

class AnimatedCard extends StatefulWidget {
  final int cardValue;
  final bool showFaceUp;
  final double width;
  final double height;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const AnimatedCard({
    super.key,
    required this.cardValue,
    this.showFaceUp = false,
    required this.width,
    required this.height,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeOutCubic,
  });

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(begin: -200.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );

    _rotationAnimation = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.animationCurve),
    );

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0; // Skip animation if not needed
    }
  }

  @override
  void didUpdateWidget(AnimatedCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !oldWidget.animate) {
      _controller.reset();
      _controller.forward();
    }
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
        return Transform.translate(
          offset: Offset(_slideAnimation.value, 0),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: CardWidget(
              cardValue: widget.cardValue,
              showFaceUp: widget.showFaceUp,
              width: widget.width,
              height: widget.height,
            ),
          ),
        );
      },
    );
  }
}

// A wrapper for the existing CardDisplay to handle a single card
class CardWidget extends StatelessWidget {
  final int cardValue;
  final bool showFaceUp;
  final double width;
  final double height;

  const CardWidget({
    super.key,
    required this.cardValue,
    this.showFaceUp = false,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return CardDisplay(
      cards: [cardValue],
      showFaceUp: showFaceUp,
      cardWidth: width,
      cardHeight: height,
    );
  }
}

class CommunityCards extends StatelessWidget {
  final List<int> cards;
  final double height;
  final double spacing;
  final bool animate;

  const CommunityCards({
    super.key,
    required this.cards,
    this.height = 120,
    this.spacing = 8.0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    const maxCards = 5; // Maximum community cards in poker
    final visibleCards = cards.where((card) => card != 0).toList();

    return ClipRect(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < maxCards; i++)
                if (i < visibleCards.length)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                    child: AnimatedCard(
                      cardValue: visibleCards[i],
                      showFaceUp: true,
                      width: height * 0.6,
                      height: height,
                      animate: animate,
                      // Stagger the animations
                      animationDuration:
                          Duration(milliseconds: 300 + (i * 100)),
                    ),
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                    child: SizedBox(
                      width: height * 0.6,
                      height: height,
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class HoleCards extends StatelessWidget {
  final List<int> cards;
  final bool showCards;
  final double height;
  final double spacing;
  final bool animate;

  const HoleCards({
    super.key,
    required this.cards,
    this.showCards = false,
    this.height = 120,
    this.spacing = 8.0,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final validCards = cards.where((card) => card != 0).toList();

    return ClipRect(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < validCards.length; i++)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: spacing / 2),
                  child: AnimatedCard(
                    cardValue: validCards[i],
                    showFaceUp: showCards,
                    width: height * 0.6,
                    height: height,
                    animate: animate,
                    // Stagger the animations slightly
                    animationDuration: Duration(milliseconds: 300 + (i * 50)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
