import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/subscriptions/screens/subscriptions_screen.dart';

import '../../../../services/theme.dart';

class RequestCancelitionsHistioryScreen extends StatefulWidget {
  const RequestCancelitionsHistioryScreen({super.key});

  @override
  State<RequestCancelitionsHistioryScreen> createState() =>
      _RequestCancelitionsHistioryScreenState();
}

class _RequestCancelitionsHistioryScreenState
    extends State<RequestCancelitionsHistioryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<SubscriptionController>().fetchCancellationHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cancellation History",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
              ),
        ),
      ),
      body: GetBuilder<SubscriptionController>(builder: (controller) {
        if (controller.isCancellationHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.cancellationHistoryList.isEmpty) {
          return Center(
            child: Text(
              "No Cancellation History Found",
              style: Helper(context).textTheme.bodyMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchCancellationHistory(),
          child: ListView.separated(
            padding: AppConstants.screenPadding,
            itemCount: controller.cancellationHistoryList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final subscription = controller.cancellationHistoryList[index];
              return SubscriptionListItem(subscription: subscription);
            },
          ),
        );
      }),
    );
  }
}
