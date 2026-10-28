import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/base/custom_image.dart';
import 'package:vlr/views/screens/subscriptions/screens/request_cancellation_screen.dart';

import 'package:vlr/views/base/web_view.dart';

class SubscriptionDetainScreen extends StatefulWidget {
  final String subscriptionId;
  const SubscriptionDetainScreen({super.key, required this.subscriptionId});

  @override
  State<SubscriptionDetainScreen> createState() => _SubscriptionDetainScreenState();
}

class _SubscriptionDetainScreenState extends State<SubscriptionDetainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.find<SubscriptionController>()
          .fetchSubscriptionDetail(id: widget.subscriptionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Subscription Details",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
              ),
        ),
      ),
      body: GetBuilder<SubscriptionController>(builder: (controller) {
        if (controller.isSubscriptionDetailLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final subscription = controller.selectedSubscriptionDetail;
        if (subscription == null) {
          return const Center(child: Text("Subscription not found"));
        }

        return SingleChildScrollView(
          padding: AppConstants.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Listing Header
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: CustomImage(
                        path: subscription.listing?.image ?? "",
                        height: 80,
                        width: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            subscription.listing?.title ?? "",
                            style: Helper(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subscription.listing?.category ?? "",
                            style: Helper(context).textTheme.bodySmall?.copyWith(
                                  color: greyText3,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined,
                                  size: 14, color: greyText3),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  subscription.listing?.address ?? "",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Helper(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: greyText3,
                                        fontSize: 12,
                                      ),
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
              const SizedBox(height: 24),

              _buildSectionTitle("Subscription Info"),
              _buildDetailCard([
                _buildDetailRow("Status", subscription.status?.toUpperCase() ?? "",
                    isStatus: true),
                _buildDetailRow("Plan", subscription.plan?.name ?? ""),
                _buildDetailRow("Duration", subscription.plan?.duration ?? ""),
                _buildDetailRow("Start Date",
                    DateFormat('dd MMM yyyy').format(subscription.startsAt!)),
                _buildDetailRow("Expiry Date",
                    DateFormat('dd MMM yyyy').format(subscription.expiresAt!)),
                if (subscription.room != null)
                  _buildDetailRow("Room",
                      "${subscription.room?.roomNumber} (${subscription.room?.roomType})"),
              ]),
              const SizedBox(height: 24),

              if (subscription.invoices != null && subscription.invoices!.isNotEmpty) ...[
                _buildSectionTitle("Invoices"),
                ...subscription.invoices!.map((invoice) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: greyText3.withValues(alpha: 0.1)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  invoice.invoiceNumber ?? "",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(invoice.dueDate!),
                                  style: TextStyle(color: greyText3, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (invoice.id != null) {
                                Get.find<SubscriptionController>().downloadInvoice(
                                  invoice.id!,
                                  invoice.invoiceNumber ?? "Invoice",
                                );
                              } else {
                                showToast(message: "Invoice ID not available");
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.file_download_outlined, color: Colors.blue, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            "₹${invoice.total}",
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 24),
              ],

              if (subscription.status?.toLowerCase() == 'active' &&
                  subscription.leaveStatus != 'requested')
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: controller.isLoading ? null : () {
                          controller.renewSubscription(subscription.id!).then((value) {
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: controller.isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text(
                              "Renew Subscription",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          navigate(
                            context: context,
                            page: RequestCancellationScreen(
                                subscriptionId: subscription.id!),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade50,
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(color: Colors.red.shade200),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Request Cancellation",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              if (subscription.leaveStatus == 'requested')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                  ),
                  child: const Center(
                    child: Text(
                      "Cancellation Requested",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Helper(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(children: children),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: greyText3, fontWeight: FontWeight.w500),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (value.toLowerCase() == 'active'
                        ? Colors.green
                        : Colors.orange)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: value.toLowerCase() == 'active'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
        ],
      ),
    );
  }
}
