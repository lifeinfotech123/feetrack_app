import 'package:get/get.dart';
import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';

class NotificationRepo {
  final ApiClient apiClient;

  NotificationRepo({required this.apiClient});

  Future<Response> getNotifications(int page) async {
    return await apiClient.getData(
      "${AppConstants.notificationUri}?page=$page",
      "getNotifications",
    );
  }

  Future<Response> markAsRead(String id) async {
    return await apiClient.putData(
      "${AppConstants.notificationUri}/$id/read",
      "markAsRead",
      {},
    );
  }

  Future<Response> markAllRead() async {
    return await apiClient.putData(
      "${AppConstants.notificationUri}/mark-all-read",
      "markAllRead",
      {},
    );
  }

  Future<Response> deleteNotification(String id) async {
    return await apiClient.deleteData(
      "${AppConstants.notificationUri}/$id",
      "deleteNotification",
    );
  }

  Future<Response> deleteAllNotifications() async {
    return await apiClient.deleteData(
      "${AppConstants.notificationUri}/delete",
      "deleteAllNotifications",
    );
  }

  Future<Response> getUnreadCount() async {
    return await apiClient.getData(
      "${AppConstants.notificationUri}/unread-count",
      "getUnreadCount",
    );
  }
}
