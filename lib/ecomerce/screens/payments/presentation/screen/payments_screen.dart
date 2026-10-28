import 'package:flutter/material.dart';

import '../../../../../hospital/core/constants/colors.dart';
import '../../../../../hospital/core/widgets/animated_widgets.dart';
import '../../../../../hospital/features/bills_invoices/presentation/screen/bills_invoices_screen.dart';

class PaymentsScreen extends StatefulWidget {
  final double amount;
  final String billTitle;

  const PaymentsScreen({
    super.key,
    this.amount = 45.0,
    this.billTitle = 'Dr. Mohamed Saeed Consultation Fee',
  });

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text('Payments & Checkout',
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long, color: colorWhite),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BillsInvoicesScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Summary Card
            ModernCard(
              color: primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Payable Amount',
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text('\$${widget.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: colorWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('For: ${widget.billTitle}',
                      style: const TextStyle(
                          color: colorWhite,
                          fontSize: 13,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const SectionHeader(title: 'Choose Payment Method'),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: wellnessGreen,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      title: const Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: wellnessGreen, size: 28),
                          SizedBox(width: 10),
                          Text('Payment Successful!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amount: \$${widget.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          const Text('Transaction ID: #TXN-9028491823',
                              style: TextStyle(fontSize: 12, color: textMuted)),
                          const SizedBox(height: 12),
                          const Text(
                              'Receipt generated and saved in Bills & Invoices.',
                              style: TextStyle(fontSize: 12)),
                        ],
                      ),
                      actions: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor),
                          onPressed: () {
                            Navigator.pop(ctx);
                            Navigator.pop(context);
                          },
                          child: const Text('Done',
                              style: TextStyle(color: colorWhite)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.payment, color: colorWhite),
                label: Text(
                    'Pay \$${widget.amount.toStringAsFixed(2)} Securely',
                    style: const TextStyle(
                        color: colorWhite,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
