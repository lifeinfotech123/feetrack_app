import 'package:flutter/material.dart';

class GymShiftModel {
  final String? id;
  final String? shiftName;
  final String? shiftLabel;
  final String? startTime;
  final String? endTime;
  final int? maxMembers;
  final dynamic fee;
  final GymShiftGymInfo? gym;
  final GymShiftWebsiteInfo? website;
  bool isSelected;

  GymShiftModel({
    this.id,
    this.shiftName,
    this.shiftLabel,
    this.startTime,
    this.endTime,
    this.maxMembers,
    this.fee,
    this.gym,
    this.website,
    this.isSelected = false,
  });

  factory GymShiftModel.fromJson(Map<String, dynamic> json) {
    return GymShiftModel(
      id: json['id']?.toString(),
      shiftName: json['shift_name']?.toString(),
      shiftLabel: json['shift_label']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      maxMembers: json['max_members'] != null
          ? int.tryParse(json['max_members'].toString())
          : null,
      fee: json['fee'],
      gym: json['gym'] is Map
          ? GymShiftGymInfo.fromJson(Map<String, dynamic>.from(json['gym']))
          : null,
      website: json['website'] is Map
          ? GymShiftWebsiteInfo.fromJson(
              Map<String, dynamic>.from(json['website']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'shift_name': shiftName,
        'shift_label': shiftLabel,
        'start_time': startTime,
        'end_time': endTime,
        'max_members': maxMembers,
        'fee': fee,
        if (gym != null) 'gym': gym!.toJson(),
        if (website != null) 'website': website!.toJson(),
      };

  double get feeAmount {
    if (fee == null) return 0.0;
    return double.tryParse(fee.toString()) ?? 0.0;
  }

  String get formattedFee {
    if (feeAmount <= 0) return 'Free / Included';
    return '₹${feeAmount.toInt()}';
  }

  String get displayTiming {
    if (shiftLabel != null && shiftLabel!.isNotEmpty) {
      return shiftLabel!;
    }
    if ((startTime != null && startTime!.isNotEmpty) &&
        (endTime != null && endTime!.isNotEmpty)) {
      return '$startTime - $endTime';
    }
    return shiftName ?? 'Gym Shift';
  }

  IconData get icon {
    final lower = (shiftName ?? '').toLowerCase();
    if (lower.contains('morning')) {
      return Icons.wb_sunny_rounded;
    } else if (lower.contains('afternoon')) {
      return Icons.wb_twilight_rounded;
    } else if (lower.contains('evening') || lower.contains('night')) {
      return Icons.nights_stay_rounded;
    }
    return Icons.access_time_filled_rounded;
  }
}

class GymShiftGymInfo {
  final String? id;
  final String? title;
  final String? city;
  final String? address;
  final String? phone;

  GymShiftGymInfo({
    this.id,
    this.title,
    this.city,
    this.address,
    this.phone,
  });

  factory GymShiftGymInfo.fromJson(Map<String, dynamic> json) {
    return GymShiftGymInfo(
      id: json['id']?.toString(),
      title: json['title']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'city': city,
        'address': address,
        'phone': phone,
      };
}

class GymShiftWebsiteInfo {
  final int? id;
  final String? name;
  final String? domain;
  final String? portalUrl;

  GymShiftWebsiteInfo({
    this.id,
    this.name,
    this.domain,
    this.portalUrl,
  });

  factory GymShiftWebsiteInfo.fromJson(Map<String, dynamic> json) {
    return GymShiftWebsiteInfo(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      name: json['name']?.toString(),
      domain: json['domain']?.toString(),
      portalUrl: json['portal_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'domain': domain,
        'portal_url': portalUrl,
      };
}
