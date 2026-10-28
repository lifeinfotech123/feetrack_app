import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/controllers/room_controller.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';
import 'package:vlr/views/screens/room_section/room_bottom_nav_bar/my_room_booking_screen.dart';
import 'package:vlr/views/screens/room_section/room_profile_dashboard/pg_invoice_detail_pdf_screen.dart';

class PgProfileSheets {
  // ══════════════════════════════════════════════════════════════════
  // 1. WALLET SHEET
  // ══════════════════════════════════════════════════════════════════
  static void showWalletSheet(BuildContext context, RoomController controller) {
    controller.fetchPgCustomerWallet();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.78,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "PG Smart Wallet",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    final wallet = ctrl.customerWalletData;
                    if (ctrl.isCustomerWalletLoading && wallet == null) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final transactions = wallet?.transactions ?? [];

                    if (wallet == null && ctrl.customerWalletError != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.error_outline_rounded,
                                size: 42,
                                color: Color(0xFFDC2626),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                ctrl.customerWalletError!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFF475569),
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: ctrl.fetchPgCustomerWallet,
                                child: const Text("Retry"),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Wallet Balance Banner
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF002060), Color(0xFF1E3A8A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Available Balance",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                wallet?.formattedBalance ?? "—",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "Total Transactions: ${wallet?.totalTransactions ?? 0}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF002060),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                ),
                                onPressed: () {
                                  Navigator.pop(sheetContext);
                                  showWalletRechargeDialog(context, controller);
                                },
                                icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 16),
                                label: const Text(
                                  "Recharge Wallet",
                                  style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Transaction History",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (transactions.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 36),
                            alignment: Alignment.center,
                            child: Column(
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 40, color: Colors.grey.shade400),
                                const SizedBox(height: 8),
                                const Text(
                                  "No wallet transactions recorded yet",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: transactions.length,
                            separatorBuilder: (_, __) => const Divider(
                                height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final tx = transactions[index];
                              final isCredit =
                                  (tx.type ?? "").toLowerCase() == 'credit';

                              return ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: (isCredit
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626))
                                        .withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    isCredit
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    size: 18,
                                    color: isCredit
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                                title: Text(
                                  tx.description ??
                                      (isCredit
                                          ? "Wallet Recharge"
                                          : "Payment"),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                subtitle: Text(
                                  tx.formattedDate ?? tx.createdAt ?? "",
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                trailing: Text(
                                  tx.formattedAmount ??
                                      (tx.amount == null
                                          ? "—"
                                          : "₹${tx.amount}"),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: isCredit
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFFDC2626),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 2. WALLET RECHARGE DIALOG
  // ══════════════════════════════════════════════════════════════════
  static void showWalletRechargeDialog(
    BuildContext context,
    RoomController controller,
  ) {
    final amountController = TextEditingController(text: "1000");
    final presetAmounts = [500, 1000, 2000, 5000];
    Razorpay? razorpay;
    num? _rechargeAmount;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            void initRazorpay() {
              razorpay ??= Razorpay();
              razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, (response) async {
                final amt = _rechargeAmount;
                if (amt != null && amt > 0) {
                  showToast(
                      message: "Payment successful. Adding amount to wallet...",
                      toastType: ToastType.success);
                  final res = await controller.rechargePgCustomerWallet(amt);
                  if (res.isSuccess) {
                    await controller.fetchPgCustomerWallet();
                    await controller.fetchPgCustomerDashboard();
                    showToast(
                        message: res.message.isNotEmpty
                            ? res.message
                            : "Wallet recharged successfully",
                        toastType: ToastType.success);
                  } else {
                    showToast(
                        message: res.message.isNotEmpty
                            ? res.message
                            : "Wallet recharge failed",
                        toastType: ToastType.error);
                    await controller.fetchPgCustomerWallet();
                    await controller.fetchPgCustomerDashboard();
                  }
                } else {
                  showToast(
                      message: "Payment successful", toastType: ToastType.success);
                  await controller.fetchPgCustomerWallet();
                  await controller.fetchPgCustomerDashboard();
                }
                if (sheetContext.mounted) Navigator.pop(sheetContext);
              });
              razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, (response) {
                showToast(
                    message: "Payment failed or cancelled. Amount not added to wallet.",
                    toastType: ToastType.error);
              });
              razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, (response) {
                showToast(message: "External wallet selected", toastType: ToastType.success);
              });
            }

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.account_balance_wallet_rounded,
                                color: Color(0xFF002060), size: 22),
                            SizedBox(width: 8),
                            Text(
                              "Recharge PG Wallet",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Add balance to your wallet for instant room rent payments and PG service dues.",
                      style:
                          TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Enter Amount (₹)",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF002060),
                      ),
                      decoration: InputDecoration(
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          child: Text(
                            "₹",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ),
                        prefixIconConstraints:
                            const BoxConstraints(minWidth: 0, minHeight: 0),
                        hintText: "1000",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide:
                              const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                              color: Color(0xFF002060), width: 1.8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: presetAmounts.map((amt) {
                        return ActionChip(
                          label: Text("+₹$amt"),
                          backgroundColor: const Color(0xFFF1F5F9),
                          labelStyle: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF002060),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          onPressed: () {
                            setModalState(() {
                              amountController.text = amt.toString();
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    GetBuilder<RoomController>(
                      builder: (ctrl) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002060),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: ctrl.isRechargingWallet
                                ? null
                                : () async {
                                    final amt = num.tryParse(
                                            amountController.text.trim()) ??
                                        0;
                                    if (amt <= 0) {
                                      showToast(
                                        message: "Please enter a valid amount",
                                        toastType: ToastType.error,
                                      );
                                      return;
                                    }
                                    _rechargeAmount = amt;
                                    initRazorpay();
                                    final amountPaise =
                                        ((amt.toDouble()) * 100).toInt();
                                    final options = {
                                      'key': 'rzp_test_TWIAoYszpcVthe',
                                      'amount':
                                          amountPaise > 0 ? amountPaise : 100000,
                                      'name': 'PG Wallet Recharge',
                                      'description': 'Wallet Topup',
                                      'prefill': {},
                                      'theme': {'color': '#002060'},
                                    };
                                    try {
                                      razorpay?.open(options);
                                    } catch (e) {
                                      showToast(
                                          message: "Failed to open payment",
                                          toastType: ToastType.error);
                                    }
                                  },
                            child: ctrl.isRechargingWallet
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Proceed to Recharge",
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      razorpay?.clear();
    });
  }

  // ══════════════════════════════════════════════════════════════════
  // 3. PROFILE DETAILS SHEET
  // ══════════════════════════════════════════════════════════════════
  static void showProfileSheet(
      BuildContext context, RoomController controller) {
    controller.fetchPgCustomerProfile();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Personal Profile Details",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            showEditProfileDialog(context, controller);
                          },
                          icon: const Icon(Icons.edit_outlined,
                              size: 15, color: Color(0xFF002060)),
                          label: const Text(
                            "Edit",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF002060),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    final profile = ctrl.customerProfileData;
                    final customer = ctrl.customerDashboardData?.customer;

                    final name = profile?.name ?? customer?.name ?? "—";
                    final email = profile?.email ?? customer?.email ?? "N/A";
                    final phone = profile?.phone ?? customer?.phone ?? "N/A";
                    final gender =
                        profile?.gender ?? customer?.gender ?? "Not Specified";
                    final dob = profile?.dateOfBirth ?? "Not Specified";
                    final bloodGroup = profile?.bloodGroup ?? "Not Specified";
                    final address =
                        profile?.address ?? customer?.address ?? "Not Provided";
                    final city =
                        profile?.city ?? customer?.city ?? "Not Provided";
                    final state = profile?.state ?? "Not Provided";
                    final country = profile?.country ?? "—";
                    final status = profile?.status;

                    return ListView(
                      padding: const EdgeInsets.all(18),
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 70,
                                height: 70,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF002060),
                                      Color(0xFF1E3A8A)
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: (profile?.initials ??
                                            customer?.initials ??
                                            "")
                                        .isNotEmpty
                                    ? Text(
                                        (profile?.initials ??
                                                customer?.initials ??
                                                "")
                                            .toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.person_outline_rounded,
                                        color: Colors.white,
                                        size: 32,
                                      ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 4),
                              if (status?.isNotEmpty == true)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF16A34A)
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status!.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF16A34A),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildProfileInfoRow(
                            "Mobile Phone", phone, Icons.phone_rounded),
                        _buildProfileInfoRow(
                            "Email Address", email, Icons.email_outlined),
                        _buildProfileInfoRow(
                            "Gender", gender, Icons.person_outline_rounded),
                        _buildProfileInfoRow(
                            "Date of Birth", dob, Icons.cake_outlined),
                        _buildProfileInfoRow("Blood Group", bloodGroup,
                            Icons.bloodtype_outlined),
                        _buildProfileInfoRow(
                            "Address", address, Icons.home_outlined),
                        _buildProfileInfoRow("City / State", "$city, $state",
                            Icons.location_city_rounded),
                        _buildProfileInfoRow(
                            "Country", country, Icons.public_rounded),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildProfileInfoRow(
      String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF002060).withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF002060)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 4. PROFILE EDIT DIALOG
  // ══════════════════════════════════════════════════════════════════
  static void showEditProfileDialog(
    BuildContext context,
    RoomController controller,
  ) {
    final profile = controller.customerProfileData;
    String selectedGender = profile?.gender?.toLowerCase() == 'female'
        ? 'female'
        : (profile?.gender?.toLowerCase() == 'other' ? 'other' : 'male');
    final addressCtrl = TextEditingController(text: profile?.address ?? "");
    final cityCtrl = TextEditingController(text: profile?.city ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetCtx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Update Profile",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Gender",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: ['male', 'female', 'other'].map((g) {
                        final isSel = selectedGender == g;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(g.capitalizeFirst ?? g),
                            selected: isSel,
                            selectedColor: const Color(0xFF002060),
                            backgroundColor: const Color(0xFFF1F5F9),
                            labelStyle: TextStyle(
                              color: isSel
                                  ? Colors.white
                                  : const Color(0xFF334155),
                              fontWeight: FontWeight.w700,
                            ),
                            onSelected: (val) {
                              if (val) {
                                setModalState(() {
                                  selectedGender = g;
                                });
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "Address",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter full address",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      "City",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: cityCtrl,
                      decoration: InputDecoration(
                        hintText: "Enter city",
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GetBuilder<RoomController>(
                      builder: (ctrl) {
                        return SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002060),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: ctrl.isUpdatingProfile
                                ? null
                                : () async {
                                    final Map<String, dynamic> body = {
                                      'gender': selectedGender,
                                    };
                                    if (addressCtrl.text.trim().isNotEmpty) {
                                      body['address'] = addressCtrl.text.trim();
                                    }
                                    if (cityCtrl.text.trim().isNotEmpty) {
                                      body['city'] = cityCtrl.text.trim();
                                    }
                                    final res = await ctrl
                                        .updatePgCustomerProfile(body);
                                    if (res.isSuccess) {
                                      if (sheetCtx.mounted) {
                                        Navigator.pop(sheetCtx);
                                      }
                                    }
                                  },
                            child: ctrl.isUpdatingProfile
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Save Profile Changes",
                                    style: TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 5. BOOKING DETAIL SHEET
  // ══════════════════════════════════════════════════════════════════
  static void showBookingDetailSheet(
    BuildContext context,
    PgCustomerBookingItem booking,
    RoomController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.75,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Booking ${booking.shortId ?? ''}",
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    // Property Name
                    Text(
                      booking.property?.title ?? "PG Room",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${booking.property?.address ?? ''}, ${booking.property?.city ?? ''}",
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Key Specs
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              "Status",
                              booking.statusLabel ??
                                  booking.status?.toUpperCase() ??
                                  ""),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Payment Status",
                              booking.paymentStatusBadge?.isNotEmpty == true
                                  ? booking.paymentStatusBadge!
                                  : (booking.paymentStatus ?? "")
                                      .toUpperCase()),
                          const Divider(height: 16),
                          _buildDetailRow("Occupancy",
                              booking.occupancyTypeDisplay ?? "Per Bed"),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Beds Booked", booking.bedsDisplay ?? "1 Bed"),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Total Rent",
                              booking.formattedAmount ??
                                  "₹${booking.finalAmount ?? 0}"),
                          if (booking.invoice?['invoice_number'] != null) ...[
                            const Divider(height: 16),
                            _buildDetailRow("Invoice Number",
                                booking.invoice!['invoice_number'].toString()),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (booking.actions?['can_pay'] == true) ...[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF16A34A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          navigate(
                            context: context,
                            page: const MyRoomBookingScreen(),
                          );
                        },
                        child: const Text(
                          "Pay with Razorpay",
                          style: TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    if (booking.invoice != null) ...[
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002060),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          final invId = booking.invoice!['id']?.toString() ??
                              booking.id ??
                              "";
                          Navigator.of(context, rootNavigator: true).push(
                            MaterialPageRoute(
                              builder: (_) => PgInvoiceDetailPdfScreen(
                                invoiceId: invId,
                              ),
                            ),
                          );
                        },
                        icon:
                            const Icon(Icons.picture_as_pdf_rounded, size: 18),
                        label: const Text(
                          "View Official Tax Invoice",
                          style: TextStyle(
                              fontSize: 14.5, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 6. INVOICES SUMMARY SHEET
  // ══════════════════════════════════════════════════════════════════
  static void showInvoicesSheet(
      BuildContext context, RoomController controller) {
    controller.fetchPgCustomerInvoices();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.78,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Invoices & Rent Receipts",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    final invoices = ctrl.customerInvoicesList;
                    if (ctrl.isCustomerInvoicesLoading && invoices.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (invoices.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            const Text(
                              "No invoices found",
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: invoices.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final inv = invoices[index];
                        final isPaid =
                            (inv.status ?? "").toLowerCase() == 'paid';

                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    inv.invoiceNumber ?? "Invoice",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF002060),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      inv.statusLabel ??
                                          (isPaid ? "PAID" : "SENT"),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isPaid
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                inv.property?.title ?? "Room Booking",
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    inv.formattedDate ?? inv.dueDate ?? "",
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                  Text(
                                    inv.formattedTotal ?? "₹${inv.total ?? 0}",
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF002060),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 7. SUBSCRIPTIONS SHEET & DETAILS
  // ══════════════════════════════════════════════════════════════════
  static void showSubscriptionsSheet(
      BuildContext context, RoomController controller) {
    controller.fetchPgCustomerSubscriptions();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.78,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "My PG Subscriptions & Plans",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: GetBuilder<RoomController>(
                  builder: (ctrl) {
                    final subscriptions = ctrl.customerSubscriptionsList;
                    if (ctrl.isCustomerSubscriptionsLoading &&
                        subscriptions.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (subscriptions.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.card_membership_rounded,
                                size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 10),
                            const Text(
                              "No active PG subscriptions found",
                              style: TextStyle(
                                  fontSize: 14, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: subscriptions.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final sub = subscriptions[index];
                        final isActive =
                            (sub.status ?? "").toLowerCase() == 'active';

                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.02),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    sub.subscriptionNumber ?? "Plan",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF002060),
                                      fontSize: 14,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      sub.statusLabel ??
                                          (isActive ? "ACTIVE" : "EXPIRED"),
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        color: isActive
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFD97706),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                sub.property?.title ?? "PG Accommodation",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                sub.package?['name']?.toString() ??
                                    "Standard Plan",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const Divider(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Starts",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                      Text(
                                        sub.formattedStartsAt ??
                                            sub.startsAt ??
                                            "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        "Expires",
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF94A3B8)),
                                      ),
                                      Text(
                                        sub.formattedExpiresAt ??
                                            sub.expiresAt ??
                                            "",
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF334155),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void showSubscriptionDetailSheet(
      BuildContext context, PgCustomerSubscriptionItem sub) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          height: MediaQuery.of(sheetContext).size.height * 0.70,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      sub.subscriptionNumber ?? "Plan Details",
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(18),
                  children: [
                    Text(
                      sub.property?.title ?? "PG Room",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      sub.property?.address ?? '',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow("Status", sub.statusLabel ?? ""),
                          const Divider(height: 16),
                          _buildDetailRow("Package",
                              sub.package?['name']?.toString() ?? "Standard"),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Starts At", sub.formattedStartsAt ?? ""),
                          const Divider(height: 16),
                          _buildDetailRow(
                              "Expires At", sub.formattedExpiresAt ?? ""),
                          const Divider(height: 16),
                          _buildDetailRow("Days Remaining",
                              "${sub.daysRemaining ?? 0} Days"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // 8. LOGOUT DIALOG
  // ══════════════════════════════════════════════════════════════════
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          "Confirm Log Out",
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
        ),
        content: const Text(
          "Are you sure you want to log out of your account?",
          style: TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogCtx);
              if (Get.isRegistered<AuthController>()) {
                await Get.find<AuthController>().logout();
              }
              if (context.mounted) {
                navigate(
                    context: context,
                    isRemoveUntil: true,
                    page: const LoginScreen());
              }
              AppRouter.goToLogin();
            },
            child: const Text("Log Out"),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
