import 'package:flutter/material.dart';
import '../../models/card_svg.dart';
import '../../models/card_display.dart';

// Convenience widget for hole cards
class HoleCards extends StatelessWidget {
  final List<int> cards;
  final bool showCards;
  final double height;
  final double spacing;
  final bool enableShadows;

  const HoleCards({
    Key? key,
    required this.cards,
    this.showCards = false,
    this.height = 80,
    this.spacing = 4.0,
    this.enableShadows = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate width based on standard card aspect ratio
    final cardWidth = height * 0.7;

    return CardDisplay(
      cards: cards.length == 2 ? cards : [0, 0], // Always show 2 cards
      showFaceUp: showCards,
      cardWidth: cardWidth,
      cardHeight: height,
      spacing: spacing,
      enableShadows: enableShadows,
    );
  }
}

// Convenience widget for community cards
class CommunityCards extends StatelessWidget {
  final List<int> cards;
  final double height;
  final double spacing;
  final bool enableShadows;
  final bool showAnimation;

  const CommunityCards({
    Key? key,
    required this.cards,
    this.height = 80,
    this.spacing = 4.0,
    this.enableShadows = true,
    this.showAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate width based on standard card aspect ratio
    final cardWidth = height * 0.7;

    // Pad to 5 cards with zeros if needed
    final List<int> displayCards = List<int>.from(cards);
    while (displayCards.length < 5) {
      displayCards.add(0);
    }

    return CardDisplay(
      cards: displayCards,
      showFaceUp: true,
      cardWidth: cardWidth,
      cardHeight: height,
      spacing: spacing,
      enableShadows: enableShadows,
    );
  }
}

// Single card widget for more flexibility
class CardWidget extends StatelessWidget {
  final int cardValue; // 8-bit integer from game core
  final bool faceDown;
  final double height;
  final bool enableShadow;
  final VoidCallback? onTap;

  const CardWidget({
    Key? key,
    required this.cardValue,
    this.faceDown = false,
    this.height = 80,
    this.enableShadow = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate width based on standard card aspect ratio
    final width = height * 0.7;

    Widget card = SvgCard(
      cardValue: cardValue,
      faceDown: faceDown,
      width: width,
      height: height,
      onTap: onTap,
    );

    // Add shadow if enabled
    if (enableShadow) {
      card = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(width * 0.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 3,
              offset: Offset(1, 1),
            ),
          ],
        ),
        child: card,
      );
    }

    return card;
  }
}
