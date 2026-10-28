import 'package:flutter/material.dart';
import '../../constants.dart';
import '../../controllers/cart_controller.dart';
import '../../models/product_model.dart';

/// Universal reactive Add-to-Cart & Quantity Stepper Button.
///
/// Automatically listens to [CartController.instance].
/// When quantity == 0, renders an "ADD" or "+" button.
/// When quantity > 0, smoothly transforms into a `[-] [quantity] [+]` stepper.
class ProductQuantityButton extends StatelessWidget {
  final ProductModel product;
  final String? storeDomain;
  final bool isMini;
  final bool isFullWidth;
  final bool showText;
  final double? height;
  final Color? activeColor;
  final String? variant;
  final String? color;
  final Map<String, dynamic>? choices;
  final VoidCallback? onAdded;
  final VoidCallback? onRemoved;

  const ProductQuantityButton({
    super.key,
    required this.product,
    this.storeDomain,
    this.isMini = false,
    this.isFullWidth = false,
    this.showText = true,
    this.height,
    this.activeColor,
    this.variant,
    this.color,
    this.choices,
    this.onAdded,
    this.onRemoved,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = activeColor ?? primaryColor;
    final buttonHeight = height ?? (isMini ? 28.0 : 30.0);

    return ListenableBuilder(
      listenable: CartController.instance,
      builder: (context, _) {
        final cart = CartController.instance;
        final int quantity =
            cart.getQuantity(product, storeDomain: storeDomain);

        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
              child: child,
            ),
          ),
          child: quantity == 0
              ? _buildAddButton(context, cart, effectiveColor, buttonHeight)
              : _buildStepper(
                  context, cart, quantity, effectiveColor, buttonHeight),
        );
      },
    );
  }

  Widget _buildAddButton(
    BuildContext context,
    CartController cart,
    Color color,
    double height,
  ) {
    final bool useIconOnly = isMini && !showText;

    return Material(
      key: const ValueKey('add_button'),
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          cart.addToCart(
            product,
            quantity: 1,
            storeDomain: storeDomain,
            variant: variant,
            color: this.color,
            choices: choices,
          );
          onAdded?.call();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Added ${product.title} to cart 🛍️",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF1B5E20),
                duration: const Duration(milliseconds: 900),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: height,
          width: useIconOnly ? height : (isFullWidth ? double.infinity : null),
          padding: useIconOnly
              ? EdgeInsets.zero
              : EdgeInsets.symmetric(horizontal: isFullWidth ? 8 : 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: useIconOnly
              ? const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 18,
                )
              : Row(
                  mainAxisSize:
                      isFullWidth ? MainAxisSize.max : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_rounded, size: 14, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      "ADD",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildStepper(
    BuildContext context,
    CartController cart,
    int quantity,
    Color color,
    double height,
  ) {
    final double stepWidth = isFullWidth ? 30 : (isMini ? 24 : 26);

    return Material(
      key: const ValueKey('stepper_active'),
      color: Colors.transparent,
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        constraints: BoxConstraints(
          minWidth: isFullWidth ? double.infinity : (isMini ? 72 : 78),
        ),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Decrement Button (-) or Trash
            InkWell(
              onTap: () {
                cart.decreaseQuantity(product, storeDomain: storeDomain);
                if (quantity == 1) {
                  onRemoved?.call();
                }
              },
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
              child: Container(
                height: height,
                width: stepWidth,
                alignment: Alignment.center,
                child: Icon(
                  quantity == 1
                      ? Icons.delete_outline_rounded
                      : Icons.remove_rounded,
                  color: Colors.white,
                  size: quantity == 1 ? 14 : 15,
                ),
              ),
            ),

            // Quantity Display
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Text(
                "$quantity",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ),

            // Increment Button (+)
            InkWell(
              onTap: () {
                cart.increaseQuantity(product, storeDomain: storeDomain);
              },
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(8)),
              child: Container(
                height: height,
                width: stepWidth,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
