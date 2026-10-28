import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vlr/services/theme.dart';

class AddMoneyAmountPresetCard extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const AddMoneyAmountPresetCard({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.08) : white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            width: 1,
            color:
                isSelected ? primaryColor.withValues(alpha: 0.35) : greyLight4,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: transactionDetailsPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
