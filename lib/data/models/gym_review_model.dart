import 'gym_attendance_model.dart';

bool _parseGymReviewBool(dynamic value, {bool defaultValue = false}) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes' || normalized == 'y' || normalized == 'on') {
      return true;
    }
    if (normalized == 'false' || normalized == '0' || normalized == 'no' || normalized == 'n' || normalized == 'off' || normalized.isEmpty) {
      return false;
    }
  }
  return defaultValue;
}

class GymReviewsResponse {
  final bool? status;
  final String? message;
  final GymReviewsData? data;

  GymReviewsResponse({this.status, this.message, this.data});

  factory GymReviewsResponse.fromJson(Map<String, dynamic> json) {
    return GymReviewsResponse(
      status: _parseGymReviewBool(json['status']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? GymReviewsData.fromJson(Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class GymReviewsData {
  final GymReviewSummary? summary;
  final GymAttendancePagination? pagination;
  final List<GymReviewItem> reviews;

  GymReviewsData({
    this.summary,
    this.pagination,
    this.reviews = const [],
  });

  factory GymReviewsData.fromJson(Map<String, dynamic> json) {
    var rawList = json['reviews'];
    List<GymReviewItem> list = [];
    if (rawList is List) {
      list = rawList
          .map((e) => GymReviewItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return GymReviewsData(
      summary: json['summary'] is Map
          ? GymReviewSummary.fromJson(
              Map<String, dynamic>.from(json['summary'] as Map))
          : null,
      pagination: json['pagination'] is Map
          ? GymAttendancePagination.fromJson(
              Map<String, dynamic>.from(json['pagination'] as Map))
          : null,
      reviews: list,
    );
  }
}

class GymReviewSummary {
  final num averageRating;
  final int totalReviews;
  final Map<String, int> ratingBreakdown;

  GymReviewSummary({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.ratingBreakdown = const {},
  });

  factory GymReviewSummary.fromJson(Map<String, dynamic> json) {
    Map<String, int> breakdown = {};
    if (json['rating_breakdown'] is Map) {
      (json['rating_breakdown'] as Map).forEach((k, v) {
        breakdown[k.toString()] = v is num
            ? v.toInt()
            : int.tryParse(v?.toString() ?? '0') ?? 0;
      });
    }

    return GymReviewSummary(
      averageRating: json['average_rating'] is num
          ? (json['average_rating'] as num)
          : num.tryParse(json['average_rating']?.toString() ?? '0') ?? 0,
      totalReviews: json['total_reviews'] is num
          ? (json['total_reviews'] as num).toInt()
          : int.tryParse(json['total_reviews']?.toString() ?? '0') ?? 0,
      ratingBreakdown: breakdown,
    );
  }
}

class GymReviewItem {
  final String? id;
  final num rating;
  final String? comment;
  final GymReviewCustomer? customer;
  final GymAttendanceGym? gym;
  final String? createdAt;
  final String? dateFormatted;

  GymReviewItem({
    this.id,
    this.rating = 0,
    this.comment,
    this.customer,
    this.gym,
    this.createdAt,
    this.dateFormatted,
  });

  factory GymReviewItem.fromJson(Map<String, dynamic> json) {
    return GymReviewItem(
      id: json['id']?.toString(),
      rating: json['rating'] is num
          ? (json['rating'] as num)
          : num.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      comment: json['comment']?.toString(),
      customer: json['customer'] is Map
          ? GymReviewCustomer.fromJson(
              Map<String, dynamic>.from(json['customer'] as Map))
          : null,
      gym: json['gym'] is Map
          ? GymAttendanceGym.fromJson(
              Map<String, dynamic>.from(json['gym'] as Map))
          : null,
      createdAt: json['created_at']?.toString(),
      dateFormatted: json['date_formatted']?.toString(),
    );
  }
}

class GymReviewCustomer {
  final String? name;
  final String? avatar;

  GymReviewCustomer({this.name, this.avatar});

  factory GymReviewCustomer.fromJson(Map<String, dynamic> json) {
    return GymReviewCustomer(
      name: json['name']?.toString(),
      avatar: json['avatar']?.toString(),
    );
  }
}

class GymReviewSubmitResponse {
  final bool? status;
  final String? message;
  final GymReviewSubmitData? data;

  GymReviewSubmitResponse({this.status, this.message, this.data});

  factory GymReviewSubmitResponse.fromJson(Map<String, dynamic> json) {
    return GymReviewSubmitResponse(
      status: _parseGymReviewBool(json['status']),
      message: json['message']?.toString(),
      data: json['data'] is Map<String, dynamic>
          ? GymReviewSubmitData.fromJson(
              Map<String, dynamic>.from(json['data']))
          : null,
    );
  }
}

class GymReviewSubmitData {
  final bool? success;
  final String? message;
  final dynamic reviewId;
  final GymAttendanceGym? gym;
  final num? rating;
  final String? comment;
  final String? updatedAt;

  GymReviewSubmitData({
    this.success,
    this.message,
    this.reviewId,
    this.gym,
    this.rating,
    this.comment,
    this.updatedAt,
  });

  factory GymReviewSubmitData.fromJson(Map<String, dynamic> json) {
    final reviewMap = json['review'] is Map ? json['review'] as Map : null;

    return GymReviewSubmitData(
      success: _parseGymReviewBool(json['success']),
      message: json['message']?.toString(),
      reviewId: json['review_id'],
      gym: json['gym'] is Map
          ? GymAttendanceGym.fromJson(
              Map<String, dynamic>.from(json['gym'] as Map))
          : null,
      rating: reviewMap != null && reviewMap['rating'] is num
          ? (reviewMap['rating'] as num)
          : null,
      comment: reviewMap?['comment']?.toString(),
      updatedAt: reviewMap?['updated_at']?.toString(),
    );
  }
}
