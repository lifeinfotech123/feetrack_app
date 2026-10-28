import 'package:flutter/material.dart';
import 'package:vlr/data/models/notification_models/notification_option_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class NotifOptionWidget extends StatelessWidget {
  final NotificationOptionModel notificationOptionModel;

  const NotifOptionWidget({
    super.key,
    required this.notificationOptionModel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: notificationOptionModel.isSelect ? 1.0 : 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          color: notificationOptionModel.isSelect ? primaryText1 : greyLight9,
          boxShadow: notificationOptionModel.isSelect
              ? [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: black.withValues(alpha: 0.10),
                  )
                ]
              : [],
        ),
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          style: notificationOptionModel.isSelect
              ? Helper(context).textTheme.titleMedium!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: white,
                  )
              : Helper(context).textTheme.titleSmall!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: greyText2,
                  ),
          child: Text(
            notificationOptionModel.title,
          ),
        ),
      ),
    );
  }
}
