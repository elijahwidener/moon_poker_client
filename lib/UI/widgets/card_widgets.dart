import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

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
    this.height = 120, // Increased default height
    this.spacing = 8.0, // Wider spacing
    this.enableShadows = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a larger default size
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 2; i++)
          Padding(
            padding: EdgeInsets.only(right: i == 0 ? spacing : 0),
            child: CardWidget(
              cardValue: i < cards.length ? cards[i] : 0,
              faceDown: !showCards,
              height: height,
              enableShadow: enableShadows,
            ),
          ),
      ],
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
    this.height = 120, // Increased default height
    this.spacing = 8.0, // Wider spacing
    this.enableShadows = true,
    this.showAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: EdgeInsets.only(right: i < 4 ? spacing : 0),
            child: CardWidget(
              cardValue: i < cards.length ? cards[i] : 0,
              height: height,
              enableShadow: enableShadows,
            ),
          ),
      ],
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
    this.height = 120, // Increased default height
    this.enableShadow = true,
    this.onTap,
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
    // Calculate width based on standard card aspect ratio (poker cards are 2.5 x 3.5 inches)
    final width = height *
        0.714; // This ratio (2.5/3.5) preserves the proper poker card dimensions

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        child: PlayingCardView(
          card: _convertToPlayingCard(cardValue),
          showBack: faceDown,
          elevation: enableShadow ? 4.0 : 1.0,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(4.0), // Very slight rounding for edges
            side: BorderSide(color: Colors.black12, width: 0.5),
          ),
          style: PlayingCardViewStyle(
            cardBackgroundColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
