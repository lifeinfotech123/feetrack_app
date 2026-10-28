import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vlr/ecomerce/screens/product/views/product_returns_screen.dart';

import 'package:get/get.dart';
import '../../../components/cart_button.dart';
import '../../../components/custom_modal_bottom_sheet.dart';
import '../../../components/product/product_card.dart';
import '../../../constants.dart';
import '../../../controllers/cart_controller.dart';
import '../../../controllers/home_screen_api_controller.dart';
import '../../../controllers/store_controller.dart';
import '../../../controllers/wishlist_controller.dart';
import '../../../models/product_model.dart';
import '../../../models/product_variant_model.dart';
import '../../../services/product_service.dart';
import '../../../route/route_constants.dart';
import 'components/notify_me_card.dart';
import 'components/product_images.dart';
import 'components/product_info.dart';
import 'components/product_list_tile.dart';
import '../../../components/review_card.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel? product;
  final bool isProductAvailable;

  const ProductDetailsScreen({
    super.key,
    this.product,
    this.isProductAvailable = true,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  ProductVariantDetailsModel? _variantDetails;
  bool _isLoadingVariants = false;
  ProductVariationItemModel? _selectedVariationItem;
  final Map<String, String> _selectedChoices = {};
  String? _selectedVariant;
  String? _selectedColor;
  String? _selectedSize;
  int? _loadedProductId;

  Color? _parseColorCode(String? hex) {
    if (hex == null || hex.isEmpty) return null;
    try {
      String clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) {
        clean = 'FF$clean';
      }
      if (clean.length == 8) {
        return Color(int.parse(clean, radix: 16));
      }
    } catch (_) {}
    return null;
  }

  void _initDefaultVariants(ProductModel product) {
    _selectedColor = product.getDefaultColor();
    final availSizes = product.getAvailableSizes();
    _selectedSize = availSizes.isNotEmpty ? availSizes.first : null;
    _selectedVariant = product.getDefaultVariant();
    _selectedChoices.clear();
    final defChoices = product.getDefaultChoices();
    defChoices.forEach((k, v) => _selectedChoices[k] = v.toString());
  }

  Future<void> _fetchVariantsFromApi(ProductModel product) async {
    final productId = product.id;
    if (productId == null || productId <= 0) return;
    setState(() {
      _isLoadingVariants = true;
    });

    try {
      final StoreController? storeCtrl =
          Get.isRegistered<StoreController>() ? Get.find<StoreController>() : null;
      final activeDomain =
          product.storeDomain ?? storeCtrl?.selectedStore.value?.domain;

      final details =
          await ProductService().getProductVariants(product.id!, domain: activeDomain);

      if (mounted && details != null) {
        setState(() {
          _variantDetails = details;
          _isLoadingVariants = false;

          // Initialize with default_selection if present
          if (details.defaultSelection != null) {
            _selectedVariationItem = details.defaultSelection;
            _selectedVariant = details.defaultSelection!.variant;
            if (details.defaultSelection!.color != null &&
                details.defaultSelection!.color!.isNotEmpty) {
              _selectedColor = details.defaultSelection!.color;
            }
            if (details.defaultSelection!.size != null &&
                details.defaultSelection!.size!.isNotEmpty) {
              _selectedSize = details.defaultSelection!.size;
            }
          }

          // Initialize choice_options
          for (var choice in details.choiceOptions) {
            if (choice.options.isNotEmpty) {
              String optVal = choice.options.first;
              if (_selectedVariationItem != null) {
                for (var opt in choice.options) {
                  final target =
                      '${_selectedVariationItem!.variant} ${_selectedVariationItem!.title ?? ''}'
                          .toLowerCase();
                  if (target.contains(opt.toLowerCase())) {
                    optVal = opt;
                    break;
                  }
                }
              }
              _selectedChoices[choice.title] = optVal;
            }
          }

          // Initialize color
          if (details.colors.isNotEmpty &&
              (_selectedColor == null || _selectedColor!.isEmpty)) {
            _selectedColor = details.colors.first.name;
          }

          _syncSelectedVariation();
        });
      } else if (mounted) {
        setState(() {
          _isLoadingVariants = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVariants = false;
        });
      }
    }
  }

  void _syncSelectedVariation() {
    if (_variantDetails == null) return;

    if (_variantDetails!.variations.isNotEmpty) {
      final matched = _variantDetails!.findVariation(
        color: _selectedColor,
        size: _selectedChoices['Size'] ?? _selectedSize,
        selectedChoices: _selectedChoices,
      );
      if (matched != null) {
        _selectedVariationItem = matched;
        _selectedVariant =
            matched.variant.isNotEmpty ? matched.variant : matched.title ?? '';
        if (matched.color != null && matched.color!.isNotEmpty) {
          _selectedColor = matched.color;
        }
        if (matched.size != null && matched.size!.isNotEmpty) {
          _selectedSize = matched.size;
        }
        return;
      }
    }

    final parts = <String>[];
    if (_selectedChoices.isNotEmpty) {
      parts.addAll(_selectedChoices.values);
    }
    if (_selectedColor != null &&
        _selectedColor!.isNotEmpty &&
        !parts.contains(_selectedColor)) {
      parts.add(_selectedColor!);
    }
    _selectedVariant = parts.isNotEmpty
        ? parts.join(", ")
        : (_variantDetails?.defaultSelection?.variant ?? '');
  }

  void _onChoiceSelected(String choiceTitle, String optionValue) {
    setState(() {
      _selectedChoices[choiceTitle] = optionValue;
      if (choiceTitle.toLowerCase() == 'size') {
        _selectedSize = optionValue;
      }
      _syncSelectedVariation();
    });
  }

  void _onColorSelected(String colorName) {
    setState(() {
      _selectedColor = colorName;
      _syncSelectedVariation();
    });
  }

  void _updateVariantForApparel(ProductModel product) {
    final size = _selectedSize ??
        (product.getAvailableSizes().isNotEmpty
            ? product.getAvailableSizes().first
            : '');
    final color = _selectedColor ??
        (product.getAvailableColors().isNotEmpty
            ? product.getAvailableColors().first
            : '');
    if (size.isNotEmpty && color.isNotEmpty) {
      _selectedVariant = "$size, $color";
    } else if (size.isNotEmpty) {
      _selectedVariant = size;
    } else if (color.isNotEmpty) {
      _selectedVariant = color;
    } else {
      _selectedVariant = product.getDefaultVariant();
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArgs = ModalRoute.of(context)?.settings.arguments;
    ProductModel currentProduct;

    if (widget.product != null) {
      currentProduct = widget.product!;
    } else if (routeArgs is ProductModel) {
      currentProduct = routeArgs;
    } else {
      final HomeScreenApiController? homeCtrl =
          Get.isRegistered<HomeScreenApiController>()
              ? Get.find<HomeScreenApiController>()
              : null;
      if (homeCtrl != null && homeCtrl.allProducts.isNotEmpty) {
        currentProduct = homeCtrl.allProducts.first.toProductModel();
      } else {
        currentProduct = demoPopularProducts.first;
      }
    }

    if (_loadedProductId != currentProduct.id) {
      _loadedProductId = currentProduct.id;
      _initDefaultVariants(currentProduct);
      _fetchVariantsFromApi(currentProduct);
    }

    final CartController cart = CartController.instance;
    final double displayUnitPrice = _selectedVariationItem?.price ??
        (currentProduct.priceAfetDiscount ?? currentProduct.price);

    return Scaffold(
      bottomNavigationBar: widget.isProductAvailable
          ? ListenableBuilder(
              listenable: cart,
              builder: (context, _) {
                final StoreController? storeCtrl =
                    Get.isRegistered<StoreController>()
                        ? Get.find<StoreController>()
                        : null;
                final activeDomain = currentProduct.storeDomain ??
                    storeCtrl?.selectedStore.value?.domain;
                final int qty = cart.getQuantity(
                  currentProduct,
                  storeDomain: activeDomain,
                  variant: _selectedVariant,
                );

                if (qty == 0) {
                  return CartButton(
                    price: displayUnitPrice,
                    title: "Add to cart",
                    subTitle: "Total Price",
                    press: () {
                      final itemVariant = _selectedVariant ??
                          _selectedVariationItem?.variant ??
                          currentProduct.getDefaultVariant();
                      cart.addToCart(
                        currentProduct,
                        storeDomain: activeDomain,
                        variant: itemVariant,
                        color: _selectedColor ?? _selectedVariationItem?.color,
                        choices: _selectedChoices.isNotEmpty
                            ? _selectedChoices
                            : null,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: successColor,
                          behavior: SnackBarBehavior.floating,
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${currentProduct.title} (${itemVariant.isNotEmpty ? itemVariant : 'Standard'}) added to cart!",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          action: SnackBarAction(
                            label: "VIEW CART",
                            textColor: Colors.white,
                            onPressed: () {
                              Navigator.pushNamed(context, cartScreenRoute);
                            },
                          ),
                        ),
                      );
                    },
                  );
                } else {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: defaultPadding,
                      vertical: defaultPadding * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      border: Border(
                        top: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white12
                              : const Color(0xFFECECF0),
                          width: 1,
                        ),
                      ),
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
                      child: Row(
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Total Price",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white60
                                      : Colors.grey.shade600,
                                ),
                              ),
                              Text(
                                "₹${(displayUnitPrice * qty).toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            height: 42,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withValues(alpha: 0.3),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                InkWell(
                                  onTap: () {
                                    cart.decreaseQuantity(
                                      currentProduct,
                                      storeDomain: activeDomain,
                                      variant: _selectedVariant,
                                    );
                                  },
                                  borderRadius: const BorderRadius.horizontal(
                                      left: Radius.circular(12)),
                                  child: Container(
                                    width: 38,
                                    height: 42,
                                    alignment: Alignment.center,
                                    child: Icon(
                                      qty == 1
                                          ? Icons.delete_outline_rounded
                                          : Icons.remove_rounded,
                                      color: primaryColor,
                                      size: 19,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    "$qty",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    cart.addToCart(
                                      currentProduct,
                                      quantity: 1,
                                      storeDomain: activeDomain,
                                      variant: _selectedVariant,
                                      color: _selectedColor,
                                      choices: _selectedChoices.isNotEmpty
                                          ? _selectedChoices
                                          : null,
                                    );
                                  },
                                  borderRadius: const BorderRadius.horizontal(
                                      right: Radius.circular(12)),
                                  child: Container(
                                    width: 38,
                                    height: 42,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.add_rounded,
                                      color: primaryColor,
                                      size: 19,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pushNamed(context, cartScreenRoute);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            icon: const Icon(Icons.shopping_bag_outlined,
                                size: 17),
                            label: const Text(
                              "VIEW CART",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11.5,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            )
          : NotifyMeCard(
              isNotify: false,
              onChanged: (value) {},
            ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              floating: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                Obx(() {
                  final isFav = WishlistController.instance
                      .isWishlisted(currentProduct.id);
                  return IconButton(
                    tooltip: isFav ? "Remove from Wishlist" : "Add to Wishlist",
                    onPressed: () {
                      WishlistController.instance.toggleWishlist(
                        productId: currentProduct.id,
                        domain: currentProduct.storeDomain,
                        context: context,
                      );
                    },
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav
                          ? const Color(0xFFFF3366)
                          : (Theme.of(context).textTheme.bodyLarge?.color ??
                              Colors.black),
                    ),
                  );
                }),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, cartScreenRoute);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/Bag.svg",
                    colorFilter: ColorFilter.mode(
                      Theme.of(context).textTheme.bodyLarge?.color ??
                          Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
              ],
            ),

            // Product Images Slider
            ProductImages(
              images: {
                if (_selectedVariationItem?.thumbnail != null &&
                    _selectedVariationItem!.thumbnail!.isNotEmpty)
                  _selectedVariationItem!.thumbnail!,
                currentProduct.image,
                productDemoImg2,
                productDemoImg3,
              }.toList(),
            ),

            // Product Information Header
            ProductInfo(
              brand: currentProduct.brandName.toUpperCase(),
              title: currentProduct.title,
              isAvailable: widget.isProductAvailable,
              description:
                  "Premium curated design with exceptional durability and high comfort. Handcrafted with authentic materials, designed for your everyday lifestyle.",
              rating: 4.8,
              numOfReviews: 128,
            ),

            // Interactive Variant Selector (Size, Color, Specs, Portion)
            _buildVariantSelectorSection(context, currentProduct),

            // Store / Vendor info banner
            if (currentProduct.storeName != null &&
                currentProduct.storeName!.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: defaultPadding / 2,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.storefront_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Sold & Fulfilled by",
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                currentProduct.storeName!,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF00C853),
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Shipping Information
            ProductListTile(
              svgSrc: "assets/icons/Delivery.svg",
              title: "⚡ Express 10-15 Mins Delivery Info",
              press: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Free delivery on orders above ₹250. Express 10-15 mins delivery."),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),

            // Returns Info
            ProductListTile(
              svgSrc: "assets/icons/Return.svg",
              title: "Easy 7-Day Free Returns",
              isShowBottomBorder: true,
              press: () {
                customModalBottomSheet(
                  context,
                  height: MediaQuery.of(context).size.height * 0.92,
                  child: const ProductReturnsScreen(),
                );
              },
            ),

            // Reviews Summary Rating Card
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(defaultPadding),
                child: ReviewCard(
                  rating: 4.8,
                  numOfReviews: 128,
                  numOfFiveStar: 82,
                  numOfFourStar: 32,
                  numOfThreeStar: 10,
                  numOfTwoStar: 3,
                  numOfOneStar: 1,
                ),
              ),
            ),

            // Reviews List Tile
            ProductListTile(
              svgSrc: "assets/icons/Chat.svg",
              title: "Customer Reviews & Ratings (128)",
              isShowBottomBorder: true,
              press: () {
                Navigator.pushNamed(
                  context,
                  productReviewsScreenRoute,
                  arguments: {
                    "title": currentProduct.title,
                    "brand": currentProduct.brandName,
                    "image": currentProduct.image,
                    "rating": 4.8,
                  },
                );
              },
            ),

            // Recommendations Header & Horizontal List
            Builder(
              builder: (context) {
                final HomeScreenApiController? homeController =
                    Get.isRegistered<HomeScreenApiController>()
                        ? Get.find<HomeScreenApiController>()
                        : null;
                final liveItems = (homeController != null &&
                        homeController.allProducts.isNotEmpty)
                    ? homeController.allProducts
                        .where((p) => !p.isFood && p.id != currentProduct.id)
                        .map((p) => p.toProductModel())
                        .toList()
                    : <ProductModel>[];

                final displayList = liveItems.isNotEmpty
                    ? liveItems
                    : (homeController != null &&
                            homeController.newArrivalsProducts.isNotEmpty
                        ? homeController.newArrivalsProducts
                            .where((p) =>
                                !p.isFood && p.id != currentProduct.id)
                            .map((p) => p.toProductModel())
                            .toList()
                        : <ProductModel>[]);

                if (displayList.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }

                return SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(defaultPadding),
                        child: Text(
                          "You May Also Like",
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final item = displayList[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                left: defaultPadding,
                                right: index == displayList.length - 1
                                    ? defaultPadding
                                    : 0,
                              ),
                              child: ProductCard(
                                id: item.id,
                                shopId: item.shopId,
                                storeDomain: item.storeDomain,
                                discountAmount: item.discountAmount,
                                variant: item.variant,
                                color: item.color,
                                choices: item.choices,
                                image: item.image,
                                title: item.title,
                                brandName: item.brandName,
                                price: item.price,
                                priceAfetDiscount: item.priceAfetDiscount,
                                dicountpercent: item.dicountpercent,
                                press: () {
                                  Navigator.pushNamed(
                                    context,
                                    productDetailsScreenRoute,
                                    arguments: item,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: defaultPadding * 2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantSelectorSection(BuildContext context, ProductModel product) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoadingVariants) {
      return SliverToBoxAdapter(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1D2B) : const Color(0xFFF9F9FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFECECF2),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  "Fetching product variations...",
                  style: TextStyle(
                    fontSize: 12,
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 1. If live API variant details are available
    if (_variantDetails != null) {
      final hasChoices = _variantDetails!.choiceOptions.isNotEmpty;
      final hasColors = _variantDetails!.colors.isNotEmpty;
      final hasVariations =
          _variantDetails!.hasVariations || hasChoices || hasColors;

      if (!hasVariations) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      final activePrice = _selectedVariationItem?.price ??
          (product.priceAfetDiscount ?? product.price);
      final activeMrp = _selectedVariationItem?.mrp;
      final activeDiscount = _selectedVariationItem?.discount;

      return SliverToBoxAdapter(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1F1D2B) : const Color(0xFFF9F9FC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white12 : const Color(0xFFECECF2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Selected Variant pill and live variation price
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Selected Variation",
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white70
                                : const Color(0xFF6B6B78),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            Text(
                              "₹${activePrice.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            ),
                            if (activeMrp != null && activeMrp > activePrice) ...[
                              const SizedBox(width: 6),
                              Text(
                                "₹${activeMrp.toStringAsFixed(0)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: isDark
                                      ? Colors.white38
                                      : Colors.grey.shade500,
                                ),
                              ),
                            ],
                            if (activeDiscount != null && activeDiscount > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  "-${activeDiscount.toStringAsFixed(0)}%",
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        (_selectedVariant != null &&
                                _selectedVariant!.trim().isNotEmpty)
                            ? _selectedVariant!
                            : "Standard",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Choice Options (e.g. Size, Storage, RAM, etc.)
                for (var choice in _variantDetails!.choiceOptions) ...[
                  Text(
                    choice.title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: choice.options.map((opt) {
                      final isSelected =
                          (_selectedChoices[choice.title] ?? '') == opt;
                      return InkWell(
                        onTap: () => _onChoiceSelected(choice.title, opt),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : (isDark
                                    ? const Color(0xFF2A2838)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : (isDark
                                      ? Colors.white24
                                      : const Color(0xFFDCDCE4)),
                              width: 1.2,
                            ),
                          ),
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                ],

                // Colors
                if (hasColors) ...[
                  Text(
                    "Color",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _variantDetails!.colors.map((col) {
                      final isSelected = (_selectedColor ?? '')
                              .trim()
                              .toLowerCase() ==
                          col.name.trim().toLowerCase();
                      final parsedColor = _parseColorCode(col.code);
                      return InkWell(
                        onTap: () => _onColorSelected(col.name),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? primaryColor
                                : (isDark
                                    ? const Color(0xFF2A2838)
                                    : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? primaryColor
                                  : (isDark
                                      ? Colors.white24
                                      : const Color(0xFFDCDCE4)),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (parsedColor != null) ...[
                                Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: parsedColor,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                      width: 0.8,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                col.name,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],

                // Stock & SKU status badges
                if (_selectedVariationItem != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (_selectedVariationItem!.stock != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: successColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 12, color: successColor),
                              const SizedBox(width: 4),
                              Text(
                                "${_selectedVariationItem!.stock} in stock",
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: successColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (_selectedVariationItem!.sku != null &&
                          _selectedVariationItem!.sku!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Text(
                          "SKU: ${_selectedVariationItem!.sku!}",
                          style: TextStyle(
                            fontSize: 10.5,
                            color:
                                isDark ? Colors.white54 : Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    }

    // 2. Fallback heuristic for offline / demo products
    final availableSizes = product.getAvailableSizes();
    final availableColors = product.getAvailableColors();
    final availableVariants = product.getAvailableVariants();

    final bool hasSizes = availableSizes.isNotEmpty;
    final bool hasColors = availableColors.isNotEmpty;
    final bool hasVariants = availableVariants.isNotEmpty && !hasSizes;

    if (!hasSizes && !hasColors && !hasVariants) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1F1D2B) : const Color(0xFFF9F9FC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white12 : const Color(0xFFECECF2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Active selected variant header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Selected Variation",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : const Color(0xFF6B6B78),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _selectedVariant ?? product.getDefaultVariant(),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Sizes (If Apparel or Shoes)
              if (hasSizes) ...[
                Text(
                  "Size",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableSizes.map((size) {
                    final isSelected = (_selectedSize ?? '') == size;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedSize = size;
                          _updateVariantForApparel(product);
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                  ? const Color(0xFF2A2838)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : (isDark
                                    ? Colors.white24
                                    : const Color(0xFFDCDCE4)),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          size,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
              ],

              // Colors (If applicable)
              if (hasColors) ...[
                Text(
                  "Color",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableColors.map((col) {
                    final isSelected = (_selectedColor ?? '') == col;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = col;
                          if (hasSizes) {
                            _updateVariantForApparel(product);
                          } else {
                            _selectedVariant = col;
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                  ? const Color(0xFF2A2838)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : (isDark
                                    ? Colors.white24
                                    : const Color(0xFFDCDCE4)),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          col,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Variant Specs (RAM/Storage for Mobiles, Portions for Food, etc.)
              if (hasVariants) ...[
                Text(
                  product.isFood ? "Portion / Pack" : "Specs / Variant",
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableVariants.map((v) {
                    final isSelected =
                        (_selectedVariant ?? product.getDefaultVariant()) == v;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedVariant = v;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryColor
                              : (isDark
                                  ? const Color(0xFF2A2838)
                                  : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? primaryColor
                                : (isDark
                                    ? Colors.white24
                                    : const Color(0xFFDCDCE4)),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          v,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
