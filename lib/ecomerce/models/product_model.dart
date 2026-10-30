// For demo only

class ProductModel {
  final String image, brandName, title;
  final double price;
  final double? priceAfetDiscount;
  final int? dicountpercent;
  final double? discountAmount;
  final String? storeName;
  final String? storeDomain;
  final int? shopId;
  final int? storeId;
  final String? storeSlug;
  final int? id;
  final String? variant;
  final String? color;
  final Map<String, dynamic>? choices;
  final int? categoryId;
  final String? categoryName;
  final String? categorySlug;
  final String? categoryType;
  final double? tax;
  final String? taxType;

  ProductModel({
    required this.image,
    required this.brandName,
    required this.title,
    required this.price,
    this.priceAfetDiscount,
    this.dicountpercent,
    this.discountAmount,
    this.storeName,
    this.storeDomain,
    this.shopId,
    this.storeId,
    this.storeSlug,
    this.id,
    this.variant,
    this.color,
    this.choices,
    this.categoryId,
    this.categoryName,
    this.categorySlug,
    this.categoryType,
    this.tax,
    this.taxType,
  });

  bool get isFood {
    final type = (categoryType ?? '').toLowerCase();
    if (type == 'food') return true;
    final catName = (categoryName ?? '').toLowerCase();
    final catSlug = (categorySlug ?? '').toLowerCase();
    final titleLower = title.toLowerCase();
    if (catName.contains('food') ||
        catName.contains('restaurant') ||
        catName.contains('dining') ||
        catName.contains('grocery') ||
        catSlug.contains('food') ||
        catSlug.contains('restaurant') ||
        catSlug.contains('grocery')) {
      return true;
    }
    const foodKeywords = [
      'paneer',
      'pizza',
      'burger',
      'sandwich',
      'biryani',
      'masala',
      'dal ',
      'roti',
      'naan',
      'curry',
      'chicken butter',
      'thali',
      'noodles',
      'fried rice',
      'dosa',
      'idli',
      'samosa',
      'momo',
      'beverage',
      'shake',
      'juice',
      'coffee',
      'tea'
    ];
    for (final kw in foodKeywords) {
      if (titleLower.contains(kw)) return true;
    }
    return false;
  }

  /// Returns appropriate default variant based on product type, title and category
  String getDefaultVariant() {
    if (variant != null && variant!.trim().isNotEmpty) {
      return variant!.trim();
    }

    final titleLower = title.toLowerCase();
    final catNameLower = (categoryName ?? '').toLowerCase();
    final catSlugLower = (categorySlug ?? '').toLowerCase();

    // 1. Mobile Phone & Smartphones
    if (titleLower.contains('mobile') ||
        titleLower.contains('phone') ||
        titleLower.contains('iphone') ||
        titleLower.contains('samsung') ||
        titleLower.contains('smartphone') ||
        catNameLower.contains('mobile') ||
        catSlugLower.contains('mobile')) {
      return "8 GB, 128 GB";
    }

    // 2. Electronics / Laptops
    if (titleLower.contains('laptop') ||
        titleLower.contains('macbook') ||
        titleLower.contains('pc') ||
        titleLower.contains('computer')) {
      return "16 GB, 512 GB SSD";
    }

    // 3. Audio / Watches
    if (titleLower.contains('watch') ||
        titleLower.contains('earbuds') ||
        titleLower.contains('airpods') ||
        titleLower.contains('headphone')) {
      return "Midnight Black";
    }

    // 4. Jeans / Pants / Trousers / Bottoms
    if (titleLower.contains('jean') ||
        titleLower.contains('pant') ||
        titleLower.contains('trouser') ||
        titleLower.contains('denim')) {
      return "32, Blue";
    }

    // 5. T-Shirts / Shirts / Hoodies / Jackets / Fashion
    if (titleLower.contains('t-shirt') ||
        titleLower.contains('t-shart') ||
        titleLower.contains('shirt') ||
        titleLower.contains('hoodie') ||
        titleLower.contains('jacket') ||
        titleLower.contains('kurta') ||
        catNameLower.contains('fashion') ||
        catNameLower.contains('apparel') ||
        catSlugLower.contains('fashion')) {
      return "M, Black";
    }

    // 6. Shoes / Footwear
    if (titleLower.contains('shoe') ||
        titleLower.contains('sneaker') ||
        titleLower.contains('boot') ||
        titleLower.contains('sandal')) {
      return "UK 8";
    }

    // 7. Food & Dining
    if (isFood ||
        catNameLower.contains('food') ||
        catNameLower.contains('restaurant') ||
        titleLower.contains('naan') ||
        titleLower.contains('roti') ||
        titleLower.contains('paneer') ||
        titleLower.contains('biryani') ||
        titleLower.contains('thali')) {
      return "Regular";
    }

    // 8. Groceries
    if (catNameLower.contains('grocery') ||
        titleLower.contains('oil') ||
        titleLower.contains('atta')) {
      return "1 kg";
    }

    return "Standard";
  }

  /// Returns appropriate default color
  String? getDefaultColor() {
    if (color != null && color!.trim().isNotEmpty) {
      return color!.trim();
    }
    final titleLower = title.toLowerCase();
    if (titleLower.contains('jean') || titleLower.contains('denim')) {
      return "Blue";
    }
    if (titleLower.contains('t-shirt') ||
        titleLower.contains('t-shart') ||
        titleLower.contains('shirt')) {
      return "Black";
    }
    if (titleLower.contains('mobile') || titleLower.contains('phone')) {
      return "Phantom Black";
    }
    if (titleLower.contains('shoe') || titleLower.contains('sneaker')) {
      return "White";
    }
    return null;
  }

  /// Returns appropriate default choices map
  Map<String, dynamic> getDefaultChoices() {
    if (choices != null && choices!.isNotEmpty) {
      return choices!;
    }

    final titleLower = title.toLowerCase();
    final catNameLower = (categoryName ?? '').toLowerCase();
    final catSlugLower = (categorySlug ?? '').toLowerCase();

    if (titleLower.contains('mobile') ||
        titleLower.contains('phone') ||
        catNameLower.contains('mobile') ||
        catSlugLower.contains('mobile')) {
      return {"RAM": "8 GB", "Storage": "128 GB"};
    }

    if (titleLower.contains('jean') ||
        titleLower.contains('pant') ||
        titleLower.contains('trouser')) {
      return {"Size": "32", "Color": "Blue"};
    }

    if (titleLower.contains('t-shirt') ||
        titleLower.contains('t-shart') ||
        titleLower.contains('shirt') ||
        titleLower.contains('hoodie') ||
        catNameLower.contains('fashion') ||
        catNameLower.contains('apparel')) {
      return {"Size": "M", "Color": "Black"};
    }

    if (titleLower.contains('shoe') || titleLower.contains('sneaker')) {
      return {"Size": "UK 8"};
    }

    if (isFood ||
        catNameLower.contains('food') ||
        titleLower.contains('naan') ||
        titleLower.contains('biryani')) {
      return {"Portion": "Regular"};
    }

    return {"Variant": "Standard"};
  }

  /// Available sizes for the product (if applicable)
  List<String> getAvailableSizes() {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('jean') ||
        titleLower.contains('pant') ||
        titleLower.contains('trouser')) {
      return const ["30", "32", "34", "36", "38"];
    }
    if (titleLower.contains('shoe') ||
        titleLower.contains('sneaker') ||
        titleLower.contains('boot')) {
      return const ["UK 7", "UK 8", "UK 9", "UK 10", "UK 11"];
    }
    if (titleLower.contains('t-shirt') ||
        titleLower.contains('t-shart') ||
        titleLower.contains('shirt') ||
        titleLower.contains('hoodie') ||
        titleLower.contains('jacket') ||
        (categoryName ?? '').toLowerCase().contains('fashion')) {
      return const ["S", "M", "L", "XL", "XXL"];
    }
    return const [];
  }

  /// Available colors for the product (if applicable)
  List<String> getAvailableColors() {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('jean') || titleLower.contains('denim')) {
      return const ["Blue", "Dark Blue", "Black"];
    }
    if (titleLower.contains('t-shirt') ||
        titleLower.contains('t-shart') ||
        titleLower.contains('shirt') ||
        titleLower.contains('hoodie') ||
        (categoryName ?? '').toLowerCase().contains('fashion')) {
      return const ["Black", "White", "Navy Blue", "Grey"];
    }
    if (titleLower.contains('mobile') || titleLower.contains('phone')) {
      return const ["Phantom Black", "Mystic Silver", "Midnight Blue"];
    }
    if (titleLower.contains('shoe') || titleLower.contains('sneaker')) {
      return const ["White", "Black", "Grey"];
    }
    return const [];
  }

  /// Available variant specs (e.g. RAM/Storage for mobile, portions for food)
  List<String> getAvailableVariants() {
    final titleLower = title.toLowerCase();
    if (titleLower.contains('mobile') ||
        titleLower.contains('phone') ||
        (categoryName ?? '').toLowerCase().contains('mobile')) {
      return const [
        "6 GB, 128 GB",
        "8 GB, 128 GB",
        "8 GB, 256 GB",
        "12 GB, 256 GB"
      ];
    }
    if (titleLower.contains('laptop') || titleLower.contains('macbook')) {
      return const ["8 GB, 256 GB SSD", "16 GB, 512 GB SSD", "16 GB, 1 TB SSD"];
    }
    if (isFood ||
        titleLower.contains('naan') ||
        titleLower.contains('roti') ||
        titleLower.contains('paneer') ||
        titleLower.contains('biryani')) {
      if (titleLower.contains('naan') || titleLower.contains('roti')) {
        return const ["1 Piece", "2 Pieces", "Basket of 4"];
      }
      return const ["Regular", "Large"];
    }
    if (titleLower.contains('jean') || titleLower.contains('pant')) {
      return const ["30, Blue", "32, Blue", "34, Dark Blue", "36, Black"];
    }
    if (titleLower.contains('t-shirt') ||
        titleLower.contains('t-shart') ||
        titleLower.contains('shirt')) {
      return const ["S, Black", "M, Black", "L, Navy Blue", "XL, White"];
    }
    return const ["Standard"];
  }

  Map<String, dynamic> toJson() => {
        'image': image,
        'brandName': brandName,
        'title': title,
        'price': price,
        'priceAfetDiscount': priceAfetDiscount,
        'dicountpercent': dicountpercent,
        'discountAmount': discountAmount,
        'storeName': storeName,
        'storeDomain': storeDomain,
        'shopId': shopId,
        'storeId': storeId,
        'storeSlug': storeSlug,
        'id': id,
        'variant': variant,
        'color': color,
        'choices': choices,
        'categoryId': categoryId,
        'categoryName': categoryName,
        'categorySlug': categorySlug,
        'categoryType': categoryType,
        'category_id': categoryId,
        'category_name': categoryName,
        'category_slug': categorySlug,
        'category_type': categoryType,
        'tax': tax,
        'taxType': taxType,
      };

  factory ProductModel.fromJson(Map<String, dynamic> json) => ProductModel(
        image: json['image'] as String? ?? '',
        brandName: json['brandName'] as String? ?? '',
        title: json['title'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        priceAfetDiscount: (json['priceAfetDiscount'] as num?)?.toDouble(),
        dicountpercent: json['dicountpercent'] as int?,
        discountAmount: (json['discountAmount'] as num?)?.toDouble(),
        tax: (json['tax'] as num?)?.toDouble(),
        taxType: json['tax_type']?.toString() ?? json['taxType']?.toString(),
        storeName: json['storeName'] as String?,
        storeDomain: json['storeDomain'] as String?,
        shopId: json['shopId'] as int?,
        storeId: json['storeId'] as int?,
        storeSlug: json['storeSlug'] as String?,
        id: json['id'] as int?,
        variant: json['variant'] as String?,
        color: json['color'] as String?,
        choices: json['choices'] != null
            ? Map<String, dynamic>.from(json['choices'] as Map)
            : null,
        categoryId: json['categoryId'] as int? ??
            (json['category_id'] is int
                ? json['category_id'] as int
                : int.tryParse(json['category_id']?.toString() ??
                    (json['category'] is Map
                        ? json['category']['id']?.toString() ?? ''
                        : ''))),
        categoryName: json['categoryName'] as String? ??
            json['category_name'] as String? ??
            (json['category'] is Map
                ? json['category']['name'] as String?
                : null),
        categorySlug: json['categorySlug'] as String? ??
            json['category_slug'] as String? ??
            (json['category'] is Map
                ? json['category']['slug'] as String?
                : null),
        categoryType: json['categoryType'] as String? ??
            json['category_type'] as String? ??
            (json['category'] is Map
                ? json['category']['category_type'] as String?
                : null),
      );
}

List<ProductModel> demoBestSellersProducts = [
  ProductModel(
    image: "https://i.imgur.com/tXyOMMG.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 390.36,
    dicountpercent: 40,
  ),
  ProductModel(
    image: "https://i.imgur.com/h2LqppX.png",
    title: "white satin corset top",
    brandName: "Lipsy london",
    price: 1264,
    priceAfetDiscount: 1200.8,
    dicountpercent: 5,
  ),
];
List<ProductModel> kidsProducts = [
  ProductModel(
    image: "https://i.imgur.com/dbbT6PA.png",
    title: "Green Poplin Ruched Front",
    brandName: "Lipsy london",
    price: 650.62,
    priceAfetDiscount: 590.36,
    dicountpercent: 24,
  ),
  ProductModel(
    image: "https://i.imgur.com/7fSxC7k.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 650.62,
  ),
  ProductModel(
    image: "https://i.imgur.com/pXnYE9Q.png",
    title: "Ruffle-Sleeve Ponte-Knit Sheath ",
    brandName: "Lipsy london",
    price: 400,
  ),
  ProductModel(
    image: "https://i.imgur.com/V1MXgfa.png",
    title: "Green Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 400,
    priceAfetDiscount: 360,
    dicountpercent: 20,
  ),
  ProductModel(
    image: "https://i.imgur.com/8gvE5Ss.png",
    title: "Printed Sleeveless Tiered Swing Dress",
    brandName: "Lipsy london",
    price: 654,
  ),
  ProductModel(
    image: "https://i.imgur.com/cBvB5YB.png",
    title: "Mountain Beta Warehouse",
    brandName: "Lipsy london",
    price: 250,
  ),
];
