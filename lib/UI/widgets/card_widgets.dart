import 'package:flutter/material.dart';
import '../../models/card_display.dart'; // Import the new card display

// Convenience widget for hole cards
class HoleCards extends StatelessWidget {
  final List<int> cards;
  final bool showCards;
  final double height;
  final double spacing;

  const HoleCards({
    Key? key,
    required this.cards,
    this.showCards = false,
    this.height = 120,
    this.spacing = 8.0,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return ClipRect(
      // Clips any overflowing part
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: CardDisplay(
            cards: cards,
            showFaceUp: showCards,
            cardWidth: height * 0.6,
            cardHeight: height,
          ),
        ),
      ),
    );
  }
}

// Convenience widget for community cards
class CommunityCards extends StatelessWidget {
  final List<int> cards;
  final double height;
  final double spacing;

  const CommunityCards({
    Key? key,
    required this.cards,
    this.height = 120,
    this.spacing = 8.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      // Clips any overflowing part
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: spacing / 2),
          child: CardDisplay(
            cards: cards,
            showFaceUp: true,
            cardWidth: height * 0.6,
            cardHeight: height,
          ),
        ),
      ),
    );
  }
}
