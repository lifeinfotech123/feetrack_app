import 'package:flutter/material.dart';
import 'package:vlr/data/models/rooom/pg_customer_dashboard_model.dart';

class PgProfileHeaderCard extends StatelessWidget {
  final PgCustomerInfo? customer;
  final PgDashboardHeader? header;
  final VoidCallback onProfileTap;

  const PgProfileHeaderCard({
    super.key,
    required this.customer,
    required this.header,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final initials = customer?.initials ?? header?.initials ?? "CU";
    final name = customer?.name ??
        "${customer?.firstName ?? 'Customer'} ${customer?.lastName ?? ''}"
            .trim();
    final email = customer?.email ?? "Email not provided";
    final phone = customer?.phone ?? "Phone not provided";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Initials / Avatar Circle
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF002060), Color(0xFF1E3A8A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF002060).withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: customer?.avatar != null && customer!.avatar!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(29),
                    child: Image.network(
                      customer!.avatar!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Text(
                        initials.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  )
                : Text(
                    initials.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // Name, Email, Phone
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name.isNotEmpty ? name : "Customer",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 12, color: Color(0xFF16A34A)),
                          SizedBox(width: 3),
                          Text(
                            "Active",
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16A34A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (phone.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.phone_rounded,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        phone,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 2),
                if (email.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Quick arrow to profile details
          IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xFF94A3B8),
            ),
            onPressed: onProfileTap,
          ),
        ],
      ),
    );
  }
}
