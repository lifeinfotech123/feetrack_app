import 'package:flutter/material.dart';

import '../../../services/theme.dart';
import '../common_button.dart';

showLogoutDialogue({required BuildContext context}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return const LogoutDialog();
    },
  );
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 24,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 70,
              width: 70,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.redAccent,
                  )),
              child: const Icon(Icons.logout, color: Colors.redAccent),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Oh no! You're leaving...\nAre you sure?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(
              height: 14,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomButton(
                radius: 6,
                type: ButtonType.secondary,
                title: 'No',
                height: 46,
                onTap: () {
                  Navigator.pop(context, false);
                },
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomButton(
                color: primaryColor,
                radius: 6,
                type: ButtonType.primary,
                title: 'Yes, Log Me Out',
                height: 46,
                onTap: () {
                  Navigator.pop(context, true);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
