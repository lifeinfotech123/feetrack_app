import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:vlr/ecomerce/controllers/cart_controller.dart';
import 'package:vlr/ecomerce/models/food_model.dart';

/// Swiggy & Zomato style Food Item Customization BottomSheet.
/// Displays item details, portion/variant selection, dynamic quantity stepper,
/// live price calculation, and prominent Add to Cart CTA.
class FoodCustomizationBottomSheet extends StatefulWidget {
  final DishModel dish;
  final String storeDomain;
  final int shopId;
  final String restaurantName;
  final DishVariantModel? initialVariant;
  final int initialQuantity;

  const FoodCustomizationBottomSheet({
    super.key,
    required this.dish,
    required this.storeDomain,
    required this.shopId,
    required this.restaurantName,
    this.initialVariant,
    this.initialQuantity = 1,
  });

  /// Convenient static helper to show this bottom sheet modal anywhere
  static Future<void> show({
    required BuildContext context,
    required DishModel dish,
    required String storeDomain,
    required int shopId,
    required String restaurantName,
    DishVariantModel? initialVariant,
    int initialQuantity = 1,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (ctx) => FoodCustomizationBottomSheet(
        dish: dish,
        storeDomain: storeDomain,
        shopId: shopId,
        restaurantName: restaurantName,
        initialVariant: initialVariant,
        initialQuantity: initialQuantity,
      ),
    );
  }

  @override
  State<FoodCustomizationBottomSheet> createState() =>
      _FoodCustomizationBottomSheetState();
}

class _FoodCustomizationBottomSheetState
    extends State<FoodCustomizationBottomSheet> {
  late DishVariantModel? _selectedVariant;
  late int _quantity;

  @override
  void initState() {
    super.initState();
    if (widget.dish.variants.isNotEmpty) {
      _selectedVariant = widget.initialVariant ?? widget.dish.variants.first;
    } else {
      _selectedVariant = null;
    }
    _quantity = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
  }

  double get _currentUnitPrice {
    if (_selectedVariant != null) {
      return _selectedVariant!.effectivePrice;
    }
    return widget.dish.dealPrice > 0
        ? widget.dish.dealPrice
        : widget.dish.originalPrice;
  }

  double get _currentOriginalPrice {
    if (_selectedVariant != null) {
      return _selectedVariant!.price > 0
          ? _selectedVariant!.price
          : _selectedVariant!.effectivePrice;
    }
    return widget.dish.originalPrice > 0
        ? widget.dish.originalPrice
        : widget.dish.dealPrice;
  }

  double get _totalPrice => _currentUnitPrice * _quantity;

  bool get _hasDiscount => _currentOriginalPrice > _currentUnitPrice;

  void _onAddToCart() {
    final productModel = widget.dish.toProductModel(
      storeDomain: widget.storeDomain,
      shopId: widget.shopId,
      restaurantName: widget.restaurantName,
      selectedVariant: _selectedVariant,
    );

    final variantDisplayName = _selectedVariant != null
        ? "${_selectedVariant!.name}${_selectedVariant!.weightVolume != null && _selectedVariant!.weightVolume!.trim().isNotEmpty ? ' (${_selectedVariant!.weightVolume} ${_selectedVariant!.weightUnit ?? ''})' : ''}".trim()
        : null;

    CartController.instance.addToCart(
      productModel,
      quantity: _quantity,
      storeDomain: widget.storeDomain,
      variant: variantDisplayName,
    );

    Navigator.pop(context);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Added $_quantity x ${widget.dish.name}${variantDisplayName != null ? ' ($variantDisplayName)' : ''} to cart",
                  maxLines: 2,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF00C853),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  String _formatServingSize(String size) {
    final trimmed = size.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains('-') ||
        trimmed.toLowerCase().contains('person') ||
        trimmed.toLowerCase().contains('serve')) {
      return "Serves $trimmed";
    }
    final numVal = num.tryParse(trimmed);
    if (numVal != null) {
      if (numVal <= 10) {
        return "Serves $trimmed";
      }
      return "Portion: $trimmed gm";
    }
    return "Serves $trimmed";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1E28) : Colors.white;
    final cardBg = isDark ? const Color(0xFF262634) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final subTextColor = isDark ? Colors.white60 : const Color(0xFF6E6E77);
    final borderColor = isDark ? Colors.white12 : const Color(0xFFE5E5EA);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle & Header Close
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 18,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Scrollable Body Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Food Header Card (Image + Details + Badges)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Details Column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Veg / Non-Veg Indicator & Tags
                            Row(
                              children: [
                                widget.dish.isVeg
                                    ? _buildVegIndicator()
                                    : _buildNonVegIndicator(),
                                const SizedBox(width: 8),
                                if (widget.dish.isRecommended == 1)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFF9800)
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "★ BESTSELLER",
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFE65100),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                if (widget.dish.isSpicy == 1) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE53935)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "🌶️ SPICY",
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFFE53935),
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Dish Name
                            Text(
                              widget.dish.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Price Row
                            Row(
                              children: [
                                Text(
                                  "₹${_currentUnitPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF00C853),
                                  ),
                                ),
                                if (_hasDiscount) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    "₹${_currentOriginalPrice.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: subTextColor,
                                      decoration: TextDecoration.lineThrough,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00C853)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "Save ₹${(_currentOriginalPrice - _currentUnitPrice).toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00C853),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Prep Time & Category Info
                            Row(
                              children: [
                                Icon(Icons.timer_outlined,
                                    size: 13, color: subTextColor),
                                const SizedBox(width: 4),
                                Text(
                                  "${widget.dish.preparationTimeMin ?? 20} mins",
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: subTextColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (widget.dish.categoryName != null) ...[
                                  Text(" • ",
                                      style: TextStyle(color: subTextColor)),
                                  Text(
                                    widget.dish.categoryName!,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: subTextColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // Selected Variant & Quantity Strip
                            if (_selectedVariant != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853)
                                      .withValues(alpha: isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: const Color(0xFF00C853)
                                        .withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        size: 14, color: Color(0xFF00C853)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "Selected: ${_selectedVariant!.name}"
                                        "${_selectedVariant!.weightVolume != null && _selectedVariant!.weightVolume!.trim().isNotEmpty ? ' • Qty: ${_selectedVariant!.weightVolume} ${_selectedVariant!.weightUnit ?? ''}'.trim() : ''}"
                                        "${_selectedVariant!.servingSize != null && _selectedVariant!.servingSize!.trim().isNotEmpty ? ' • ${_formatServingSize(_selectedVariant!.servingSize!)}' : ''}"
                                        "${_selectedVariant!.sku != null && _selectedVariant!.sku!.trim().isNotEmpty ? ' • SKU: ${_selectedVariant!.sku}' : ''}",
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF00C853),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Dish Thumbnail
                      if (widget.dish.thumbnail != null &&
                          widget.dish.thumbnail!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: cardBg,
                              border: Border.all(color: borderColor),
                            ),
                            child: CachedNetworkImage(
                              imageUrl: widget.dish.thumbnail!,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.fastfood_rounded,
                                color: Color(0xFF00C853),
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 18),
                  Divider(color: borderColor, height: 1),
                  const SizedBox(height: 18),

                  // 2. Portion / Variant Selection (if available)
                  if (widget.dish.variants.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Portion / Size",
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Choose any 1 option",
                              style: TextStyle(
                                fontSize: 11.5,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFE53935).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "REQUIRED",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFE53935),
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Variant List Cards
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.dish.variants.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final variant = widget.dish.variants[index];
                        final isSelected = _selectedVariant?.id == variant.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedVariant = variant;
                            });
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF00C853)
                                      .withValues(alpha: isDark ? 0.15 : 0.08)
                                  : cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF00C853)
                                    : borderColor,
                                width: isSelected ? 1.8 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    // Custom Radio Icon
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFF00C853)
                                              : (isDark
                                                  ? Colors.white38
                                                  : Colors.grey.shade400),
                                          width: isSelected ? 6 : 1.8,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Variant Name + Weight Tag
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              variant.name,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: textColor,
                                              ),
                                            ),
                                          ),
                                          if (variant.weightVolume != null &&
                                              variant.weightVolume!.trim().isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 7, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF00C853)
                                                    .withValues(alpha: 0.14),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                "${variant.weightVolume} ${variant.weightUnit ?? ''}".trim(),
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF00C853),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),

                                    // Variant Price
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "₹${variant.effectivePrice.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.w800,
                                            color: isSelected
                                                ? const Color(0xFF00C853)
                                                : textColor,
                                          ),
                                        ),
                                        if (variant.hasDiscount) ...[
                                          const SizedBox(height: 1),
                                          Text(
                                            "₹${variant.price.toStringAsFixed(2)}",
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              color: subTextColor,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),

                                // Specifications Badges: Food Qty, Serving size, Prep time, SKU
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 32),
                                  child: Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      // 1. Food Quantity / Weight
                                      if (variant.weightVolume != null &&
                                          variant.weightVolume!.trim().isNotEmpty)
                                        _buildVariantBadge(
                                          icon: Icons.scale_rounded,
                                          label: "Qty: ${variant.weightVolume} ${variant.weightUnit ?? ''}".trim(),
                                          isDark: isDark,
                                          isSelected: isSelected,
                                        ),

                                      // 2. Serving Size / Portion
                                      if (variant.servingSize != null &&
                                          variant.servingSize!.trim().isNotEmpty)
                                        _buildVariantBadge(
                                          icon: Icons.room_service_outlined,
                                          label: _formatServingSize(variant.servingSize!),
                                          isDark: isDark,
                                          isSelected: isSelected,
                                        ),

                                      // 3. Prep Time
                                      if (variant.prepTimeMin != null &&
                                          variant.prepTimeMin! > 0)
                                        _buildVariantBadge(
                                          icon: Icons.timer_outlined,
                                          label: "${variant.prepTimeMin} min prep",
                                          isDark: isDark,
                                          isSelected: isSelected,
                                        ),

                                      // 4. SKU Code
                                      if (variant.sku != null &&
                                          variant.sku!.trim().isNotEmpty)
                                        _buildVariantBadge(
                                          icon: Icons.qr_code_rounded,
                                          label: "SKU: ${variant.sku}",
                                          isDark: isDark,
                                          isSelected: isSelected,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),
                    Divider(color: borderColor, height: 1),
                    const SizedBox(height: 16),
                  ],

                  // 3. Quantity Stepper Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Quantity",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Adjust number of items",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),

                      // Stepper Controls
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Minus Button
                            InkWell(
                              onTap: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: _quantity > 1
                                      ? (isDark
                                          ? Colors.white12
                                          : Colors.grey.shade200)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.remove_rounded,
                                  size: 18,
                                  color: _quantity > 1
                                      ? textColor
                                      : subTextColor.withValues(alpha: 0.4),
                                ),
                              ),
                            ),

                            // Quantity Display
                            Container(
                              constraints: const BoxConstraints(minWidth: 42),
                              alignment: Alignment.center,
                              child: Text(
                                "$_quantity",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: textColor,
                                ),
                              ),
                            ),

                            // Plus Button
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _quantity++;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00C853)
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.add_rounded,
                                  size: 18,
                                  color: Color(0xFF00C853),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // 4. Sticky Bottom Action CTA Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              border: Border(top: BorderSide(color: borderColor)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00C853),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                  child: Row(
                    children: [
                      // Total items & price
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "$_quantity ${_quantity == 1 ? 'ITEM' : 'ITEMS'}",
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white70,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            "₹${_totalPrice.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // CTA label
                      const Text(
                        "Add Item to Cart",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantBadge({
    required IconData icon,
    required String label,
    required bool isDark,
    required bool isSelected,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xFF00C853).withValues(alpha: isDark ? 0.22 : 0.12)
            : (isDark
                ? Colors.white.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.04)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00C853).withValues(alpha: 0.35)
              : (isDark
                  ? Colors.white10
                  : Colors.black.withValues(alpha: 0.06)),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11.5,
            color: isSelected
                ? const Color(0xFF00C853)
                : (isDark ? Colors.white60 : Colors.black54),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected
                  ? (isDark
                      ? Colors.greenAccent.shade100
                      : const Color(0xFF007E33))
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVegIndicator() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF00C853), width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(
            color: Color(0xFF00C853),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildNonVegIndicator() {
    return Container(
      width: 15,
      height: 15,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFE53935), width: 1.5),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Center(
        child: CustomPaint(
          size: const Size(6, 6),
          painter: _TrianglePainter(color: const Color(0xFFE53935)),
        ),
      ),
    );
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;

  _TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
