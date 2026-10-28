import 'dart:convert';

class BannerModel {
  final int? id;
  final dynamic string;
  final String? image;
  final dynamic link;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerModel({
    this.id,
    this.string,
    this.image,
    this.link,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerModel.fromRawJson(String str) =>
      BannerModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json["id"],
        string: json["String"],
        image: json["image"],
        link: json["link"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "String": string,
        "image": image,
        "link": link,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
