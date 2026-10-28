import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class DoctorShowDataWidget extends StatelessWidget {
  final String name;
  final String specialty;
  final String? experience;
  final double? rating;
  final int? reviews;
  final int? patientStoriesPercent;
  final int? patientStoriesCount;
  final String? hospital;
  final String? location;
  final String? fee;
  final String? availability;
  final String? imageUrl;
  final List<String>? hospitalImages;
  final VoidCallback onTap;
  final VoidCallback? onCallTap;

  const DoctorShowDataWidget({
    super.key,
    required this.name,
    required this.specialty,
    this.experience,
    this.rating,
    this.reviews,
    this.patientStoriesPercent,
    this.patientStoriesCount,
    this.hospital,
    this.location,
    this.fee,
    this.availability,
    this.imageUrl,
    this.hospitalImages,
    required this.onTap,
    this.onCallTap,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = imageUrl;

    final doctorFee = (fee != null && fee!.isNotEmpty)
        ? (fee!.startsWith('~') ||
                fee!.contains('Consultation') ||
                fee!.contains('Fee')
            ? fee!
            : '$fee Consultation Fee')
        : null;

    final loc = location ?? '';
    final hospName = hospital ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: borderGrey.withValues(alpha: 0.8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Doctor Image + Basic Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: (imgUrl != null && imgUrl.isNotEmpty)
                            ? Image.network(
                                imgUrl,
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Image.network(
                                  'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300&auto=format&fit=crop&q=80',
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color:
                                          primaryColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Icon(Icons.person,
                                        color: primaryColor, size: 38),
                                  ),
                                ),
                              )
                            : Image.network(
                                'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=300&auto=format&fit=crop&q=80',
                                width: 72,
                                height: 72,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.person,
                                      color: primaryColor, size: 38),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Doctor Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                                height: 1.2,
                              ),
                            ),
                            if (specialty.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                specialty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            if (experience != null &&
                                experience!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.work_outline,
                                      size: 13, color: textMuted),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      experience!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: textDark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Badges section only if rating or patient stories present in API data
                  if ((patientStoriesPercent != null &&
                          patientStoriesCount != null) ||
                      (rating != null && rating! > 0)) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (patientStoriesPercent != null &&
                            patientStoriesCount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: wellnessGreenBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: wellnessGreen.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.thumb_up_alt_rounded,
                                    color: wellnessGreen, size: 13),
                                const SizedBox(width: 4),
                                Text(
                                  '$patientStoriesPercent%',
                                  style: const TextStyle(
                                    color: wellnessGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '($patientStoriesCount Stories)',
                                  style: const TextStyle(
                                    color: textMuted,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (rating != null && rating! > 0)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(20),
                              border:
                                  Border.all(color: const Color(0xFFBFDBFE)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFF0284C7), size: 14),
                                const SizedBox(width: 3),
                                Text(
                                  '$rating',
                                  style: const TextStyle(
                                    color: textDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                                if (reviews != null && reviews! > 0) ...[
                                  const SizedBox(width: 3),
                                  Text(
                                    '($reviews)',
                                    style: const TextStyle(
                                      color: textMuted,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],

                  if (hospName.isNotEmpty ||
                      loc.isNotEmpty ||
                      doctorFee != null) ...[
                    const SizedBox(height: 12),
                    // Hospital Info Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderGrey),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (hospName.isNotEmpty)
                                      Text(
                                        hospName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: textDark,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    if (loc.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        loc,
                                        style: const TextStyle(
                                          color: textMuted,
                                          fontSize: 11,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                    if (doctorFee != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        doctorFee,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          color: Color(0xFF0284C7),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (hospName.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified_user_rounded,
                                          color: Color(0xFF0284C7), size: 12),
                                      SizedBox(width: 3),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          color: Color(0xFF0284C7),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (hospitalImages != null &&
                              hospitalImages!.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 38,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: hospitalImages!.length,
                                itemBuilder: (context, idx) {
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.network(
                                        hospitalImages![idx],
                                        width: 48,
                                        height: 38,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          width: 48,
                                          height: 38,
                                          color: Colors.grey[200],
                                          child: const Icon(
                                              Icons.local_hospital,
                                              size: 16,
                                              color: primaryColor),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],

                  if (availability != null && availability!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time_filled_rounded,
                            color: Color(0xFF0284C7), size: 15),
                        const SizedBox(width: 6),
                        const Text(
                          'Availability: ',
                          style: TextStyle(fontSize: 11, color: textMuted),
                        ),
                        Expanded(
                          child: Text(
                            availability!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCallTap ?? onTap,
                      icon: const Icon(Icons.phone,
                          size: 14, color: Color(0xFF1E3A8A)),
                      label: const Text(
                        'Call',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFEFF3FE),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      child: const Text(
                        'Book Visit',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
