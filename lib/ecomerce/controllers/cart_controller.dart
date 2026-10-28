import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';
import '../models/coupon_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import 'package:get/get.dart';
import 'categories_controller.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final String? storeDomain;
  final String? variant;
  final String? color;
  final Map<String, dynamic>? choices;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    this.storeDomain,
    this.variant,
    this.color,
    this.choices,
  });

  String get effectiveVariant =>
      (variant != null && variant!.trim().isNotEmpty)
          ? variant!.trim()
          : product.getDefaultVariant();

  String? get effectiveColor =>
      (color != null && color!.trim().isNotEmpty)
          ? color!.trim()
          : product.getDefaultColor();

  Map<String, dynamic> get effectiveChoices =>
      (choices != null && choices!.isNotEmpty)
          ? choices!
          : product.getDefaultChoices();

  String? get domain => storeDomain ?? product.storeDomain;
  double get unitPrice => product.priceAfetDiscount ?? product.price;
  double get totalPrice => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'product': product.toJson(),
        'quantity': quantity,
        'storeDomain': storeDomain ?? product.storeDomain,
        'variant': effectiveVariant,
        'color': effectiveColor,
        'choices': effectiveChoices,
      };

  Map<String, dynamic> toOrderItemJson({String? fallbackDomain}) {
    final effectiveDomain = domain ?? fallbackDomain ?? 'e-team-12';

    // Resolve category details with fallbacks so database always receives category info
    int? catId = product.categoryId;
    String? catName = product.categoryName;
    String? catSlug = product.categorySlug;
    String? catType = product.categoryType;

    if (catId == null || catId == 0) {
      try {
        if (Get.isRegistered<CategoriesController>()) {
          final catCtrl = Get.find<CategoriesController>();
          final match = catCtrl.categories.firstWhereOrNull((c) =>
              (product.categorySlug != null && c.slug == product.categorySlug) ||
              (product.categoryName != null && c.name.toLowerCase() == product.categoryName!.toLowerCase()) ||
              (effectiveDomain.isNotEmpty && c.store?.domain == effectiveDomain));
          if (match != null) {
            catId = match.id;
            catName = match.name;
            catSlug = match.slug;
            catType = match.categoryType;
          }
        }
      } catch (_) {}
    }

    // Default fallback category if none detected
    catId ??= 146; // Default active category id (Electronics)
    catName ??= 'Electronics';
    catSlug ??= 'electronics';
    catType ??= 'ecommerce';

    final categoryMap = {
      'id': catId,
      'name': catName,
      'slug': catSlug,
      'category_type': catType,
    };

    final String itemVariant = effectiveVariant;
    final String? itemColor = effectiveColor;
    final Map<String, dynamic> itemChoices = effectiveChoices;

    return {
      'id': product.id,
      'product_id': product.id,
      'name': product.title,
      'title': product.title,
      'image': product.image,
      'thumbnail': product.image,
      'price': unitPrice,
      'unit_price': product.price,
      'price_after_discount': product.priceAfetDiscount ?? product.price,
      'discount': product.discountAmount ?? 0,
      'discount_percent': product.dicountpercent ?? 0,
      'quantity': quantity,
      'total_price': totalPrice,
      'domain': effectiveDomain,
      'store_domain': effectiveDomain,
      'shop_id': product.shopId ?? 1,
      'store_id': product.storeId,
      'store_name': product.storeName,
      // Variant & Variation matching backend order_details table
      'variant': itemVariant,
      'variation': itemVariant,
      'variations': itemVariant,
      if (itemColor != null) 'color': itemColor,
      'choices': itemChoices,
      'choice_options': itemChoices,
      // Category details for database categorization
      'category_id': catId,
      'category_name': catName,
      'category_slug': catSlug,
      'category_type': catType,
      'category': categoryMap,
      'product_details': {
        ...product.toJson(),
        'variant': itemVariant,
        'variation': itemVariant,
        if (itemColor != null) 'color': itemColor,
        'choices': itemChoices,
        'category_id': catId,
        'category_name': catName,
        'category_slug': catSlug,
        'category_type': catType,
        'category': categoryMap,
        'domain': effectiveDomain,
      },
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final prod = ProductModel.fromJson(
        Map<String, dynamic>.from(json['product'] as Map? ?? {}));
    var parsedVariant = json['variant'] as String? ?? prod.variant;
    // Auto-fix stale cached "8 GB, 500 GB" on non-phone products
    if (parsedVariant == "8 GB, 500 GB" &&
        !prod.title.toLowerCase().contains("phone") &&
        !prod.title.toLowerCase().contains("mobile")) {
      parsedVariant = prod.getDefaultVariant();
    }
    return CartItemModel(
      product: prod,
      quantity: json['quantity'] as int? ?? 1,
      storeDomain: json['storeDomain'] as String?,
      variant: parsedVariant,
      color: json['color'] as String? ?? prod.getDefaultColor(),
      choices: json['choices'] != null
          ? Map<String, dynamic>.from(json['choices'] as Map)
          : prod.getDefaultChoices(),
    );
  }
}

class CartController extends ChangeNotifier {
  static const String _cartStorageKey = 'ecommerce_cart_items_v2';

  // Singleton instance for global access across the app
  static final CartController instance = CartController._internal();

  CartController._internal() {
    _loadCartFromPrefs();
  }

  final List<CartItemModel> _items = [];
  CouponModel? _appliedCoupon;
  double _appliedDiscount = 0.0;
  String? _appliedCouponCode;
  bool _isLoaded = false;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoaded => _isLoaded;

  CouponModel? get appliedCoupon => _appliedCoupon;
  bool get hasCoupon => _appliedCoupon != null;
  double get appliedDiscountAmount => _appliedDiscount;
  String? get appliedCouponCode => _appliedCouponCode;

  /// Generate detailed order items payload including category, product details and domain
  List<Map<String, dynamic>> getOrderItemsPayload({String? fallbackDomain}) {
    return _items
        .map((item) => item.toOrderItemJson(fallbackDomain: fallbackDomain))
        .toList();
  }

  /// Load persisted cart from SharedPreferences
  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString(_cartStorageKey);
      if (savedJson != null && savedJson.isNotEmpty) {
        final List decoded = jsonDecode(savedJson);
        _items.clear();
        for (final item in decoded) {
          try {
            _items.add(
                CartItemModel.fromJson(Map<String, dynamic>.from(item as Map)));
          } catch (e) {
            debugPrint("CartController: error parsing item: $e");
          }
        }
      }
    } catch (e) {
      debugPrint("CartController _loadCartFromPrefs error: $e");
    } finally {
      _isLoaded = true;
      notifyListeners();
    }
  }

  /// Save current cart to SharedPreferences
  Future<void> _saveCartToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((i) => i.toJson()).toList();
      await prefs.setString(_cartStorageKey, jsonEncode(list));
    } catch (e) {
      debugPrint("CartController _saveCartToPrefs error: $e");
    }
  }

  int get totalItemCount {
    int count = 0;
    for (var item in _items) {
      count += item.quantity;
    }
    return count;
  }

  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += item.totalPrice;
    }
    return total;
  }

  double get deliveryFee {
    if (_items.isEmpty) return 0.0;
    if (_appliedCoupon != null &&
        _appliedCoupon!.isFreeDelivery &&
        subtotal >= _appliedCoupon!.minOrderValue) {
      return 0.0;
    }
    return subtotal > 25.0 ? 0.0 : 1.99;
  }

  double get discountAmount {
    if (_appliedDiscount > 0) return _appliedDiscount;
    if (_appliedCoupon == null) return 0.0;
    final discount = _appliedCoupon!.calculateDiscount(subtotal);
    return discount;
  }

  double get grandTotal =>
      (subtotal + deliveryFee - discountAmount).clamp(0.0, double.infinity);

  /// Total money saved by user (discounts + free delivery waiver if applicable)
  double get totalSavings {
    double saved = discountAmount;
    if (subtotal <= 25.0 &&
        _appliedCoupon != null &&
        _appliedCoupon!.isFreeDelivery) {
      saved += 1.99;
    }
    return saved;
  }

  /// Unique domains across all products in the cart (for multi-vendor management)
  List<String> get uniqueDomains {
    final domains = <String>{};
    for (var item in _items) {
      final d = item.domain;
      if (d != null && d.isNotEmpty) {
        domains.add(d);
      }
    }
    return domains.toList();
  }

  /// Unique stores across all products in the cart
  List<String> get uniqueStoreNames {
    final stores = <String>{};
    for (var item in _items) {
      final s = item.product.storeName;
      if (s != null && s.isNotEmpty) {
        stores.add(s);
      }
    }
    return stores.toList();
  }

  /// Group cart items by domain
  Map<String, List<CartItemModel>> get itemsGroupedByDomain {
    final map = <String, List<CartItemModel>>{};
    for (var item in _items) {
      final key = item.domain ?? 'e-team-12';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Group cart items by store name (UI friendly)
  Map<String, List<CartItemModel>> get itemsGroupedByStore {
    final map = <String, List<CartItemModel>>{};
    for (var item in _items) {
      final key = item.product.storeName ?? 'Store';
      map.putIfAbsent(key, () => []).add(item);
    }
    return map;
  }

  /// Applies a coupon if eligible. Returns an error string if ineligible, null on success.
  String? applyCoupon(CouponModel coupon) {
    if (subtotal < coupon.minOrderValue) {
      final needed = coupon.minOrderValue - subtotal;
      return "Add ₹${needed.toStringAsFixed(2)} more to use ${coupon.code}";
    }
    _appliedCoupon = coupon;
    notifyListeners();
    return null;
  }

  /// Applies a coupon by text code via API. Returns error message or null if successfully applied.
  Future<String?> applyCouponByCode(String code) async {
    final cleanCode = code.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return "Please enter a promo code";
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? prefs.getString('user_app_token') ?? '';
      final d = 'e-team-12';
      int sId = 1;
      if (_items.isNotEmpty) {
        sId = _items.first.product.storeId ?? 1;
      }
      final url = Uri.parse('${ecomBaseUrl}coupons/apply');
      final res = await http.Client().post(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'domain': d,
          'coupon_code': cleanCode,
          'subtotal': subtotal,
          'shop_id': sId,
        }),
      );
      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body);
        if (decoded['status'] == true) {
          final data = decoded['data'] ?? {};
          _appliedDiscount = (data['discount_amount'] as num?)?.toDouble() ?? 0.0;
          _appliedCouponCode = data['coupon_code']?.toString() ?? cleanCode;
          _appliedCoupon = CouponModel(
            id: data['coupon_id']?.toString() ?? cleanCode,
            code: _appliedCouponCode!,
            title: data['coupon_title']?.toString() ?? cleanCode,
            description: decoded['message']?.toString() ?? '',
            discountType: (data['discount_type']?.toString() == 'percentage') ? CouponType.percentage : CouponType.flat,
            discountValue: (data['discount_value'] as num?)?.toDouble() ?? _appliedDiscount,
            minOrderValue: (data['min_purchase'] as num?)?.toDouble() ?? 0.0,
            maxDiscountAmount: (data['max_discount'] as num?)?.toDouble(),
            expiryDate: '',
            terms: '',
          );
          notifyListeners();
          return null;
        }
        return decoded['message']?.toString() ?? 'Failed to apply coupon';
      }
    } catch (e) {
      debugPrint('applyCouponByCode error: $e');
    }
    return "Failed to apply coupon";
  }

  /// Removes the currently applied coupon
  void removeCoupon() {
    _appliedCoupon = null;
    _appliedDiscount = 0.0;
    _appliedCouponCode = null;
    notifyListeners();
  }

  /// Checks if a cart item matches a given product and domain and optional variant
  bool _matchesProduct(CartItemModel item, ProductModel p, String? domain, {String? variant}) {
    final matchesId = (item.product.id != null && p.id != null)
        ? (item.product.id == p.id)
        : (item.product.title.trim().toLowerCase() ==
            p.title.trim().toLowerCase());

    final itemDomain = item.domain ?? '';
    final targetDomain = domain ?? p.storeDomain ?? '';
    final matchesDomain = targetDomain.isEmpty ||
        itemDomain.isEmpty ||
        itemDomain.toLowerCase() == targetDomain.toLowerCase();

    final matchesVariant = variant == null ||
        item.effectiveVariant.trim().toLowerCase() == variant.trim().toLowerCase();

    return matchesId && matchesDomain && matchesVariant;
  }

  int getQuantity(ProductModel product, {String? storeDomain, String? variant}) {
    final index = _items.indexWhere(
        (item) => _matchesProduct(item, product, storeDomain, variant: variant));
    if (index != -1) {
      return _items[index].quantity;
    }
    return 0;
  }

  /// Add item to cart locally & sync with backend asynchronously
  void addToCart(
    ProductModel product, {
    int quantity = 1,
    String? storeDomain,
    String? variant,
    String? color,
    Map<String, dynamic>? choices,
  }) {
    final effectiveDomain = storeDomain ?? product.storeDomain ?? 'e-team-12';
    final productVariant = (variant != null && variant.trim().isNotEmpty)
        ? variant.trim()
        : product.getDefaultVariant();
    final productColor = (color != null && color.trim().isNotEmpty)
        ? color.trim()
        : product.getDefaultColor();
    final productChoices = (choices != null && choices.isNotEmpty)
        ? choices
        : product.getDefaultChoices();

    final index = _items.indexWhere(
        (item) => _matchesProduct(item, product, effectiveDomain, variant: productVariant));

    if (index != -1) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItemModel(
        product: product,
        quantity: quantity,
        storeDomain: effectiveDomain,
        variant: productVariant,
        color: productColor,
        choices: productChoices,
      ));
    }

    _saveCartToPrefs();
    notifyListeners();

    // Call live backend cart add API asynchronously in background
    final productId = product.id ?? 1;
    final shopId = product.shopId ?? 1;

    CartService().addToCart(
      domain: effectiveDomain,
      productId: productId,
      shopId: shopId,
      quantity: quantity,
      variant: productVariant,
      color: productColor,
      choices: productChoices,
    );
  }

  void increaseQuantity(ProductModel product, {String? storeDomain, String? variant}) {
    addToCart(product, quantity: 1, storeDomain: storeDomain, variant: variant);
  }

  void decreaseQuantity(ProductModel product, {String? storeDomain, String? variant}) {
    final effectiveDomain = storeDomain ?? product.storeDomain;
    final index = _items.indexWhere(
        (item) => _matchesProduct(item, product, effectiveDomain, variant: variant));
    if (index != -1) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].quantity -= 1;
      }
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void updateQuantity(ProductModel product, int newQuantity,
      {String? storeDomain, String? variant}) {
    final effectiveDomain = storeDomain ?? product.storeDomain;
    final index = _items.indexWhere(
        (item) => _matchesProduct(item, product, effectiveDomain, variant: variant));
    if (index != -1) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      _saveCartToPrefs();
      notifyListeners();
    }
  }

  void removeFromCart(ProductModel product, {String? storeDomain}) {
    final effectiveDomain = storeDomain ?? product.storeDomain;
    _items.removeWhere(
        (item) => _matchesProduct(item, product, effectiveDomain));
    _saveCartToPrefs();
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    _appliedCoupon = null;
    _appliedDiscount = 0.0;
    _appliedCouponCode = null;
    _saveCartToPrefs();
    notifyListeners();
  }
}
