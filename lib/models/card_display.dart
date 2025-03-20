import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

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
    this.cardWidth = 85, // Increased width
    this.cardHeight = 120, // Increased height
    this.spacing = 8.0, // Increased spacing
    this.enableShadows = true,
  }) : super(key: key);

  // Convert our 8-bit card value to PlayingCard format
  PlayingCard _convertToPlayingCard(int value) {
    if (value == 0)
      return PlayingCard(Suit.hearts, CardValue.ace); // Invalid card

    // Extract rank (high 4 bits) and suit (low 4 bits)
    final rank = value >> 4;
    final suit = value & 0x0F;

    // Convert rank
    CardValue cardValue;
    switch (rank) {
      case 0x02:
        cardValue = CardValue.two;
        break;
      case 0x03:
        cardValue = CardValue.three;
        break;
      case 0x04:
        cardValue = CardValue.four;
        break;
      case 0x05:
        cardValue = CardValue.five;
        break;
      case 0x06:
        cardValue = CardValue.six;
        break;
      case 0x07:
        cardValue = CardValue.seven;
        break;
      case 0x08:
        cardValue = CardValue.eight;
        break;
      case 0x09:
        cardValue = CardValue.nine;
        break;
      case 0x0A:
        cardValue = CardValue.ten;
        break;
      case 0x0B:
        cardValue = CardValue.jack;
        break;
      case 0x0C:
        cardValue = CardValue.queen;
        break;
      case 0x0D:
        cardValue = CardValue.king;
        break;
      case 0x0E:
        cardValue = CardValue.ace;
        break;
      default:
        cardValue = CardValue.ace; // Invalid rank
    }

    // Convert suit
    Suit cardSuit;
    switch (suit) {
      case 0x04:
        cardSuit = Suit.spades;
        break;
      case 0x03:
        cardSuit = Suit.hearts;
        break;
      case 0x02:
        cardSuit = Suit.clubs;
        break;
      case 0x01:
        cardSuit = Suit.diamonds;
        break;
      default:
        cardSuit = Suit.hearts; // Invalid suit
    }

    return PlayingCard(cardSuit, cardValue);
  }

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

    Widget card = Container(
      width: cardWidth,
      height: cardHeight,
      child: PlayingCardView(
        card: _convertToPlayingCard(cardValue),
        showBack: !showFaceUp || cardValue == 0,
        elevation: enableShadows ? 2.0 : 0.0,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(4.0), // Very slight rounding for edges
          side: BorderSide(color: Colors.black12, width: 0.5),
        ),
        style: PlayingCardViewStyle(
          cardBackgroundColor: Colors.white,
        ),
      ),
    );

    return Transform.translate(
      offset: Offset(0, offset),
      child: card,
    );
  }
}
