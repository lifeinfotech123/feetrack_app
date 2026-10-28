class WebsiteModel {
  final int? id;
  final String? websiteTitle;
  final String? companyName;
  final String? domainName;
  final String? fullDomainUrl;
  final String? websiteLogo;
  final String? androidAppUrl;
  final String? iosAppUrl;
  final WebsiteCategoryModel? category;
  final String? createdAt;

  WebsiteModel({
    this.id,
    this.websiteTitle,
    this.companyName,
    this.domainName,
    this.fullDomainUrl,
    this.websiteLogo,
    this.androidAppUrl,
    this.iosAppUrl,
    this.category,
    this.createdAt,
  });

  factory WebsiteModel.fromJson(Map<String, dynamic> json) {
    return WebsiteModel(
      id: json['id'],
      websiteTitle: json['website_title'] ?? json['company_name'] ?? "",
      companyName: json['company_name'] ?? json['website_title'] ?? "",
      domainName: json['domain_name'] ?? "",
      fullDomainUrl: json['full_domain_url'] ?? "",
      websiteLogo: json['website_logo'] ?? json['logo'] ?? json['image'],
      androidAppUrl: json['android_app_url'],
      iosAppUrl: json['ios_app_url'],
      category: json['category'] != null && json['category'] is Map<String, dynamic>
          ? WebsiteCategoryModel.fromJson(json['category'])
          : null,
      createdAt: json['created_at'],
    );
  }
}

class WebsiteCategoryModel {
  final int? id;
  final String? name;
  final String? slug;

  WebsiteCategoryModel({this.id, this.name, this.slug});

  factory WebsiteCategoryModel.fromJson(Map<String, dynamic> json) {
    return WebsiteCategoryModel(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}
