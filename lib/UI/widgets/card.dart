import 'package:flutter/material.dart';
import 'package:playing_cards/playing_cards.dart';

class CardWidget extends StatelessWidget {
  final int cardValue; // 8-bit integer from game core
  final bool faceDown;
  final double height;
  final bool enabled;
  final VoidCallback? onTap;

  const CardWidget({
    super.key,
    required this.cardValue,
    this.faceDown = false,
    this.height = 80,
    this.enabled = true,
    this.onTap,
  });

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
    return SizedBox(
      height: height,
      child: AspectRatio(
        aspectRatio: 0.7,
        child: GestureDetector(
          onTap: enabled ? onTap : null,
          child: faceDown
              ? const FaceDownCard()
              : PlayingCardView(
                  card: _convertToPlayingCard(cardValue),
                  showBack: faceDown,
                  elevation: enabled ? 4.0 : 1.0,
                ),
        ),
      ),
    );
  }
}

// Convenience widget for hole cards
class HoleCards extends StatelessWidget {
  final List<int> cards;
  final bool showCards;
  final double height;

  const HoleCards({
    super.key,
    required this.cards,
    this.showCards = false,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 2; i++)
          Padding(
            padding: EdgeInsets.only(right: i == 0 ? 4.0 : 0),
            child: CardWidget(
              cardValue: i < cards.length ? cards[i] : 0,
              faceDown: !showCards,
              height: height,
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

  const CommunityCards({
    super.key,
    required this.cards,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < 5; i++)
          Padding(
            padding: EdgeInsets.only(right: i < 4 ? 4.0 : 0),
            child: CardWidget(
              cardValue: i < cards.length ? cards[i] : 0,
              height: height,
            ),
          ),
      ],
    );
  }
}

// Face down card implementation
class FaceDownCard extends StatelessWidget {
  const FaceDownCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        image: const DecorationImage(
          image: AssetImage('assets/card_back.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
