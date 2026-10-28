import 'package:flutter/material.dart';

import '../common_button.dart';

showDeleteDialogue ({required BuildContext context}) async {
  return await showDialog(
    context: context,
    builder: (context) {
      return const DeleteDialog();
    },
  );
}

class DeleteDialog extends StatelessWidget {
  const DeleteDialog({super.key});

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
              child: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Are you sure you want to delete\nyour account?",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              "Remember, you can recover it if you log in within 48 hours.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium!.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(
              height: 14,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: CustomButton(
                fontSize: 14,
                radius: 6,
                type: ButtonType.secondary,
                title: 'Not Now',
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
                fontSize: 14,
                color: Colors.redAccent,
                radius: 6,
                type: ButtonType.primary,
                title: 'Yes, Delete Account',
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
