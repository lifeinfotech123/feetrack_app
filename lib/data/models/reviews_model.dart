class ReviewsModel {
  final int? id;
  final int? rating;
  final String? comment;
  final String? customerName;
  final String? avatar;
  final String? createdAt;

  ReviewsModel({
    this.id,
    this.rating,
    this.comment,
    this.customerName,
    this.avatar,
    this.createdAt,
  });

  factory ReviewsModel.fromJson(Map<String, dynamic> json) => ReviewsModel(
        id: json["id"],
        rating: json["rating"],
        comment: json["comment"],
        customerName: json["customer_name"],
        avatar: json["avatar"],
        createdAt: json["created_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rating": rating,
        "comment": comment,
        "customer_name": customerName,
        "avatar": avatar,
        "created_at": createdAt,
      };
}
