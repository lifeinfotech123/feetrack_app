class BillingPreviewModel {
  final String? planName;
  final String? duration;
  final String? durationDays;
  final num? subtotal;
  final num? tax;
  final num? discount;
  final num? total;
  final dynamic room;
  final num? shiftFee;
  final num? trainerFee;
  final int? bedsBooked;
  final num? securityDeposit;

  BillingPreviewModel({
    this.planName,
    this.duration,
    this.durationDays,
    this.subtotal,
    this.tax,
    this.discount,
    this.total,
    this.room,
    this.shiftFee,
    this.trainerFee,
    this.bedsBooked,
    this.securityDeposit,
  });

  factory BillingPreviewModel.fromJson(Map<String, dynamic> json) =>
      BillingPreviewModel(
        planName: json["plan_name"],
        duration: json["duration"],
        durationDays: json["duration_days"]?.toString(),
        subtotal: json["subtotal"],
        tax: json["tax"],
        discount: json["discount"],
        total: json["total"],
        room: json["room"],
        shiftFee: json["shift_fee"],
        trainerFee: json["trainer_fee"],
        bedsBooked: json["beds_booked"],
        securityDeposit: json["security_deposit"],
      );

  Map<String, dynamic> toJson() => {
        "plan_name": planName,
        "duration": duration,
        "duration_days": durationDays,
        "subtotal": subtotal,
        "tax": tax,
        "discount": discount,
        "total": total,
        "room": room,
        "shift_fee": shiftFee,
        "trainer_fee": trainerFee,
        "beds_booked": bedsBooked,
        "security_deposit": securityDeposit,
      };
}
