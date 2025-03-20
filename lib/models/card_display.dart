import 'package:flutter/material.dart';

class CardDisplay extends StatelessWidget {
  final List<int> cards;
  final bool showFaceUp;
  final double cardWidth;
  final double cardHeight;

  const CardDisplay({
    super.key,
    required this.cards,
    this.showFaceUp = false,
    this.cardWidth = 40,
    this.cardHeight = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < cards.length; i++)
          Padding(
            padding: EdgeInsets.only(right: i < cards.length - 1 ? 2.0 : 0),
            child: _buildCard(cards[i]),
          ),
      ],
    );
  }

  Widget _buildCard(int cardValue) {
    // Card face-down if not showing face up
    if (!showFaceUp || cardValue == 0) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.white, width: 1),
        ),
      );
    }

    // Convert card value to rank and suit
    final rank = cardValue >> 4;
    final suit = cardValue & 0x0F;

    // Card face display
    return Container(
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _rankString(rank),
            style: TextStyle(
              color: _suitColor(suit),
              fontWeight: FontWeight.bold,
              fontSize: cardWidth * 0.4,
            ),
          ),
          SizedBox(height: cardHeight * 0.05),
          Text(
            _suitString(suit),
            style: TextStyle(
              color: _suitColor(suit),
              fontSize: cardWidth * 0.5,
            ),
          ),
        ],
      ),
    );
  }

  String _rankString(int rank) {
    switch (rank) {
      case 0x02:
        return '2';
      case 0x03:
        return '3';
      case 0x04:
        return '4';
      case 0x05:
        return '5';
      case 0x06:
        return '6';
      case 0x07:
        return '7';
      case 0x08:
        return '8';
      case 0x09:
        return '9';
      case 0x0A:
        return '10';
      case 0x0B:
        return 'J';
      case 0x0C:
        return 'Q';
      case 0x0D:
        return 'K';
      case 0x0E:
        return 'A';
      default:
        return '?';
    }
  }

  String _suitString(int suit) {
    switch (suit) {
      case 0x04:
        return '♠';
      case 0x03:
        return '♥';
      case 0x02:
        return '♣';
      case 0x01:
        return '♦';
      default:
        return '?';
    }
  }

  Color _suitColor(int suit) {
    // Hearts and diamonds are red, spades and clubs are black
    return (suit == 0x03 || suit == 0x01) ? Colors.red : Colors.black;
  }
}
