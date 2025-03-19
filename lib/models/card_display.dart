import 'package:flutter/material.dart';
import 'card_svg.dart';

class CardDisplay extends StatelessWidget {
  final List<int> cards;
  final bool showFaceUp;
  final double cardWidth;
  final double cardHeight;
  final double spacing;
  final bool enableShadows;

  const CardDisplay({
    Key? key,
    required this.cards,
    this.showFaceUp = false,
    this.cardWidth = 40,
    this.cardHeight = 60,
    this.spacing = 2.0,
    this.enableShadows = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < cards.length; i++)
          Padding(
            padding: EdgeInsets.only(right: i < cards.length - 1 ? spacing : 0),
            child: _buildCard(cards[i], i),
          ),
      ],
    );
  }

  Widget _buildCard(int cardValue, int index) {
    // Apply a slight offset for stacked card effect
    final offset = index * 0.5;

    Widget card = SvgCard(
      cardValue: cardValue,
      faceDown: !showFaceUp || cardValue == 0,
      width: cardWidth,
      height: cardHeight,
    );

    // Add shadow if enabled
    if (enableShadows) {
      card = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(cardWidth * 0.1),
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

    return Transform.translate(
      offset: Offset(0, offset),
      child: card,
    );
  }
}
