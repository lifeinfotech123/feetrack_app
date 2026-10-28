

class BannerModel {


  final int? id;
  final String? title;
  final String? imageUrl;
  final int? sortOrder;

  BannerModel({
    this.id,
    this.title,
    this.imageUrl,
    this.sortOrder,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json["id"],
        title: json["title"],
        imageUrl: json["image_url"] ?? json["image"] ?? json["image_path"] ?? json["url"],
        sortOrder: json["sort_order"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "image_url": imageUrl,
        "sort_order": sortOrder,
      };
}
