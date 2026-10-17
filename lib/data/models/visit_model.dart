import 'package:vlr/data/models/category_model/listing_model.dart';
import 'package:vlr/data/models/user_model.dart';

class VisitWebsiteModel {
  final dynamic id;
  final String? name;
  final String? domain;
  final String? portalUrl;

  VisitWebsiteModel({
    this.id,
    this.name,
    this.domain,
    this.portalUrl,
  });

  factory VisitWebsiteModel.fromJson(Map<String, dynamic> json) =>
      VisitWebsiteModel(
        id: json['id'],
        name: json['name']?.toString(),
        domain: json['domain']?.toString(),
        portalUrl: json['portal_url']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'domain': domain,
        'portal_url': portalUrl,
      };
}

class VisitModel {
  String? id;
  String? customerId;
  String? listingId;
  String? partnerId;
  String? visitDate;
  String? formattedDate;
  String? visitTime;
  String? status;
  String? statusLabel;
  String? note;
  String? createdAt;
  String? updatedAt;
  ListingModel? listing;
  UserModel? partner;
  UserModel? customer;
  VisitWebsiteModel? website;

  VisitModel({
    this.id,
    this.customerId,
    this.listingId,
    this.partnerId,
    this.visitDate,
    this.formattedDate,
    this.visitTime,
    this.status,
    this.statusLabel,
    this.note,
    this.createdAt,
    this.updatedAt,
    this.listing,
    this.partner,
    this.customer,
    this.website,
  });

  VisitModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['visit_id']?.toString();
    customerId = json['customer_id']?.toString() ??
        json['app_user_id']?.toString() ??
        json['visitor']?['id']?.toString();
    listingId = json['listing_id']?.toString() ?? json['listing']?['id']?.toString();
    partnerId = json['partner_id']?.toString() ??
        json['host']?['partner_id']?.toString();
    visitDate = json['visit_date']?.toString();
    formattedDate = json['formatted_date']?.toString();
    visitTime = json['visit_time']?.toString();
    status = json['status']?.toString();
    statusLabel = json['status_label']?.toString();
    note = json['note']?.toString();
    createdAt = json['created_at']?.toString();
    updatedAt = json['updated_at']?.toString();
    if (json['listing'] != null && json['listing'] is Map) {
      listing = ListingModel.fromJson(Map<String, dynamic>.from(json['listing']));
    } else if (json['property'] != null && json['property'] is Map) {
      listing = ListingModel.fromJson(Map<String, dynamic>.from(json['property']));
    }
    if (json['partner'] != null) {
      partner = UserModel.fromJson(Map<String, dynamic>.from(json['partner']));
    } else if (json['host'] != null) {
      partner = UserModel.fromJson(Map<String, dynamic>.from(json['host']));
    }
    if (json['customer'] != null) {
      customer = UserModel.fromJson(Map<String, dynamic>.from(json['customer']));
    } else if (json['visitor'] != null) {
      customer = UserModel.fromJson(Map<String, dynamic>.from(json['visitor']));
    }
    if (json['website'] != null && json['website'] is Map) {
      website = VisitWebsiteModel.fromJson(
          Map<String, dynamic>.from(json['website']));
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['customer_id'] = customerId;
    data['listing_id'] = listingId;
    data['partner_id'] = partnerId;
    data['visit_date'] = visitDate;
    data['visit_time'] = visitTime;
    data['status'] = status;
    data['note'] = note;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    if (listing != null) {
      data['listing'] = listing!.toJson();
    }
    if (partner != null) {
      data['partner'] = partner!.toJson();
    }
    if (customer != null) {
      data['customer'] = customer!.toJson();
    }
    if (website != null) {
      data['website'] = website!.toJson();
    }
    return data;
  }
}
