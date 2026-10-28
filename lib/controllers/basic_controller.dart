import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/data/models/notification_models/notification_option_model.dart';
import 'package:vlr/data/models/pagination/pagination_state.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/models/reviews_model.dart';
import 'package:vlr/data/repositories/basic_repo.dart';

class BasicController extends GetxController implements GetxService {
  final BasicRepo basicRepo;

  BasicController({required this.basicRepo});

  bool isLoading = false;

  //* State and city

  List<String> stateList = [];
  List<String> cityList = [];

  //* notification
  NotificationOptionModel? selectNotificationOption;

  void updateNotificationOptionModel(NotificationOptionModel value) {
    for (var e in notificationOptionModelList) {
      e.isSelect = e.id == value.id;
    }
    update();
  }

  List<NotificationOptionModel> notificationOptionModelList = [
    NotificationOptionModel(title: "All", isSelect: true, id: 1),
    NotificationOptionModel(title: "Payments", isSelect: false, id: 2),
    NotificationOptionModel(title: "GYN", isSelect: false, id: 3),
    NotificationOptionModel(title: "ROOM", isSelect: false, id: 4),
    NotificationOptionModel(title: "PG", isSelect: false, id: 5),
    NotificationOptionModel(title: "School", isSelect: false, id: 6),
    NotificationOptionModel(title: "Other", isSelect: false, id: 7),
  ];

  TextEditingController reviewController = TextEditingController();
  double selectRating = 0;

  Future<ResponseModel> submitReviewsById({required String? id}) async {
    log('-----------  submitReviewsById ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final data = {
        "rating": selectRating.toInt(),
        "comment": reviewController.text,
      };
      Response response = await basicRepo.submitReviewsById(
        id: id,
        data: data,
      );

      if (response.body['status'] == "success") {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success submitReviewsById  ");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while submitReviewsById  ");
      }
    } catch (e) {
      log('ERROR AT submitReviewsById(): $e');
      responseModel =
          ResponseModel(false, "Error while submitReviewsById   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  void resetReview() {
    reviewController.clear();
    selectRating = 0;
    update();
  }

  double averageRating = 0;
  int totalReviews = 0;

  final PaginationState<ReviewsModel> reviewsListState =
      PaginationState<ReviewsModel>();

  List<ReviewsModel> get reviewsList => reviewsListState.items;

  Future<ResponseModel> fetchListingReviewsByIdPagination({
    required String? id,
    bool loadMore = false,
    bool refresh = false,
  }) async {
    log('fetchListingReviewsById called '
        '(loadMore: $loadMore, refresh: $refresh)');

    ResponseModel responseModel = ResponseModel(false, "Unknown error");

    if (refresh) {
      reviewsListState.page = 1;
      reviewsListState.lastPage = 1;
      reviewsListState.items.clear();
      reviewsListState.dedupeIds.clear();
    }

    if (loadMore) {
      if (!reviewsListState.canLoadMore) {
        return ResponseModel(false, "No more pages");
      }
      reviewsListState.isMoreLoading = true;
      reviewsListState.page += 1;
    } else {
      reviewsListState.isInitialLoading = true;
      reviewsListState.page = 1;
      reviewsListState.items.clear();
      reviewsListState.dedupeIds.clear();
    }

    update();

    try {
      final Response response = await basicRepo.fetchListingReviewsById(id: id);

      log("Raw response body: ${response.body}");

      if (response.statusCode != 200) {
        responseModel =
            ResponseModel(false, "Status code: ${response.statusCode}");
      } else if (response.body is Map<String, dynamic> &&
          response.body['status'] == "success") {
        averageRating = double.tryParse(
              response.body['data']['average_rating'].toString(),
            ) ??
            0;

        totalReviews = int.tryParse(
              response.body['data']['total_reviews'].toString(),
            ) ??
            0;
        final paginated = response.body['data']['reviews'];

        if (paginated is Map<String, dynamic> && paginated['data'] is List) {
          final List itemsJson = paginated['data'] as List;

          final List<ReviewsModel> parsedData = itemsJson
              .map((e) => ReviewsModel.fromJson(e as Map<String, dynamic>))
              .toList();

          final int currentPage =
              int.tryParse(paginated['current_page'].toString()) ??
                  reviewsListState.page;
          final int lastPage =
              int.tryParse(paginated['last_page'].toString()) ?? currentPage;

          reviewsListState.lastPage = lastPage;
          reviewsListState.page = currentPage;

          if (loadMore) {
            for (final item in parsedData) {
              if (!reviewsListState.dedupeIds.contains(item.id)) {
                reviewsListState.dedupeIds.add(item.id);
                reviewsListState.items.add(item);
              }
            }
          } else {
            reviewsListState.items
              ..clear()
              ..addAll(parsedData);

            reviewsListState.dedupeIds
              ..clear()
              ..addAll(parsedData.map((e) => e.id));
          }

          log("Listing count: ${reviewsListState.items.length}");
          responseModel = ResponseModel(
            true,
            response.body['message'] ?? "success fetchListingReviewsById",
          );
        } else {
          responseModel =
              ResponseModel(false, "Invalid listing response format");
        }
      } else {
        responseModel = ResponseModel(
          false,
          response.body is Map<String, dynamic>
              ? (response.body['message'] ??
                  "Error while fetchListingReviewsById")
              : "Invalid server response",
        );
      }
    } catch (e) {
      log('ERROR AT fetchListingReviewsById(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchListingReviewsById $e");
    }

    reviewsListState.isInitialLoading = false;
    reviewsListState.isMoreLoading = false;
    update();
    return responseModel;
  }
}
