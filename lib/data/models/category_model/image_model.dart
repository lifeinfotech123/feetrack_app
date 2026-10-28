
class ImageMode {
    final int? id;
    final String? listingId;
    final String? imagePath;
    final dynamic caption;
    final String? sortOrder;
    final DateTime? createdAt;
    final DateTime? updatedAt;

    String? get url => imagePath;

    ImageMode({
        this.id,
        this.listingId,
        this.imagePath,
        this.caption,
        this.sortOrder,
        this.createdAt,
        this.updatedAt,
    });

    factory ImageMode.fromJson(Map<String, dynamic> json) => ImageMode(
        id: json["id"] != null ? int.tryParse(json["id"].toString()) : null,
        listingId: json["listing_id"]?.toString(),
        imagePath: (json["url"] ?? json["image_path"] ?? json["image_url"] ?? json["image"])?.toString(),
        caption: json["caption"],
        sortOrder: json["sort_order"]?.toString(),
        createdAt: json["created_at"] == null ? null : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null ? null : DateTime.tryParse(json["updated_at"].toString()),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "listing_id": listingId,
        "image_path": imagePath,
        "caption": caption,
        "sort_order": sortOrder,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}
