class CouponsCodeModel {
  final int? id;
  final String? code;
  final String? title;
  final String? description;
  final String? type;
  final int? value;
  final int? minAmount;
  final int? maxDiscount;
  final String? expiresAt;

  CouponsCodeModel({
    this.id,
    this.code,
    this.title,
    this.description,
    this.type,
    this.value,
    this.minAmount,
    this.maxDiscount,
    this.expiresAt,
  });

  factory CouponsCodeModel.fromJson(Map<String, dynamic> json) =>
      CouponsCodeModel(
        id: json["id"],
        code: json["code"],
        title: json["title"],
        description: json["description"],
        type: json["type"],
        value: json["value"],
        minAmount: json["min_amount"],
        maxDiscount: json["max_discount"],
        expiresAt: json["expires_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "title": title,
        "description": description,
        "type": type,
        "value": value,
        "min_amount": minAmount,
        "max_discount": maxDiscount,
        "expires_at": expiresAt,
      };
}
