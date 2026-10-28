import 'dart:developer';
import 'package:get/get.dart';
import 'package:vlr/data/models/notification_models/notification_model.dart';
import 'package:vlr/data/repositories/notification_repo.dart';
import 'package:vlr/data/models/response/response_model.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationRepo notificationRepo;
  NotificationController({required this.notificationRepo});

  @override
  void onInit() {
    super.onInit();
    getUnreadCount();
  }

  bool isLoading = false;
  List<NotificationModel> notificationList = [];
  int _page = 1;
  bool _hasNextPage = true;
  int unreadCount = 0;

  Future<void> getNotifications({bool isRefresh = true}) async {
    if (isRefresh) {
      _page = 1;
      _hasNextPage = true;
      notificationList = [];
    }

    if (!_hasNextPage) return;

    isLoading = true;
    update();
    try {
      Response response = await notificationRepo.getNotifications(_page);
      if (response.body != null && response.body['status'] == "success") {
        var rawData = response.body['data'];
        List items = [];
        
        if (rawData is Map && rawData['data'] is List) {
          items = rawData['data'];
          _hasNextPage = rawData['next_page_url'] != null;
          if (_hasNextPage) _page++;
        }
        
        List<NotificationModel> fetchedList = items.map((e) => NotificationModel.fromJson(e)).toList();
        notificationList.addAll(fetchedList);
        getUnreadCount();
      } else {
        log("Notification API Error: ${response.body?['message']}");
      }
    } catch (e) {
      log("Error fetching notifications: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<void> getUnreadCount() async {
    try {
      Response response = await notificationRepo.getUnreadCount();
      if (response.body != null && response.body['status'] == "success") {
        unreadCount = response.body['data']['unread_count'] ?? 0;
        update();
      }
    } catch (e) {
      log("Error fetching unread count: $e");
    }
  }

  Future<ResponseModel> markAsRead(String id) async {
    try {
      Response response = await notificationRepo.markAsRead(id);
      if (response.body != null && response.body['status'] == "success") {
        // Update local list
        int index = notificationList.indexWhere((element) => element.id == id);
        if (index != -1) {
          notificationList[index] = NotificationModel.fromJson(response.body['data']);
          getUnreadCount();
          update();
        }
        return ResponseModel(true, response.body['message'] ?? "Marked as read");
      }
      return ResponseModel(false, response.body?['message'] ?? "Error");
    } catch (e) {
      return ResponseModel(false, "Error: $e");
    }
  }

  Future<ResponseModel> markAllRead() async {
    isLoading = true;
    update();
    try {
      Response response = await notificationRepo.markAllRead();
      if (response.body != null && response.body['status'] == "success") {
        await getNotifications(isRefresh: true);
        return ResponseModel(true, response.body['message'] ?? "All marked as read");
      }
      return ResponseModel(false, response.body?['message'] ?? "Error");
    } catch (e) {
      return ResponseModel(false, "Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }

  Future<ResponseModel> deleteNotification(String id) async {
    try {
      Response response = await notificationRepo.deleteNotification(id);
      if (response.body != null && response.body['status'] == "success") {
        notificationList.removeWhere((element) => element.id == id);
        getUnreadCount();
        update();
        return ResponseModel(true, response.body['message'] ?? "Deleted");
      }
      return ResponseModel(false, response.body?['message'] ?? "Error");
    } catch (e) {
      return ResponseModel(false, "Error: $e");
    }
  }

  Future<ResponseModel> deleteAllNotifications() async {
    isLoading = true;
    update();
    try {
      Response response = await notificationRepo.deleteAllNotifications();
      if (response.body != null && response.body['status'] == "success") {
        notificationList = [];
        unreadCount = 0;
        update();
        return ResponseModel(true, response.body['message'] ?? "All notifications deleted");
      }
      return ResponseModel(false, response.body?['message'] ?? "Error");
    } catch (e) {
      return ResponseModel(false, "Error: $e");
    } finally {
      isLoading = false;
      update();
    }
  }
}
