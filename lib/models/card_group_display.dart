import 'package:flutter/material.dart';
import '../../models/card_display.dart';

// Widget for displaying poker cards with a label
class CardGroupDisplay extends StatelessWidget {
  final List<int> cards;
  final bool showFaceUp;
  final String? label;
  final Color backgroundColor;
  final double cardWidth;
  final double cardHeight;
  final double spacing;

  const CardGroupDisplay({
    super.key,
    required this.cards,
    this.showFaceUp = false,
    this.label,
    this.backgroundColor = Colors.black38,
    this.cardWidth = 50,
    this.cardHeight = 75,
    this.spacing = 5,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out invalid cards if showing face up
    final displayCards =
        showFaceUp ? cards.where((card) => card != 0).toList() : cards;

    if (displayCards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null &&
              displayCards.isNotEmpty) // Only show label when there are cards
            Text(
              label!,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          if (label != null && displayCards.isNotEmpty)
            const SizedBox(height: 8),
          CardDisplay(
            cards: displayCards,
            showFaceUp: showFaceUp,
            cardWidth: cardWidth,
            cardHeight: cardHeight,
          ),
        ],
      ),
    );
  }
}
