import 'package:flutter/material.dart';

class PgProfileOptionsCard extends StatelessWidget {
  final VoidCallback onBookingsTap;
  final VoidCallback onAttendanceTap;
  final VoidCallback onVisitsTap;
  final VoidCallback onSavedListingsTap;
  final VoidCallback onPaymentHistoryTap;
  final VoidCallback onInvoicesTap;
  final VoidCallback onSubscriptionsTap;
  final VoidCallback onWalletTap;
  final VoidCallback onProfileTap;
  final VoidCallback onSupportTap;
  final VoidCallback onLogoutTap;

  const PgProfileOptionsCard({
    super.key,
    required this.onBookingsTap,
    required this.onAttendanceTap,
    required this.onVisitsTap,
    required this.onSavedListingsTap,
    required this.onPaymentHistoryTap,
    required this.onInvoicesTap,
    required this.onSubscriptionsTap,
    required this.onWalletTap,
    required this.onProfileTap,
    required this.onSupportTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          PgProfileOptionTile(
            icon: Icons.receipt_long_rounded,
            title: "My Room Bookings & Stays",
            subtitle: "View booking history, receipts & invoice",
            onTap: onBookingsTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.fingerprint_rounded,
            title: "PG Attendance & Daily Check-in",
            subtitle: "Mark daily entry/exit & view attendance logs",
            onTap: onAttendanceTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.calendar_month_rounded,
            title: "My Scheduled Visits",
            subtitle: "Property tour appointments & status",
            onTap: onVisitsTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.favorite_rounded,
            title: "Saved PGs & Wishlist",
            subtitle: "View and manage your bookmarked PGs & hostels",
            iconColor: const Color(0xFFE11D48),
            onTap: onSavedListingsTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.payment_rounded,
            title: "Payment History & Receipts",
            subtitle: "Razorpay transaction history & payment records",
            iconColor: const Color(0xFF0D9488),
            onTap: onPaymentHistoryTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.description_outlined,
            title: "Invoices & Tax Receipts",
            subtitle: "View billing history & download PDF invoices",
            onTap: onInvoicesTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.card_membership_rounded,
            title: "My PG Subscriptions & Plans",
            subtitle: "Active stay plans, validity & renewals",
            onTap: onSubscriptionsTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.account_balance_wallet_rounded,
            title: "PG Wallet & Transactions",
            subtitle: "Recharges, cashback & deposit history",
            onTap: onWalletTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.badge_outlined,
            title: "Personal Profile & Details",
            subtitle: "Name, email, phone & KYC details",
            onTap: onProfileTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.headset_mic_rounded,
            title: "Help & Customer Support",
            subtitle: "24/7 dedicated support for tenants",
            onTap: onSupportTap,
          ),
          const Divider(height: 1, indent: 56, color: Color(0xFFF1F5F9)),
          PgProfileOptionTile(
            icon: Icons.logout_rounded,
            title: "Log Out",
            subtitle: "Sign out of your account",
            iconColor: const Color(0xFFDC2626),
            textColor: const Color(0xFFDC2626),
            onTap: onLogoutTap,
          ),
        ],
      ),
    );
  }
}

class PgProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const PgProfileOptionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: (iconColor ?? const Color(0xFF002060)).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? const Color(0xFF002060),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textColor ?? const Color(0xFF0F172A),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 11.5,
          color: Color(0xFF64748B),
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        size: 18,
        color: Color(0xFFCBD5E1),
      ),
    );
  }
}
