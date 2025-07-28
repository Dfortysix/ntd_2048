import 'package:flutter/material.dart';
import 'localization_helper.dart';

class FruitGuide extends StatelessWidget {
  const FruitGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 8, bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🍎 ${LocalizationHelper.getLocalizedString(context, 'fruitGuide')}:',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFruitStep(context, '🍒', LocalizationHelper.getLocalizedString(context, 'cherry')),
                _buildArrow(),
                _buildFruitStep(context, '🍓', LocalizationHelper.getLocalizedString(context, 'strawberry')),
                _buildArrow(),
                _buildFruitStep(context, '🍇', LocalizationHelper.getLocalizedString(context, 'grape')),
                _buildArrow(),
                _buildFruitStep(context, '🍊', LocalizationHelper.getLocalizedString(context, 'orange')),
                _buildArrow(),
                _buildFruitStep(context, '🍎', LocalizationHelper.getLocalizedString(context, 'apple')),
                _buildArrow(),
                _buildFruitStep(context, '🍐', LocalizationHelper.getLocalizedString(context, 'pear')),
                _buildArrow(),
                _buildFruitStep(context, '🍑', LocalizationHelper.getLocalizedString(context, 'peach')),
                _buildArrow(),
                _buildFruitStep(context, '🥭', LocalizationHelper.getLocalizedString(context, 'mango')),
                _buildArrow(),
                _buildFruitStep(context, '🍍', LocalizationHelper.getLocalizedString(context, 'pineapple')),
                _buildArrow(),
                _buildFruitStep(context, '🍉', LocalizationHelper.getLocalizedString(context, 'watermelon')),
                _buildArrow(),
                _buildFruitStep(context, '🍈', LocalizationHelper.getLocalizedString(context, 'melon')),
                _buildArrow(),
                _buildFruitStep(context, '🥥', LocalizationHelper.getLocalizedString(context, 'coconut')),
                _buildArrow(),
                _buildFruitStep(context, '🧺', LocalizationHelper.getLocalizedString(context, 'magicBasket'), isSpecial: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFruitStep(BuildContext context, String emoji, String name, {bool isSpecial = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSpecial 
            ? const Color(0xFF673AB7).withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSpecial 
              ? const Color(0xFF673AB7)
              : Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isSpecial 
                  ? const Color(0xFF673AB7)
                  : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: const Icon(
        Icons.arrow_forward,
        size: 16,
        color: Color(0xFF4CAF50),
      ),
    );
  }
} 