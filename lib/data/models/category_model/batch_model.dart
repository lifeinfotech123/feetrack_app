class BatchModel {
  final int? id;
  final String? name;
  final String? startTime;
  final String? endTime;
  final String? maxMembers;
  final int? fee;

  bool isSelected;

  BatchModel({
    this.id,
    this.name,
    this.startTime,
    this.endTime,
    this.maxMembers,
    this.fee,
    this.isSelected = false,
  });

  factory BatchModel.fromJson(Map<String, dynamic> json) {
    return BatchModel(
      id: json["id"],
      name: json["name"],
      startTime: json["start_time"],
      endTime: json["end_time"],
      maxMembers: json["max_members"]?.toString(),
      fee: json["fee"],
    );
  }
}