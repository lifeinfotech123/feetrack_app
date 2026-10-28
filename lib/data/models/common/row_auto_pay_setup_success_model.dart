class RowOfAutoSetupSuccessModel {
  final String? title;
  final String? subTitle;

  RowOfAutoSetupSuccessModel({
    this.title,
    this.subTitle,
  });

  factory RowOfAutoSetupSuccessModel.fromJson(Map<String, dynamic> json) {
    return RowOfAutoSetupSuccessModel(
      title: json['title'] as String?,
      subTitle: json['subTitle'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subTitle': subTitle,
    };
  }
}