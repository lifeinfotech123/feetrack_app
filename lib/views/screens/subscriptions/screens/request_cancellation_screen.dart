import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vlr/controllers/subscription_controller.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';

class RequestCancellationScreen extends StatefulWidget {
  final String subscriptionId;
  const RequestCancellationScreen({super.key, required this.subscriptionId});

  @override
  State<RequestCancellationScreen> createState() => _RequestCancellationScreenState();
}

class _RequestCancellationScreenState extends State<RequestCancellationScreen> {
  final TextEditingController _reasonController = TextEditingController();
  DateTime? _selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Request Cancellation",
          style: Helper(context).textTheme.bodyMedium?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: primaryText1,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Cancellation Reason",
              style: Helper(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Enter reason for cancellation",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: greyText3.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: greyText3.withValues(alpha: 0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: primaryColor),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Leave Date",
              style: Helper(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() {
                    _selectedDate = date;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: greyText3.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedDate == null
                          ? "Select leave date"
                          : DateFormat('dd MMM yyyy').format(_selectedDate!),
                      style: TextStyle(
                        color: _selectedDate == null ? greyText3 : black,
                      ),
                    ),
                    Icon(Icons.calendar_today, color: primaryColor, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            GetBuilder<SubscriptionController>(builder: (controller) {
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () {
                          if (_reasonController.text.isEmpty) {
                            showToast(message: "Please enter a reason");
                            return;
                          }
                          if (_selectedDate == null) {
                            showToast(message: "Please select a leave date");
                            return;
                          }

                          controller
                              .requestCancellation(
                            id: widget.subscriptionId,
                            reason: _reasonController.text,
                            leaveDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          )
                              .then((response) {
                            if (response.isSuccess) {
                              showToast(
                                message: response.message,
                                toastType: ToastType.success,
                              );
                              pop(context);
                            } else {
                              showToast(message: response.message);
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
                      ?  CircularProgressIndicator(color: white)
                      : const Text(
                          "Submit Request",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
