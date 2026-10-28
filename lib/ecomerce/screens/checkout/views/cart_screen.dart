import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../components/network_image_with_loader.dart';
import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/address_controller.dart';
import '../../address/presentation/views/addresses_screen.dart';
import '../../coupon/views/coupon_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartController _cart = CartController.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final String targetDomain = _cart.items.isNotEmpty
          ? (_cart.items.first.domain ?? 'e-team-12')
          : 'e-team-12';
      AddressController.instance.fetchAddresses(domain: targetDomain);
    });
  }

  void _navigateToCouponScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CouponScreen(),
      ),
    );
  }

  void _openAddressSelection() {
    final String targetDomain = _cart.items.isNotEmpty
        ? (_cart.items.first.domain ?? 'e-team-12')
        : 'e-team-12';
    AddressController.instance.fetchAddresses(domain: targetDomain);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddressesScreen(
          selectAndReturn: true,
          storeDomain: targetDomain,
        ),
      ),
    );
  }

  void _confirmClearCart() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(defaultBorderRadious),
        ),
        title: const Text(
          "Clear Cart?",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        content: const Text(
          "Are you sure you want to remove all items from your cart?",
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: errorColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              _cart.clearCart();
              Navigator.pop(context);
            },
            child: const Text(
              "Clear",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : whiteColor;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    return Scaffold(
      backgroundColor: bodyBg,
      appBar: AppBar(
        backgroundColor: bodyBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: AnimatedBuilder(
          animation: _cart,
          builder: (context, _) {
            return Row(
              children: [
                Text(
                  "MY CART",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                ),
                if (_cart.totalItemCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "${_cart.totalItemCount} Items",
                      style: const TextStyle(
                        color: primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          AnimatedBuilder(
            animation: _cart,
            builder: (context, _) {
              if (_cart.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: _confirmClearCart,
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    color: errorColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: AnimatedBuilder(
        animation: _cart,
        builder: (context, _) {
          final items = _cart.items;

          if (items.isEmpty) {
            return _buildEmptyCartView(context, isDark);
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Cart Items Section Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Order Items",
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            "${items.length} unique products",
                            style: TextStyle(
                              fontSize: 11.5,
                              color: isDark ? Colors.white54 : greyColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: defaultPadding / 1.5),

                      // 3. Cart Items List Cards
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final cartItem = items[index];
                          final product = cartItem.product;
                          final unitPrice = cartItem.unitPrice;

                          return Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius:
                                  BorderRadius.circular(defaultBorderRadious),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white12
                                    : const Color(0xFFECECF0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Product Image
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF262634)
                                        : const Color(0xFFF6F6F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: NetworkImageWithLoader(
                                      product.image,
                                      radius: 10,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Product Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            product.brandName.toUpperCase(),
                                            style: const TextStyle(
                                              color: primaryColor,
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (product.storeName != null &&
                                              product
                                                  .storeName!.isNotEmpty) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: primaryColor.withValues(
                                                    alpha: isDark ? 0.2 : 0.08),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.storefront_outlined,
                                                    size: 9.5,
                                                    color: primaryColor,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    product.storeName!,
                                                    style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: primaryColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      if (cartItem.effectiveVariant.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isDark
                                                ? const Color(0xFF2E2A40)
                                                : const Color(0xFFF3F0FA),
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                              color: primaryColor.withValues(
                                                  alpha: 0.22),
                                              width: 0.8,
                                            ),
                                          ),
                                          child: Text(
                                            "Variation: ${cartItem.effectiveVariant}",
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w600,
                                              color: primaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 6),
                                      Text(
                                        "₹${unitPrice % 1 == 0 ? unitPrice.toInt() : unitPrice.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w800,
                                          color: primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Quantity Stepper & Remove Icon
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        _cart.removeFromCart(product);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        child: SvgPicture.asset(
                                          "assets/icons/Delete.svg",
                                          height: 18,
                                          colorFilter: const ColorFilter.mode(
                                            errorColor,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Stepper (+ / -)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: primaryColor.withValues(
                                          alpha: isDark ? 0.2 : 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: primaryColor.withValues(
                                            alpha: 0.3,
                                          ),
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              _cart.updateQuantity(product,
                                                  cartItem.quantity - 1);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: Icon(
                                                Icons.remove_rounded,
                                                color: primaryColor,
                                                size: 16,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6),
                                            child: Text(
                                              "${cartItem.quantity}",
                                              style: const TextStyle(
                                                color: primaryColor,
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              _cart.updateQuantity(product,
                                                  cartItem.quantity + 1);
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4),
                                              child: Icon(
                                                Icons.add_rounded,
                                                color: primaryColor,
                                                size: 16,
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
                          );
                        },
                      ),

                      const SizedBox(height: defaultPadding),

                      // 4. Interactive Coupon & Promo Code Section
                      _buildCouponSection(cardBg, isDark),

                      const SizedBox(height: defaultPadding),

                      // 5. Bill & Payment Summary Card
                      _buildBillDetailsCard(cardBg, isDark),

                      const SizedBox(height: defaultPadding),
                    ],
                  ),
                ),
              ),

              // Bottom Fixed Checkout Bar
              _buildBottomCheckoutBar(cardBg, isDark),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCouponSection(Color cardBg, bool isDark) {
    final appliedCoupon = _cart.appliedCoupon;

    if (appliedCoupon != null) {
      // Applied State
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: successColor.withValues(alpha: isDark ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(
            color: successColor.withValues(alpha: 0.35),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: successColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: successColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: successColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          appliedCoupon.code,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: successColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        "Applied!",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: successColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    appliedCoupon.isFreeDelivery
                        ? "Free express shipping unlocked 🎉"
                        : "Saved ₹${_cart.discountAmount.toStringAsFixed(2)} with promo discount",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white70 : blackColor60,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _navigateToCouponScreen,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Change",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _cart.removeCoupon();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Coupon removed"),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: errorColor,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  splashRadius: 16,
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Unapplied State: Prominent clickable coupon trigger
    return InkWell(
      onTap: _navigateToCouponScreen,
      borderRadius: BorderRadius.circular(defaultBorderRadious),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: defaultPadding,
          vertical: defaultPadding / 1.3,
        ),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(defaultBorderRadious),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.25),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                "assets/icons/Coupon.svg",
                height: 18,
                colorFilter: const ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Apply Coupons & Offers",
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Save up to 50% on your order",
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : greyColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "APPLY",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillDetailsCard(Color cardBg, bool isDark) {
    final subtotal = _cart.subtotal;
    final deliveryFee = _cart.deliveryFee;
    final discountAmount = _cart.discountAmount;
    final appliedCoupon = _cart.appliedCoupon;
    final grandTotal = _cart.grandTotal;
    final savings = _cart.totalSavings;

    return Container(
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Bill Details",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (savings > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: successColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "Saved ₹${savings.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: successColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Item Subtotal
          _buildSummaryRow(
            "Item Subtotal",
            "₹${subtotal.toStringAsFixed(2)}",
            isDark: isDark,
          ),
          const SizedBox(height: 8),

          // Delivery Fee
          _buildSummaryRow(
            "Express Delivery Fee",
            deliveryFee == 0 ? "FREE" : "₹${deliveryFee.toStringAsFixed(2)}",
            isFree: deliveryFee == 0,
            isDark: isDark,
          ),

          // Coupon Discount Row (if applied)
          if (appliedCoupon != null && discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              "Coupon Discount (${appliedCoupon.code})",
              "-₹${discountAmount.toStringAsFixed(2)}",
              isDiscount: true,
              isDark: isDark,
            ),
          ],

          if (appliedCoupon != null && appliedCoupon.isFreeDelivery) ...[
            const SizedBox(height: 8),
            _buildSummaryRow(
              "Free Delivery Promo (${appliedCoupon.code})",
              "FREE",
              isDiscount: true,
              isDark: isDark,
            ),
          ],

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1),
          ),

          // Grand Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "To Pay",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "₹${grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomCheckoutBar(Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: defaultPadding,
        vertical: defaultPadding * 0.75,
      ),
      decoration: BoxDecoration(
        color: cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Total Amount",
                  style: TextStyle(
                    fontSize: 10.5,
                    color: greyColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  "₹${_cart.grandTotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(width: defaultPadding),
            Expanded(
              child: ElevatedButton(
                onPressed: _openAddressSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(defaultBorderRadious),
                  ),
                ),
                child: const Text(
                  "PROCEED TO CHECKOUT",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCartView(BuildContext context, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(defaultPadding * 1.5),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                "assets/icons/Bag.svg",
                height: 56,
                colorFilter: const ColorFilter.mode(
                  primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            Text(
              "Your Cart is Empty!",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Looks like you haven't added anything to your cart yet.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: greyColor,
                  ),
            ),
            const SizedBox(height: defaultPadding * 1.5),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding * 1.5,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadious),
                ),
              ),
              icon:
                  const Icon(Icons.shopping_bag_outlined, color: Colors.white),
              label: const Text(
                "Start Shopping 🛍️",
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
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isFree = false,
    bool isDiscount = false,
    required bool isDark,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: isFree
                ? successColor
                : (isDiscount
                    ? successColor
                    : (isDark ? Colors.white : blackColor)),
          ),
        ),
      ],
    );
  }
}
