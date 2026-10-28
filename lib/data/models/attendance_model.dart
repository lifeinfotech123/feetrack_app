class AttendanceModel {
  final int? id;
  final String? date;
  final String? punchInAt;
  final String? punchOutAt;
  final int? durationMinutes;
  final String? status;
  final String? listing;
  final String? listingId;

  AttendanceModel({
    this.id,
    this.date,
    this.punchInAt,
    this.punchOutAt,
    this.durationMinutes,
    this.status,
    this.listing,
    this.listingId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ""),
      date: json['date'],
      punchInAt: json['punch_in_at'],
      punchOutAt: json['punch_out_at'],
      durationMinutes: json['duration_minutes'] is int 
          ? json['duration_minutes'] 
          : int.tryParse(json['duration_minutes']?.toString() ?? ""),
      status: json['status'],
      listing: json['listing'],
      listingId: json['listing_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'punch_in_at': punchInAt,
      'punch_out_at': punchOutAt,
      'duration_minutes': durationMinutes,
      'status': status,
      'listing': listing,
      'listing_id': listingId,
    };
  }
}
