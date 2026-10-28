class CategoryStoreModel {
  final int? id;
  final String? name;
  final String? domain;
  final String? companyName;

  CategoryStoreModel({
    this.id,
    this.name,
    this.domain,
    this.companyName,
  });

  factory CategoryStoreModel.fromJson(Map<String, dynamic> json) {
    return CategoryStoreModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString(),
      domain: json['domain']?.toString(),
      companyName: json['company_name']?.toString() ??
          json['companyName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'domain': domain,
      'company_name': companyName,
    };
  }
}

class CategoryModel {
  final int? id;
  final String name;
  final String? slug;
  final String? icon;
  final String? svgSrc;
  final String? route;
  final String? categoryType; // "ecommerce" or "food"
  final int? priority;
  final int? position;
  final int? parentId;
  final int? homeStatus;
  final int? subCategoriesCount;
  final int? productsCount;
  final List<CategoryModel>? subCategories;
  final CategoryStoreModel? store;

  CategoryModel({
    this.id,
    String? name,
    String? title,
    this.slug,
    String? icon,
    String? image,
    this.svgSrc,
    this.route,
    this.categoryType,
    this.priority,
    this.position,
    this.parentId,
    this.homeStatus,
    this.subCategoriesCount,
    this.productsCount,
    this.subCategories,
    this.store,
  })  : name = name ?? title ?? '',
        icon = icon ?? image;

  String get title => name;
  String? get image => icon;

  bool get isFood {
    final type = (categoryType ?? '').toLowerCase();
    if (type == 'food') return true;
    final nameLower = name.toLowerCase();
    final slugLower = (slug ?? '').toLowerCase();
    return nameLower.contains('food') ||
        nameLower.contains('restaurant') ||
        nameLower.contains('dining') ||
        nameLower.contains('grocery') ||
        nameLower.contains('fast food') ||
        nameLower.contains('meal') ||
        slugLower.contains('food') ||
        slugLower.contains('restaurant') ||
        slugLower.contains('grocery');
  }

  bool get isEcommerce => !isFood;

  CategoryModel copyWith({
    int? id,
    String? name,
    String? slug,
    String? icon,
    String? svgSrc,
    String? route,
    String? categoryType,
    int? priority,
    int? position,
    int? parentId,
    int? homeStatus,
    int? subCategoriesCount,
    int? productsCount,
    List<CategoryModel>? subCategories,
    CategoryStoreModel? store,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      icon: icon ?? this.icon,
      svgSrc: svgSrc ?? this.svgSrc,
      route: route ?? this.route,
      categoryType: categoryType ?? this.categoryType,
      priority: priority ?? this.priority,
      position: position ?? this.position,
      parentId: parentId ?? this.parentId,
      homeStatus: homeStatus ?? this.homeStatus,
      subCategoriesCount: subCategoriesCount ?? this.subCategoriesCount,
      productsCount: productsCount ?? this.productsCount,
      subCategories: subCategories ?? this.subCategories,
      store: store ?? this.store,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final subCatsJson = json['sub_categories'] ?? json['sub_sub_categories'];
    List<CategoryModel>? subs;
    if (subCatsJson != null && subCatsJson is List) {
      subs = subCatsJson
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    CategoryStoreModel? storeModel;
    if (json['store'] != null && json['store'] is Map<String, dynamic>) {
      storeModel = CategoryStoreModel.fromJson(json['store']);
    }

    return CategoryModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      slug: json['slug']?.toString(),
      icon: json['icon']?.toString() ?? json['image']?.toString(),
      svgSrc: json['svgSrc']?.toString(),
      route: json['route']?.toString(),
      categoryType: json['category_type']?.toString() ??
          json['categoryType']?.toString(),
      priority: json['priority'] is int
          ? json['priority']
          : int.tryParse(json['priority']?.toString() ?? ''),
      position: json['position'] is int
          ? json['position']
          : int.tryParse(json['position']?.toString() ?? ''),
      parentId: json['parent_id'] is int
          ? json['parent_id']
          : int.tryParse(json['parent_id']?.toString() ?? ''),
      homeStatus: json['home_status'] is int
          ? json['home_status']
          : int.tryParse(json['home_status']?.toString() ?? ''),
      subCategoriesCount: json['sub_categories_count'] is int
          ? json['sub_categories_count']
          : int.tryParse(json['sub_categories_count']?.toString() ?? ''),
      productsCount: json['products_count'] is int
          ? json['products_count']
          : int.tryParse(json['products_count']?.toString() ?? ''),
      subCategories: subs,
      store: storeModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'icon': icon,
      'svgSrc': svgSrc,
      'route': route,
      'category_type': categoryType,
      'priority': priority,
      'position': position,
      'parent_id': parentId,
      'home_status': homeStatus,
      'sub_categories_count': subCategoriesCount,
      'products_count': productsCount,
      'sub_categories': subCategories?.map((x) => x.toJson()).toList(),
      'store': store?.toJson(),
    };
  }
}

class CategoryApiResponse {
  final bool status;
  final String message;
  final List<CategoryModel> data;
  final String? store;

  CategoryApiResponse({
    required this.status,
    required this.message,
    required this.data,
    this.store,
  });

  factory CategoryApiResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List? ?? [])
        .map((item) =>
            CategoryModel.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();

    return CategoryApiResponse(
      status: json['status'] == true,
      message: json['message']?.toString() ?? '',
      data: list,
      store: json['store']?.toString(),
    );
  }
}

final List<CategoryModel> demoCategoriesWithImage = [
  CategoryModel(title: "Woman’s", image: "https://i.imgur.com/5M89G2P.png", categoryType: "ecommerce"),
  CategoryModel(title: "Man’s", image: "https://i.imgur.com/UM3GdWg.png", categoryType: "ecommerce"),
  CategoryModel(title: "Kid’s", image: "https://i.imgur.com/Lp0D6k5.png", categoryType: "ecommerce"),
  CategoryModel(title: "Accessories", image: "https://i.imgur.com/3mSE5sN.png", categoryType: "ecommerce"),
];

final List<CategoryModel> demoCategories = [
  CategoryModel(
    id: 146,
    name: "Electronics",
    slug: "electronics",
    icon: "https://e-team-12.orderknow.com/storage/category/2026-10-24-6adc5f9b3a3d3.webp",
    categoryType: "ecommerce",
  ),
  CategoryModel(
    id: 167,
    name: "Fashion & Apparel",
    slug: "fashion-apparel",
    icon: "https://e-team-12.orderknow.com/storage/category/2026-10-24-6adc5fbf39a3f.webp",
    categoryType: "ecommerce",
  ),
  CategoryModel(
    id: 188,
    name: "Home & Living",
    slug: "home-living",
    icon: "https://e-team-12.orderknow.com/storage/category/2026-10-24-6adc5fadd1b6f.webp",
    categoryType: "ecommerce",
  ),
  CategoryModel(
    id: 209,
    name: "Beauty & Care",
    slug: "beauty-care",
    icon: "https://e-team-12.orderknow.com/storage/category/2026-10-24-6adc5f84af9fa.webp",
    categoryType: "ecommerce",
  ),
  CategoryModel(
    id: 230,
    name: "Sports & Fitness",
    slug: "sports-fitness",
    icon: "https://e-team-12.orderknow.com/storage/category/2026-10-24-6adc5fec60948.webp",
    categoryType: "ecommerce",
  ),
  CategoryModel(
    id: 251,
    name: "Groceries",
    slug: "groceries",
    icon: "https://e-team-12.orderknow.com/storage/category/2026-10-24-6adc600ff0aa5.webp",
    categoryType: "ecommerce",
  ),
  CategoryModel(
    id: 272,
    name: "Starters",
    slug: "starters",
    icon: "https://e-team-12.orderknow.com/storage/category/food-starters.webp",
    categoryType: "food",
  ),
  CategoryModel(
    id: 273,
    name: "Main Course",
    slug: "main-course",
    icon: "https://e-team-12.orderknow.com/storage/category/food-main-course.webp",
    categoryType: "food",
  ),
  CategoryModel(
    id: 274,
    name: "Biryanis & Rice",
    slug: "biryanis-and-rice",
    icon: "https://e-team-12.orderknow.com/storage/category/food-biryani.webp",
    categoryType: "food",
  ),
  CategoryModel(
    id: 275,
    name: "Breads",
    slug: "breads",
    icon: "https://e-team-12.orderknow.com/storage/category/food-breads.webp",
    categoryType: "food",
  ),
  CategoryModel(
    id: 276,
    name: "Pizzas",
    slug: "pizzas",
    icon: "https://e-team-12.orderknow.com/storage/category/food-pizzas.webp",
    categoryType: "food",
  ),
];
