import 'package:flutter/material.dart';
import 'package:vlr/services/constants.dart';

class CategoryModel {
  final int? id;
  final dynamic parentId;
  final String? name;
  final String? slug;
  final String? icon;
  final String? iconUrl;
  final String? image;
  final String? color;
  final bool? isActive;
  final bool? hasShifts;
  final bool? hasTrainers;
  final bool? hasRooms;
  final bool? hasPackages;
  final String? sortOrder;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final dynamic deletedAt;

  CategoryModel({
    this.id,
    this.parentId,
    this.name,
    this.slug,
    this.icon,
    this.iconUrl,
    this.image,
    this.color,
    this.isActive,
    this.hasShifts,
    this.hasTrainers,
    this.hasRooms,
    this.hasPackages,
    this.sortOrder,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  String? get imageUrl {
    final String? raw = (image != null && image!.trim().isNotEmpty)
        ? image!.trim()
        : ((iconUrl != null && iconUrl!.trim().isNotEmpty) ? iconUrl!.trim() : null);

    if (raw == null || raw.isEmpty) return null;

    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return raw;
    }
    if (raw.startsWith('/')) {
      return "${AppConstants.baseUrl.replaceAll('/api/', '').replaceAll('/api', '')}$raw";
    }
    return "${AppConstants.baseImageUrl}$raw";
  }

  String? get displayImage => imageUrl ?? icon;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"] is int ? json["id"] : int.tryParse(json["id"]?.toString() ?? ""),
        parentId: json["parent_id"],
        name: json["name"],
        slug: json["slug"],
        icon: json["icon"],
        iconUrl: json["icon_url"] ?? json["image"]?.toString(),
        image: json["image"]?.toString(),
        color: json["color"],
        isActive: json["is_active"] is bool ? json["is_active"] : (json["is_active"] == 1 || json["is_active"] == "1"),
        hasShifts: json["has_shifts"] is bool ? json["has_shifts"] : (json["has_shifts"] == 1 || json["has_shifts"] == "1"),
        hasTrainers: json["has_trainers"] is bool ? json["has_trainers"] : (json["has_trainers"] == 1 || json["has_trainers"] == "1"),
        hasRooms: json["has_rooms"] is bool ? json["has_rooms"] : (json["has_rooms"] == 1 || json["has_rooms"] == "1"),
        hasPackages: json["has_packages"] is bool ? json["has_packages"] : (json["has_packages"] == 1 || json["has_packages"] == "1"),
        sortOrder: json["sort_order"]?.toString(),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.tryParse(json["created_at"].toString()),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.tryParse(json["updated_at"].toString()),
        deletedAt: json["deleted_at"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "parent_id": parentId,
        "name": name,
        "slug": slug,
        "icon": icon,
        "icon_url": iconUrl,
        "color": color,
        "is_active": isActive,
        "has_shifts": hasShifts,
        "has_trainers": hasTrainers,
        "has_rooms": hasRooms,
        "has_packages": hasPackages,
        "sort_order": sortOrder,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
        "deleted_at": deletedAt,
      };
  Color get colorValue {
    if (color == null || color!.isEmpty) {
      return Colors.grey;
    }

    try {
      return Color(
        int.parse(color!.replaceFirst('#', '0xFF')),
      );
    } catch (e) {
      return Colors.grey;
    }
  }
}
