import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/common_button.dart';

class GymSelectPackageButtonSection extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final bool isLoading;

  const GymSelectPackageButtonSection({
    super.key,
    required this.title,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 10,
            color: black.withValues(alpha: 0.05),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: CustomButton(
            height: 54,
            radius: 100,
            isLoading: isLoading,
            color: const Color(0xFF002060),
            borderColor: const Color(0xFF002060),
            onTap: onTap,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: Helper(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: white,
                      ),
                ),
                sizedBoxWidth(width: 8),
                 Icon(
                  Icons.arrow_forward_ios,
                  color: white,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
