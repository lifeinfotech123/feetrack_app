import 'package:vlr/data/models/category_model/plan_model.dart';

class RoomDetailModel {
  final String? id;
  final String? floorId;
  final String? roomNumber;
  final String? roomType;
  final String? capacity;
  final String? availableBeds;
  final int? securityDeposit;
  final List<PlanModel>? packages;
  bool isSelected;

  RoomDetailModel({
    this.id,
    this.floorId,
    this.roomNumber,
    this.roomType,
    this.capacity,
    this.availableBeds,
    this.securityDeposit,
    this.packages,
    this.isSelected = false,
  });

  factory RoomDetailModel.fromJson(Map<String, dynamic> json) => RoomDetailModel(
        id: json["id"],
        floorId: json["floor_id"]?.toString(),
        roomNumber: json["room_number"],
        roomType: json["room_type"],
        capacity: json["capacity"]?.toString(),
        availableBeds: json["available_beds"]?.toString(),
        securityDeposit: json["security_deposit"] is int
            ? json["security_deposit"]
            : int.tryParse(json["security_deposit"]?.toString() ?? ''),
        packages: json["packages"] != null
            ? (json["packages"] as List)
                .map((e) => PlanModel.fromJson(e))
                .toList()
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "floor_id": floorId,
        "room_number": roomNumber,
        "room_type": roomType,
        "capacity": capacity,
        "available_beds": availableBeds,
        "security_deposit": securityDeposit,
      };
}
