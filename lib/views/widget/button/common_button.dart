
import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class CommonButton extends StatelessWidget {
  final String title;
  final Color titleColor;
  final Color bgColor;
  final VoidCallback? onPressed;

  const CommonButton({
    super.key,
    required this.title,
    this.titleColor = Colors.white,
    this.bgColor = primaryColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: bgColor, // ✅ Use custom background color
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          title, // ✅ Use dynamic title
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: titleColor, // ✅ Use dynamic text color
              ),
        ),
      ),
    );
  }
}
