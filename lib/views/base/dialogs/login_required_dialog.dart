import 'package:flutter/material.dart';
import '../../../services/app_router.dart';
import '../../../services/constants.dart';
import '../../../services/theme.dart';
import '../../screens/auth_screens/login/login_screen.dart';
import '../common_button.dart';

Future<bool?> showLoginRequiredDialog({
  required BuildContext context,
  String title = "Login Required",
  String message = "Please login to your account first before proceeding with the booking.",
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return LoginRequiredDialog(
        title: title,
        message: message,
      );
    },
  );
}

class LoginRequiredDialog extends StatelessWidget {
  final String title;
  final String message;

  const LoginRequiredDialog({
    super.key,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                color: primaryColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13.0,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    radius: 8,
                    type: ButtonType.secondary,
                    title: 'Cancel',
                    height: 44,
                    onTap: () {
                      Navigator.pop(context, false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    color: primaryColor,
                    radius: 8,
                    type: ButtonType.primary,
                    title: 'Login Now',
                    height: 44,
                    onTap: () {
                      Navigator.pop(context, true);
                      navigate(
                        context: context,
                        page: const LoginScreen(),
                      );
                      AppRouter.goToLogin();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
