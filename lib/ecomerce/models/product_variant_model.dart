class ProductVariantDetailsModel {
  final int productId;
  final String name;
  final String? slug;
  final String? productType;
  final String? unit;
  final double? baseUnitPrice;
  final double? baseFinalPrice;
  final double? tax;
  final String? taxType;
  final String? taxModel;
  final int? totalStock;
  final bool inStock;
  final int minimumOrderQty;
  final int maxOrderQty;
  final bool hasVariations;
  final List<ChoiceOptionModel> choiceOptions;
  final List<VariantColorModel> colors;
  final List<ProductVariationItemModel> variations;
  final ProductVariationItemModel? defaultSelection;

  ProductVariantDetailsModel({
    required this.productId,
    required this.name,
    this.slug,
    this.productType,
    this.unit,
    this.baseUnitPrice,
    this.baseFinalPrice,
    this.tax,
    this.taxType,
    this.taxModel,
    this.totalStock,
    this.inStock = true,
    this.minimumOrderQty = 1,
    this.maxOrderQty = 10,
    this.hasVariations = false,
    this.choiceOptions = const [],
    this.colors = const [],
    this.variations = const [],
    this.defaultSelection,
  });

  factory ProductVariantDetailsModel.fromJson(Map<String, dynamic> json) {
    List<ChoiceOptionModel> choices = [];
    if (json['choice_options'] is List) {
      choices = (json['choice_options'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => ChoiceOptionModel.fromJson(c))
          .toList();
    }

    List<VariantColorModel> cols = [];
    if (json['colors'] is List) {
      cols = (json['colors'] as List)
          .whereType<Map<String, dynamic>>()
          .map((c) => VariantColorModel.fromJson(c))
          .toList();
    }

    List<ProductVariationItemModel> vars = [];
    if (json['variations'] is List) {
      vars = (json['variations'] as List)
          .whereType<Map<String, dynamic>>()
          .map((v) => ProductVariationItemModel.fromJson(v))
          .toList();
    }

    ProductVariationItemModel? defSelection;
    if (json['default_selection'] is Map<String, dynamic>) {
      defSelection = ProductVariationItemModel.fromJson(json['default_selection']);
    }

    return ProductVariantDetailsModel(
      productId: json['product_id'] is int
          ? json['product_id']
          : int.tryParse(json['product_id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      productType: json['product_type']?.toString(),
      unit: json['unit']?.toString(),
      baseUnitPrice: (json['base_unit_price'] as num?)?.toDouble(),
      baseFinalPrice: (json['base_final_price'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      taxType: json['tax_type']?.toString(),
      taxModel: json['tax_model']?.toString(),
      totalStock: json['total_stock'] is int
          ? json['total_stock']
          : int.tryParse(json['total_stock']?.toString() ?? ''),
      inStock: json['in_stock'] == true || json['in_stock'] == 1,
      minimumOrderQty: int.tryParse(json['minimum_order_qty']?.toString() ?? '') ?? 1,
      maxOrderQty: int.tryParse(json['max_order_qty']?.toString() ?? '') ?? 10,
      hasVariations: json['has_variations'] == true || json['has_variations'] == 1,
      choiceOptions: choices,
      colors: cols,
      variations: vars,
      defaultSelection: defSelection,
    );
  }

  ProductVariationItemModel? findVariation({
    String? color,
    String? size,
    Map<String, String>? selectedChoices,
  }) {
    if (variations.isEmpty) return defaultSelection;

    // 1. If single variation exists
    if (variations.length == 1) return variations.first;

    // 2. Direct match on color and size if specified
    for (var v in variations) {
      bool colorMatch = color == null ||
          color.isEmpty ||
          (v.color != null && v.color!.toLowerCase() == color.toLowerCase());
      bool sizeMatch = size == null ||
          size.isEmpty ||
          (v.size != null && v.size!.toLowerCase() == size.toLowerCase());
      if (colorMatch && sizeMatch && (v.color != null || v.size != null)) {
        return v;
      }
    }

    // 3. Match against choices values in variation variant string
    if (selectedChoices != null && selectedChoices.isNotEmpty) {
      final choiceValues = selectedChoices.values
          .map((e) => e.trim().toLowerCase())
          .where((e) => e.isNotEmpty)
          .toList();
      if (choiceValues.isNotEmpty) {
        for (var v in variations) {
          final target = '${v.variant} ${v.title ?? ''} ${v.type ?? ''}'.toLowerCase();
          bool allContained = choiceValues.every((val) => target.contains(val));
          if (allContained) return v;
        }
      }
    }

    return defaultSelection ?? variations.first;
  }
}

class ChoiceOptionModel {
  final String name;
  final String title;
  final List<String> options;

  ChoiceOptionModel({
    required this.name,
    required this.title,
    required this.options,
  });

  factory ChoiceOptionModel.fromJson(Map<String, dynamic> json) {
    List<String> opts = [];
    if (json['options'] is List) {
      opts = (json['options'] as List).map((o) => o.toString()).toList();
    }
    return ChoiceOptionModel(
      name: json['name']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      options: opts,
    );
  }
}

class VariantColorModel {
  final String name;
  final String? code;

  VariantColorModel({
    required this.name,
    this.code,
  });

  factory VariantColorModel.fromJson(Map<String, dynamic> json) {
    return VariantColorModel(
      name: json['name']?.toString() ?? '',
      code: json['code']?.toString(),
    );
  }
}

class ProductVariationItemModel {
  final String variant;
  final String? title;
  final String? type;
  final String? color;
  final String? colorCode;
  final String? size;
  final double? price;
  final double? mrp;
  final double? discount;
  final String? discountType;
  final int? stock;
  final bool inStock;
  final String? sku;
  final String? thumbnail;

  ProductVariationItemModel({
    required this.variant,
    this.title,
    this.type,
    this.color,
    this.colorCode,
    this.size,
    this.price,
    this.mrp,
    this.discount,
    this.discountType,
    this.stock,
    this.inStock = true,
    this.sku,
    this.thumbnail,
  });

  factory ProductVariationItemModel.fromJson(Map<String, dynamic> json) {
    return ProductVariationItemModel(
      variant: json['variant']?.toString() ?? json['type']?.toString() ?? '',
      title: json['title']?.toString(),
      type: json['type']?.toString(),
      color: json['color']?.toString(),
      colorCode: json['color_code']?.toString(),
      size: json['size']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      mrp: (json['mrp'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble(),
      discountType: json['discount_type']?.toString(),
      stock: json['stock'] is int
          ? json['stock']
          : int.tryParse(json['stock']?.toString() ?? ''),
      inStock: json['in_stock'] == true || json['in_stock'] == 1,
      sku: json['sku']?.toString(),
      thumbnail: json['thumbnail']?.toString(),
    );
  }
}
