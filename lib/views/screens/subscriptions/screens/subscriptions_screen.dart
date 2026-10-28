import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/data/models/subscription_model.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/subscriptions/screens/subscription_detain_screen.dart';
import 'package:vlr/views/screens/subscriptions/screens/request_cancelitions_histiory_screen.dart';

import 'package:vlr/views/base/web_view.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<SubscriptionController>().fetchSubscriptionsList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Subscriptions",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              navigate(
                context: context,
                page: const RequestCancelitionsHistioryScreen(),
              );
            },
            icon: Icon(Icons.history, color: primaryColor),
          ),
        ],
      ),
      body: GetBuilder<SubscriptionController>(builder: (controller) {
        if (controller.isSubscriptionsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.subscriptionsList.isEmpty) {
          return Center(
            child: Text(
              "No Subscriptions Found",
              style: Helper(context).textTheme.bodyMedium,
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchSubscriptionsList(),
          child: ListView.separated(
            padding: AppConstants.screenPadding,
            itemCount: controller.subscriptionsList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final subscription = controller.subscriptionsList[index];
              return SubscriptionListItem(subscription: subscription);
            },
          ),
        );
      }),
    );
  }
}

class SubscriptionListItem extends StatelessWidget {
  final SubscriptionModel subscription;
  const SubscriptionListItem({super.key, required this.subscription});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        navigate(
          context: context,
          page: SubscriptionDetainScreen(subscriptionId: subscription.id ?? ""),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: black.withValues(alpha: 0.04),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomImage(
                        path: subscription.listing?.image ?? "",
                        height: 70,
                        width: 70,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                subscription.listing?.title ?? "",
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Helper(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: blackText1,
                                    ),
                              ),
                            ),
                            _buildStatusChip(subscription.status ?? ""),
                          ],
                        ),
                        const SizedBox(height: 4),

                        Text(

                          subscription.listing?.category ?? "",
                          style: Helper(context).textTheme.bodySmall?.copyWith(
                                color: greyText3,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        if (subscription.room != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            "Room: ${subscription.room?.roomNumber} (${subscription.room?.roomType})",
                            style: Helper(context).textTheme.bodySmall?.copyWith(
                                  color: greyText3,
                                  fontSize: 11,
                                ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 12, color: primaryColor),
                            const SizedBox(width: 4),
                            Text(
                              subscription.startsAt != null
                                  ? DateFormat('dd MMM')
                                      .format(subscription.startsAt!)
                                  : "-",
                              style:
                                  Helper(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                            Text(
                              " to ",
                              style:
                                  Helper(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        color: greyText3,
                                      ),
                            ),
                            Text(
                              subscription.expiresAt != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(subscription.expiresAt!)
                                  : "-",
                              style:
                                  Helper(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: blueLight5.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(24)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.layers_outlined, size: 16, color: greyText3),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${subscription.plan?.name ?? ""} (${subscription.plan?.duration ?? ""})",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                Helper(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: blackText1,
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (subscription.status?.toLowerCase() == 'active')
                    GestureDetector(
                      onTap: () {
                        Get.find<SubscriptionController>().renewSubscription(subscription.id!).then((value) {
                          if (value.isSuccess) {
                            String? paymentLink = value.data['payment_link'];
                            if (paymentLink != null && paymentLink.isNotEmpty) {
                              navigate(
                                context: context,
                                page: CustomWebView(url: paymentLink, title: "Renew Subscription"),
                              );
                            }
                          } else {
                            showToast(message: value.message, toastType: ToastType.error);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          "Renew",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Icon(Icons.arrow_forward_ios, size: 14, color: primaryColor),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'active':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'expired':
        color = Colors.grey;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
