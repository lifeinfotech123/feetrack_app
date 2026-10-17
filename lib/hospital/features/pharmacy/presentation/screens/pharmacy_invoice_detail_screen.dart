import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/hospital/core/constants/colors.dart';

import '../../data/model/pharmacy_invoice_model.dart';
import '../../logics/pharmacy_controller.dart';
import 'pharmacy_screen.dart';

class PharmacyInvoiceDetailScreen extends StatefulWidget {
  final dynamic billId;

  const PharmacyInvoiceDetailScreen({
    super.key,
    required this.billId,
  });

  @override
  State<PharmacyInvoiceDetailScreen> createState() => _PharmacyInvoiceDetailScreenState();
}

class _PharmacyInvoiceDetailScreenState extends State<PharmacyInvoiceDetailScreen> {
  late final PharmacyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<PharmacyController>()
        ? Get.find<PharmacyController>()
        : Get.put(PharmacyController());

    controller.fetchInvoice(widget.billId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: pharmacyTeal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: colorWhite),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Pharmacy Invoice',
          style: TextStyle(
            color: colorWhite,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: colorWhite),
            tooltip: 'Share Invoice',
            onPressed: () {
              Get.snackbar('Invoice', 'Invoice details copied/ready to print',
                  snackPosition: SnackPosition.BOTTOM);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: pharmacyTeal,
        onRefresh: () async {
          await controller.fetchInvoice(widget.billId);
        },
        child: Obx(() {
          if (controller.isInvoiceLoading.value && controller.currentInvoice.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: pharmacyTeal),
            );
          }

          final invoice = controller.currentInvoice.value;

          if (invoice == null) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_outlined, size: 64, color: colorGrey),
                      SizedBox(height: 12),
                      Text(
                        'Invoice Not Found',
                        style: TextStyle(color: textDark, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Please try refreshing or check the bill ID.',
                        style: TextStyle(color: textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hospital Brand Header
                _buildHospitalHeader(invoice),

                const SizedBox(height: 16),

                // Invoice Bill Info
                _buildInvoiceInfoCard(invoice),

                const SizedBox(height: 16),

                // Customer Details
                _buildCustomerCard(invoice),

                const SizedBox(height: 16),

                // Items List
                _buildItemsTable(invoice.items),

                const SizedBox(height: 16),

                // Amount Summary
                _buildPaymentSummary(invoice),

                const SizedBox(height: 24),

                // Back Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Get.offAll(() => const PharmacyScreen());
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pharmacyTeal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'BACK',
                      style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHospitalHeader(PharmacyInvoiceModel invoice) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pharmacyTealBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: pharmacyTeal.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: colorWhite,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_hospital_rounded, color: pharmacyTeal, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.hospital?.name ?? 'Hospital Pharmacy',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: pharmacyTeal,
                  ),
                ),
                if (invoice.hospital?.domain != null)
                  Text(
                    'Domain: ${invoice.hospital!.domain!}',
                    style: const TextStyle(fontSize: 11, color: textMuted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceInfoCard(PharmacyInvoiceModel invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Invoice Details',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invoice.orderStatus?.toUpperCase() ?? 'CONFIRMED',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          _buildRow('Bill No:', invoice.billNo ?? 'N/A'),
          if (invoice.groupOrderNo != null) _buildRow('Group Order:', invoice.groupOrderNo!),
          if (invoice.billDate != null) _buildRow('Bill Date:', invoice.billDate!),
          if (invoice.billId != null) _buildRow('Bill ID:', '#${invoice.billId!}'),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(PharmacyInvoiceModel invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Customer & Delivery Information',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
          ),
          const Divider(height: 20),
          _buildRow('Customer Name:', invoice.customerName ?? 'N/A'),
          _buildRow('Phone Number:', invoice.customerPhone ?? 'N/A'),
          if (invoice.shippingAddress != null) _buildRow('Shipping Address:', invoice.shippingAddress!),
        ],
      ),
    );
  }

  Widget _buildItemsTable(List<InvoiceMedicineItem> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medicines Purchased',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
          ),
          const SizedBox(height: 12),
          if (items.isEmpty)
            const Text('No item details available', style: TextStyle(color: textMuted, fontSize: 12))
          else
            ...items.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: borderGrey),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.medicineName ?? 'Medicine',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
                          ),
                          if (item.batchNo != null)
                            Text(
                              'Batch: ${item.batchNo!}',
                              style: const TextStyle(fontSize: 10, color: textMuted),
                            ),
                          Text(
                            'Qty: ${item.quantity ?? 1}  •  Price: ₹${item.salePrice ?? 0}  •  Tax: ${item.tax ?? 0}%',
                            style: const TextStyle(fontSize: 11, color: textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '₹${item.amount ?? 0}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: pharmacyTeal),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPaymentSummary(PharmacyInvoiceModel invoice) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Breakdown',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
          ),
          const Divider(height: 20),
          _buildRow('Items Total:', '₹${invoice.totalAmount ?? 0}'),
          _buildRow('Tax Amount:', '₹${invoice.tax ?? 0}'),
          _buildRow('Delivery Fee:', invoice.deliveryFee == 0 ? 'FREE' : '₹${invoice.deliveryFee ?? 0}'),
          _buildRow('Payment Mode:', invoice.paymentMode ?? 'Razorpay'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Amount Paid:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
              Text(
                '₹${invoice.netAmount ?? invoice.paymentAmount ?? 0}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: pharmacyTeal),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: textMuted)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textDark),
            ),
          ),
        ],
      ),
    );
  }
}
