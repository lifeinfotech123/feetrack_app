import 'package:vlr/data/models/category_model/listing_model.dart';
import 'pg_room_model.dart';

class PgFloorModel {
  final dynamic id;
  final String? floorNumber;
  final String? name;
  final String? listingId;
  final int? totalRooms;
  final int? totalCapacity;
  final int? availableBeds;
  final ListingModel? listing;
  final Map<String, dynamic>? website;
  final List<PgRoomModel>? rooms;
  bool isSelect;

  PgFloorModel({
    required this.id,
    this.floorNumber,
    this.name,
    this.listingId,
    this.totalRooms,
    this.totalCapacity,
    this.availableBeds,
    this.listing,
    this.website,
    this.rooms,
    this.isSelect = false,
  });

  // Display helpers & backward compatibility getters
  String get floorBadge {
    if (floorNumber == '0' || floorNumber == '0.0') return 'G';
    final n = name?.toLowerCase() ?? '';
    if (n.contains('ground')) return 'G';
    if (floorNumber != null && floorNumber!.isNotEmpty) return 'F$floorNumber';
    final match = RegExp(r'(\d+)').firstMatch(n);
    if (match != null) return 'F${match.group(1)}';
    return 'F';
  }

  String? get floorNo {
    if (floorNumber == '0' || floorNumber == '0.0') return 'Ground Floor';
    if (floorNumber == '1') return '1st Floor';
    if (floorNumber == '2') return '2nd Floor';
    if (floorNumber == '3') return '3rd Floor';
    if (floorNumber != null && floorNumber!.isNotEmpty) return 'Floor $floorNumber';
    if (name != null && name!.isNotEmpty) return name;
    return 'Floor';
  }

  String? get floorName => name;

  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    if (floorNumber == '0' || floorNumber == '0.0') return 'Ground Floor';
    if (floorNumber != null && floorNumber!.isNotEmpty) return 'Floor $floorNumber';
    return 'Floor';
  }

  factory PgFloorModel.fromJson(Map<String, dynamic> json) {
    return PgFloorModel(
      id: json['id'],
      floorNumber: json['floor_number']?.toString(),
      name: json['name']?.toString(),
      listingId: (json['listing_id'] ?? json['listing']?['id'])?.toString(),
      totalRooms: json['total_rooms'] != null
          ? int.tryParse(json['total_rooms'].toString())
          : null,
      totalCapacity: json['total_capacity'] != null
          ? int.tryParse(json['total_capacity'].toString())
          : null,
      availableBeds: json['available_beds'] != null
          ? int.tryParse(json['available_beds'].toString())
          : null,
      listing: json['listing'] != null && json['listing'] is Map
          ? ListingModel.fromJson(Map<String, dynamic>.from(json['listing']))
          : null,
      website: json['website'] != null && json['website'] is Map
          ? Map<String, dynamic>.from(json['website'])
          : null,
      rooms: json['rooms'] != null && json['rooms'] is List
          ? (json['rooms'] as List)
              .whereType<Map>()
              .map((x) => PgRoomModel.fromJson(Map<String, dynamic>.from(x)))
              .toList()
          : null,
    );
  }
}
