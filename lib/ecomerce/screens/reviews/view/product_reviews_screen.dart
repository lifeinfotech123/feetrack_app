import 'package:flutter/material.dart';

import '../../../constants.dart';


class ReviewItemModel {
  final String userName;
  final String userAvatar;
  final double rating;
  final String date;
  final String title;
  final String comment;
  int helpfulCount;
  bool isHelpful;

  ReviewItemModel({
    required this.userName,
    required this.userAvatar,
    required this.rating,
    required this.date,
    required this.title,
    required this.comment,
    this.helpfulCount = 0,
    this.isHelpful = false,
  });
}

class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  int _selectedFilterIndex = 0;

  final List<String> _filters = [
    "All Reviews",
    "5 Stars ★",
    "4 Stars ★",
    "3 Stars ★",
  ];

  late final List<ReviewItemModel> _reviews;

  @override
  void initState() {
    super.initState();
    _reviews = [
      ReviewItemModel(
        userName: "Sophia Martinez",
        userAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200&auto=format&fit=crop&q=80",
        rating: 5.0,
        date: "2 days ago",
        title: "Absolutely stunning quality & fit!",
        comment:
            "I was amazed by the material finish and the craftsmanship. The sizing is true to size and it feels so premium. Definitely recommending this to everyone!",
        helpfulCount: 24,
      ),
      ReviewItemModel(
        userName: "David Chen",
        userAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&auto=format&fit=crop&q=80",
        rating: 5.0,
        date: "4 days ago",
        title: "Fast express delivery & perfect condition",
        comment:
            "Delivered right on time in great packaging. The color is exactly as shown in the photos. Worth every penny spent!",
        helpfulCount: 16,
      ),
      ReviewItemModel(
        userName: "Emily Watson",
        userAvatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=200&auto=format&fit=crop&q=80",
        rating: 4.0,
        date: "1 week ago",
        title: "Great product, very comfortable",
        comment:
            "Super comfortable for everyday wear. Material is breathable and looks stylish. Minor thread loose at the seam but overall 10/10 value.",
        helpfulCount: 9,
      ),
      ReviewItemModel(
        userName: "Aarav Sharma",
        userAvatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&auto=format&fit=crop&q=80",
        rating: 5.0,
        date: "2 weeks ago",
        title: "Best purchase this month!",
        comment:
            "Exceeded all my expectations. Texture is soft, stitches are durable, and it looks very fashionable. Got lots of compliments.",
        helpfulCount: 31,
      ),
      ReviewItemModel(
        userName: "Jessica Taylor",
        userAvatar: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200&auto=format&fit=crop&q=80",
        rating: 4.0,
        date: "3 weeks ago",
        title: "Very pleased with the purchase",
        comment:
            "Nice quality and fits well. Would love to buy more colors from this brand.",
        helpfulCount: 7,
      ),
    ];
  }

  List<ReviewItemModel> get _filteredReviews {
    if (_selectedFilterIndex == 1) {
      return _reviews.where((r) => r.rating >= 5.0).toList();
    } else if (_selectedFilterIndex == 2) {
      return _reviews.where((r) => r.rating == 4.0).toList();
    } else if (_selectedFilterIndex == 3) {
      return _reviews.where((r) => r.rating == 3.0).toList();
    }
    return _reviews;
  }

  void _showWriteReviewDialog() {
    double selectedRating = 5.0;
    final titleController = TextEditingController();
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final sheetBg = isDark ? darkGreyColor : whiteColor;

            return Container(
              padding: EdgeInsets.only(
                left: defaultPadding,
                right: defaultPadding,
                top: defaultPadding,
                bottom: MediaQuery.of(context).viewInsets.bottom + defaultPadding,
              ),
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: greyColor.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Write a Review",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Share your feedback with other shoppers",
                      style: TextStyle(fontSize: 12, color: greyColor),
                    ),
                    const SizedBox(height: 16),

                    // Star Selector
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final star = index + 1.0;
                          return IconButton(
                            icon: Icon(
                              star <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: const Color(0xFFFFB800),
                              size: 32,
                            ),
                            onPressed: () {
                              setModalState(() {
                                selectedRating = star;
                              });
                            },
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Review Title
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: "Review Title (e.g. Great Fit & Quality)",
                        labelStyle: const TextStyle(fontSize: 12),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF262634) : const Color(0xFFF6F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Review Comment
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "What did you like or dislike about this product?",
                        hintStyle: const TextStyle(fontSize: 12, color: greyColor),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF262634) : const Color(0xFFF6F6F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Submit Button
                    ElevatedButton(
                      onPressed: () {
                        if (commentController.text.trim().isNotEmpty) {
                          setState(() {
                            _reviews.insert(
                              0,
                              ReviewItemModel(
                                userName: "You (Verified Buyer)",
                                userAvatar:
                                    "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200&auto=format&fit=crop&q=80",
                                rating: selectedRating,
                                date: "Just now",
                                title: titleController.text.trim().isEmpty
                                    ? "Verified Product Review"
                                    : titleController.text.trim(),
                                comment: commentController.text.trim(),
                                helpfulCount: 0,
                              ),
                            );
                          });
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Thank you! Your review has been submitted."),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(defaultBorderRadious),
                        ),
                      ),
                      child: const Text(
                        "SUBMIT REVIEW",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : whiteColor;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    final args = (ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?) ?? {};
    final String productTitle = args["title"] ?? "Product Customer Reviews";

    final displayReviews = _filteredReviews;

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF161620) : Colors.white,
        elevation: 0.8,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          productTitle,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Rating Summary Header Card
            Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(defaultBorderRadious),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Big rating number
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "4.8",
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFFFB800),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${_reviews.length + 80} Ratings",
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : greyColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 18),
                  Container(
                    width: 1,
                    height: 80,
                    color: isDark ? Colors.white12 : const Color(0xFFECECF0),
                  ),
                  const SizedBox(width: 16),

                  // Progress bars for stars
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar("5 ★", 0.75, isDark),
                        const SizedBox(height: 4),
                        _buildRatingBar("4 ★", 0.18, isDark),
                        const SizedBox(height: 4),
                        _buildRatingBar("3 ★", 0.05, isDark),
                        const SizedBox(height: 4),
                        _buildRatingBar("2 ★", 0.01, isDark),
                        const SizedBox(height: 4),
                        _buildRatingBar("1 ★", 0.01, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: defaultPadding),

            // 2. Filter Pills Row
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: List.generate(_filters.length, (index) {
                  final isSelected = _selectedFilterIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_filters[index]),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
                        }
                      },
                      selectedColor: primaryColor,
                      backgroundColor: isDark
                          ? const Color(0xFF262634)
                          : const Color(0xFFF4F4F8),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : (isDark ? Colors.white70 : blackColor60),
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isSelected ? primaryColor : Colors.transparent,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: defaultPadding),

            // 3. Customer Reviews Section Title & Write review action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Customer Reviews (${displayReviews.length})",
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: _showWriteReviewDialog,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 14, color: primaryColor),
                  label: const Text(
                    "Write Review",
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 4. List of Review Cards
            ...displayReviews.map((review) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                  border: Border.all(
                    color: isDark ? Colors.white10 : const Color(0xFFEFEFF4),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(review.userAvatar),
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    review.userName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.verified_rounded,
                                      size: 14, color: successColor),
                                ],
                              ),
                              Text(
                                "Verified Buyer • ${review.date}",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? Colors.white54 : greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            5,
                            (index) => Icon(
                              Icons.star_rounded,
                              size: 15,
                              color: index < review.rating
                                  ? const Color(0xFFFFB800)
                                  : greyColor.withValues(alpha: 0.3),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Title
                    Text(
                      review.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Comment
                    Text(
                      review.comment,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : blackColor60,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Helpful Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (!review.isHelpful) {
                                review.helpfulCount += 1;
                                review.isHelpful = true;
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  review.isHelpful
                                      ? Icons.thumb_up_alt_rounded
                                      : Icons.thumb_up_alt_outlined,
                                  size: 13,
                                  color: review.isHelpful ? primaryColor : greyColor,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "Helpful (${review.helpfulCount})",
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    color:
                                        review.isHelpful ? primaryColor : greyColor,
                                    fontWeight: review.isHelpful
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: defaultPadding),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(String label, double value, bool isDark) {
    return Row(
      children: [
        SizedBox(
          width: 24,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : greyColor,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: isDark ? Colors.white10 : const Color(0xFFE8E8EE),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}
