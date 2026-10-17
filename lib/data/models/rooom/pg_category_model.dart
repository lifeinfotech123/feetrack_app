class PgCategoryModel {
  final String? name;
  final String? slug;
  final String? type;
  final String? description;
  final String? icon;
  final String? bgColor;
  final String? fgColor;
  final int? totalListings;
  final String? apiUrl;
  bool isSelected;

  PgCategoryModel({
    this.name,
    this.slug,
    this.type,
    this.description,
    this.icon,
    this.bgColor,
    this.fgColor,
    this.totalListings,
    this.apiUrl,
    this.isSelected = false,
  });

  factory PgCategoryModel.fromJson(Map<String, dynamic> json) {
    return PgCategoryModel(
      name: json['name']?.toString(),
      slug: json['slug']?.toString(),
      type: json['type']?.toString(),
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      bgColor: json['bg_color']?.toString(),
      fgColor: json['fg_color']?.toString(),
      totalListings: json['total_listings'] != null
          ? int.tryParse(json['total_listings'].toString())
          : null,
      apiUrl: json['api_url']?.toString(),
      isSelected: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'slug': slug,
        'type': type,
        'description': description,
        'icon': icon,
        'bg_color': bgColor,
        'fg_color': fgColor,
        'total_listings': totalListings,
        'api_url': apiUrl,
      };
}
