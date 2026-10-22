import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/attendance_controller.dart';
import 'package:vlr/data/models/gym_review_model.dart';
import 'package:vlr/services/constants.dart';

class GymReviewsScreen extends StatefulWidget {
  final String? gymId;
  final String? gymTitle;
  final String? customerMobile;

  const GymReviewsScreen({
    super.key,
    this.gymId,
    this.gymTitle,
    this.customerMobile,
  });

  @override
  State<GymReviewsScreen> createState() => _GymReviewsScreenState();
}

class _GymReviewsScreenState extends State<GymReviewsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadReviews();
    });
  }

  Future<void> _loadReviews() async {
    final controller = Get.find<AttendanceController>();
    final targetGymId = widget.gymId ?? controller.resolvedGymId;
    if (targetGymId != null && targetGymId.isNotEmpty) {
      await controller.fetchGymReviews(gymId: targetGymId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: Color(0xFF002060),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              "Reviews & Ratings",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            if (widget.gymTitle != null && widget.gymTitle!.isNotEmpty)
              Text(
                widget.gymTitle!,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                ),
              ),
          ],
        ),
        centerTitle: true,
      ),
      body: GetBuilder<AttendanceController>(
        builder: (controller) {
          final isLoading = controller.isGymReviewsLoading;
          final summary = controller.gymReviewSummary;
          final reviews = controller.gymReviewsList;
          final targetGymId = widget.gymId ?? controller.resolvedGymId ?? "";

          if (isLoading && reviews.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF002060),
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF002060),
            onRefresh: _loadReviews,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Overall Performance Card
                  _buildSummaryCard(summary, context, controller, targetGymId),

                  const SizedBox(height: 24),

                  // 2. Reviews Section Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Member Reviews (${summary?.totalReviews ?? reviews.length})",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF002060),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () => _showWriteReviewDialog(
                          context,
                          controller,
                          targetGymId,
                        ),
                        icon: const Icon(Icons.rate_review_outlined, size: 16),
                        label: const Text(
                          "Write Review",
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 3. Reviews List or Empty State
                  if (reviews.isEmpty)
                    _buildEmptyState(context, controller, targetGymId)
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildReviewItem(reviews[index]);
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: GetBuilder<AttendanceController>(
            builder: (controller) {
              final targetGymId = widget.gymId ?? controller.resolvedGymId ?? "";
              return SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002060),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => _showWriteReviewDialog(
                    context,
                    controller,
                    targetGymId,
                  ),
                  icon: const Icon(Icons.star_rate_rounded, size: 20),
                  label: const Text(
                    "Leave a Review & Rating",
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    GymReviewSummary? summary,
    BuildContext context,
    AttendanceController controller,
    String gymId,
  ) {
    final avgRating = summary?.averageRating ?? 0;
    final total = summary?.totalReviews ?? 0;
    final breakdown = summary?.ratingBreakdown ?? {};

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            "OVERALL RATING",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Big Rating & Stars
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        text: avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF002060),
                        ),
                        children: const [
                          TextSpan(
                            text: " /5",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starVal = index + 1;
                        return Icon(
                          starVal <= avgRating
                              ? Icons.star_rounded
                              : (starVal - 0.5 <= avgRating
                                  ? Icons.star_half_rounded
                                  : Icons.star_outline_rounded),
                          color: const Color(0xFFEAB308),
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      total == 1 ? "1 review" : "$total reviews",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 90,
                width: 1,
                color: const Color(0xFFF1F5F9),
                margin: const EdgeInsets.symmetric(horizontal: 14),
              ),

              // Right: Rating breakdown bars (5 star down to 1 star)
              Expanded(
                flex: 5,
                child: Column(
                  children: [5, 4, 3, 2, 1].map((star) {
                    final count = breakdown["${star}_star"] ?? 0;
                    final pct = total > 0 ? (count / total).clamp(0.0, 1.0) : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.5),
                      child: Row(
                        children: [
                          Text(
                            "$star★",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                minHeight: 6,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFEAB308),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 18,
                            child: Text(
                              "$count",
                              textAlign: TextAlign.end,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(GymReviewItem review) {
    final customerName = review.customer?.name ?? "Gym Member";
    final initial = customerName.isNotEmpty ? customerName[0].toUpperCase() : "M";
    final rating = review.rating.toDouble();
    final timeDisplay = review.dateFormatted ?? review.createdAt ?? "";

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
          // Header: Avatar, Name, Stars & Date
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF002060).withValues(alpha: 0.1),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Color(0xFF002060),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    if (timeDisplay.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        timeDisplay,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Stars
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFEAB308),
                    size: 16,
                  );
                }),
              ),
            ],
          ),

          if (review.comment != null && review.comment!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AttendanceController controller,
    String gymId,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF002060).withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rate_review_outlined,
              size: 40,
              color: Color(0xFF002060),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "No Reviews Yet",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Be the first member to share your workout experience and feedback!",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF002060),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              elevation: 0,
            ),
            onPressed: () => _showWriteReviewDialog(context, controller, gymId),
            icon: const Icon(Icons.star_rounded, size: 18),
            label: const Text(
              "Write the First Review",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(
    BuildContext context,
    AttendanceController controller,
    String gymId,
  ) {
    double selectedRating = 5.0;
    final TextEditingController commentController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                MediaQuery.of(dialogContext).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Rate Your Experience",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "How was your session at ${widget.gymTitle ?? 'your gym'}?",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Star Rating Picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final star = index + 1;
                        final isFilled = star <= selectedRating;
                        return IconButton(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isFilled
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: const Color(0xFFEAB308),
                            size: 38,
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = star.toDouble();
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getRatingDescription(selectedRating),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF002060),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Comment box
                    Form(
                      key: formKey,
                      child: TextFormField(
                        controller: commentController,
                        maxLines: 4,
                        style: const TextStyle(fontSize: 13.5),
                        decoration: InputDecoration(
                          hintText:
                              "Tell us about the equipment, hygiene, ambiance, and trainers...",
                          hintStyle: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF94A3B8),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFFE2E8F0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF002060),
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return "Please enter your review comment.";
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Submit Button
                    GetBuilder<AttendanceController>(
                      builder: (ctrl) {
                        final isSubmitting = ctrl.isSubmittingReview;
                        return SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF002060),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: isSubmitting
                                ? null
                                : () async {
                                    if (formKey.currentState?.validate() ?? false) {
                                      final result = await ctrl.submitGymReview(
                                        gymId: gymId,
                                        mobile: widget.customerMobile,
                                        rating: selectedRating,
                                        comment: commentController.text.trim(),
                                      );

                                      if (dialogContext.mounted) {
                                        Navigator.pop(dialogContext);
                                      }

                                      showToast(
                                        message: result.message,
                                        toastType: result.isSuccess
                                            ? ToastType.success
                                            : ToastType.error,
                                      );
                                    }
                                  },
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    "Submit Review",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                      ),
                      onPressed: () => Navigator.pop(dialogContext),
                      child: const Text(
                        "Maybe Later",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _getRatingDescription(double rating) {
    if (rating >= 5) return "⭐⭐⭐⭐⭐ Outstanding!";
    if (rating >= 4) return "⭐⭐⭐⭐ Very Good";
    if (rating >= 3) return "⭐⭐⭐ Average";
    if (rating >= 2) return "⭐⭐ Below Expectations";
    return "⭐ Poor";
  }
}
