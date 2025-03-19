import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A playing card widget that uses open-source SVG card assets
class SvgCard extends StatelessWidget {
  /// The card value (8-bit integer where high 4 bits are rank, low 4 bits are suit)
  final int cardValue;

  /// Whether the card should be shown face down
  final bool faceDown;

  /// Card width
  final double width;

  /// Card height
  final double height;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Constructs a card with the given value and display properties
  const SvgCard({
    Key? key,
    required this.cardValue,
    this.faceDown = false,
    this.width = 70,
    this.height = 100,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        child:
            faceDown || cardValue == 0 ? _buildCardBack() : _buildCardFront(),
      ),
    );
  }

  /// Builds the face of the card using SVG asset
  Widget _buildCardFront() {
    // Get the SVG asset path for this card
    final String assetPath = _getCardAssetPath();

    // Return the SVG asset
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  /// Builds the back of the card using SVG asset
  Widget _buildCardBack() {
    return SvgPicture.asset(
      'assets/cards/back.svg',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  /// Gets the appropriate SVG asset path for the card value
  String _getCardAssetPath() {
    // Invalid card check
    if (cardValue == 0) {
      return 'assets/cards/2B.svg';
    }

    // Extract rank and suit
    final int rank = cardValue >> 4;
    final int suit = cardValue & 0x0F;

    // Convert rank to SVG naming convention (2-10, , j, q, k, a)
    String rankStr;
    switch (rank) {
      case 0x02:
        rankStr = '2';
        break;
      case 0x03:
        rankStr = '3';
        break;
      case 0x04:
        rankStr = '4';
        break;
      case 0x05:
        rankStr = '5';
        break;
      case 0x06:
        rankStr = '6';
        break;
      case 0x07:
        rankStr = '7';
        break;
      case 0x08:
        rankStr = '8';
        break;
      case 0x09:
        rankStr = '9';
        break;
      case 0x0A:
        rankStr = 'T';
        break;
      case 0x0B:
        rankStr = 'J';
        break;
      case 0x0C:
        rankStr = 'Q';
        break;
      case 0x0D:
        rankStr = 'K';
        break;
      case 0x0E:
        rankStr = 'A';
        break;
      default:
        rankStr = '1'; // Default to cardback
    }

    // Convert suit to SVG naming convention (s, h, c, d)
    String suitStr;
    switch (suit) {
      case 0x04:
        suitStr = 'S';
        break;
      case 0x03:
        suitStr = 'H';
        break;
      case 0x02:
        suitStr = 'C';
        break;
      case 0x01:
        suitStr = 'D';
        break;
      default:
        suitStr = 'B'; // Default to cardback
    }

    // Return the path in the format: assets/cards/{rank}{suit}.svg
    return 'assets/cards/$rankStr$suitStr.svg';
  }
}
