import 'package:vlr/data/api/api_client.dart';
import 'package:vlr/services/constants.dart';
import 'package:get/get.dart';

class RoomRepo {
  final ApiClient apiClient;

  RoomRepo({required this.apiClient});

  /// 1. Get all PG categories (Boys, Girls, Co-living, etc.)
  Future<Response> fetchPgCategories() async {
    return await apiClient.getData(
      AppConstants.pgCategories,
      "fetchPgCategories",
    );
  }

  /// 2. Get global PG listings with optional query filters
  Future<Response> fetchPgListings({
    String? city,
    String? tenant,
    String? search,
    String? category,
    dynamic minPrice,
    dynamic maxPrice,
    dynamic latitude,
    dynamic longitude,
  }) async {
    final Map<String, String> params = {};
    if (city != null && city.isNotEmpty && city.toLowerCase() != 'all') {
      params['city'] = city;
    }
    if (tenant != null && tenant.isNotEmpty && tenant.toLowerCase() != 'all') {
      params['tenant'] = tenant;
    }
    if (search != null && search.isNotEmpty) {
      params['search'] = search;
    }
    if (category != null &&
        category.isNotEmpty &&
        category.toLowerCase() != 'all') {
      params['category'] = category;
    }
    if (minPrice != null && minPrice.toString().isNotEmpty) {
      params['min_price'] = minPrice.toString();
    }
    if (maxPrice != null && maxPrice.toString().isNotEmpty) {
      params['max_price'] = maxPrice.toString();
    }
    if (latitude != null && latitude.toString().isNotEmpty) {
      params['latitude'] = latitude.toString();
    }
    if (longitude != null && longitude.toString().isNotEmpty) {
      params['longitude'] = longitude.toString();
    }

    final String queryString = params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');

    final String url = queryString.isNotEmpty
        ? "${AppConstants.pgListings}?$queryString"
        : AppConstants.pgListings;

    return await apiClient.getData(url, "fetchPgListings");
  }

  /// 3. Get single PG listing details with floors, rooms, and packages
  Future<Response> fetchPgListingDetails(String id) async {
    return await apiClient.getData(
      AppConstants.pgListingDetails(id: id),
      "fetchPgListingDetails",
    );
  }

  /// 4. Get PG listings filtered by slug type (boys, girls, hostel, etc.)
  Future<Response> fetchPgByType(String slug) async {
    Response response = await apiClient.getData(
      AppConstants.pgByType(slug: slug),
      "fetchPgByType",
    );
    if (response.statusCode != 200) {
      final altResponse = await apiClient.getData(
        AppConstants.pgByTypeAlt(slug: slug),
        "fetchPgByTypeAlt",
      );
      if (altResponse.statusCode == 200) {
        return altResponse;
      }
    }
    return response;
  }

  /// 5. Get single PG package details (api/v1/pg/packages/{id})
  Future<Response> fetchPgPackageDetails(String id) async {
    return await apiClient.getData(
      AppConstants.pgPackageDetails(id: id),
      "fetchPgPackageDetails",
    );
  }

  /// 6. Get all packages for a specific PG listing (api/v1/pg/listings/{listing_id}/packages)
  Future<Response> fetchPgListingPackages(String listingId) async {
    return await apiClient.getData(
      AppConstants.pgListingPackages(listingId: listingId),
      "fetchPgListingPackages",
    );
  }

  /// 7. Get all rooms across all PGs (api/v1/pg/rooms)
  Future<Response> fetchAllPgRooms() async {
    return await apiClient.getData(
      AppConstants.pgRooms,
      "fetchAllPgRooms",
    );
  }

  /// 8. Get single PG room details (api/v1/pg/rooms/{id})
  Future<Response> fetchPgRoomDetails(String id) async {
    return await apiClient.getData(
      AppConstants.pgRoomDetails(id: id),
      "fetchPgRoomDetails",
    );
  }

  /// 9. Get all rooms for a specific PG listing (api/v1/pg/listings/{listing_id}/rooms)
  Future<Response> fetchPgListingRooms(String listingId) async {
    return await apiClient.getData(
      AppConstants.pgListingRooms(listingId: listingId),
      "fetchPgListingRooms",
    );
  }

  // ── PG Floors APIs (v1/pg/floors) ──────────────────────────────
  /// 10. Fetch all PG floors (api/v1/pg/floors)
  Future<Response> fetchPgFloors({String? listingId}) async {
    final String url = (listingId != null && listingId.isNotEmpty)
        ? "${AppConstants.pgFloors}?listing_id=$listingId"
        : AppConstants.pgFloors;
    return await apiClient.getData(url, "fetchPgFloors");
  }

  /// 11. Fetch single PG floor details with rooms (api/v1/pg/floors/{id})
  Future<Response> fetchPgFloorDetails(dynamic floorId) async {
    return await apiClient.getData(
      AppConstants.pgFloorDetails(floorId: floorId),
      "fetchPgFloorDetails",
    );
  }

  /// 12. Fetch rooms for a specific PG floor (api/v1/pg/floors/{id}/rooms)
  Future<Response> fetchPgFloorRooms(dynamic floorId) async {
    return await apiClient.getData(
      AppConstants.pgFloorRooms(floorId: floorId),
      "fetchPgFloorRooms",
    );
  }

  //* Floors & Rooms legacy / secondary endpoints
  Future<Response> getFloors(String listingId) async {
    return await apiClient.getData(
      AppConstants.getFloors(id: listingId),
      "getFloors",
    );
  }

  Future<Response> getRooms(String listingId, dynamic floorId) async {
    return await apiClient.getData(
      AppConstants.getRooms(id: listingId, floorId: floorId),
      "getRooms",
    );
  }

  Future<Response> getRoomDetails(String listingId, String roomId) async {
    return await apiClient.getData(
      AppConstants.getRoomDetails(id: listingId, roomId: roomId),
      "getRoomDetails",
    );
  }

  // ── PG Customer Dashboard & Booking APIs ──────────────────────────
  /// 13. Fetch PG Customer Dashboard (/api/v1/pg/customer/dashboard)
  Future<Response> fetchPgCustomerDashboard() async {
    return await apiClient.getData(
      AppConstants.pgCustomerDashboard,
      "fetchPgCustomerDashboard",
    );
  }

  /// 14. Fetch PG Customer Bookings (/api/pg/bookings)
  Future<Response> fetchPgCustomerBookings({String? status}) async {
    final String query = (status != null && status.isNotEmpty && status != 'all')
        ? "?status=$status"
        : "";
    Response response = await apiClient.getData(
      "${AppConstants.pgCustomerBookings}$query",
      "fetchPgCustomerBookings",
    );
    if (response.statusCode != 200) {
      final altResponse = await apiClient.getData(
        "${AppConstants.pgCustomerBookingsLegacy}$query",
        "fetchPgCustomerBookingsLegacy",
      );
      if (altResponse.statusCode == 200) {
        return altResponse;
      }
    }
    return response;
  }

  /// 14b. Create PG Booking (/api/v1/pg/bookings or /api/pg/bookings)
  Future<Response> createPgBooking(Map<String, dynamic> data) async {
    Response response = await apiClient.postData(
      AppConstants.pgCustomerBookings,
      "createPgBooking",
      data,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final alt1 = await apiClient.postData(
        AppConstants.pgCustomerBookingsLegacy,
        "createPgBookingLegacy",
        data,
      );
      if (alt1.statusCode == 200 || alt1.statusCode == 201) {
        return alt1;
      }
      final alt2 = await apiClient.postData(
        "pg/bookings",
        "createPgBookingShort",
        data,
      );
      if (alt2.statusCode == 200 || alt2.statusCode == 201) {
        return alt2;
      }
      final alt3 = await apiClient.postData(
        AppConstants.postCreateBooking,
        "createPgBookingAlt",
        data,
      );
      if (alt3.statusCode == 200 || alt3.statusCode == 201) {
        return alt3;
      }
    }
    return response;
  }

  /// 15. Fetch PG Customer Booking Details (/api/pg/bookings/{id})
  Future<Response> fetchPgCustomerBookingDetails(String bookingId) async {
    Response response = await apiClient.getData(
      AppConstants.pgCustomerBookingDetails(id: bookingId),
      "fetchPgCustomerBookingDetails",
    );
    if (response.statusCode != 200) {
      final altResp = await apiClient.getData(
        "v1/pg/customer/bookings/$bookingId",
        "fetchPgCustomerBookingDetailsLegacy",
      );
      if (altResp.statusCode == 200) return altResp;
    }
    return response;
  }

  /// 16. Pay for PG Booking (/api/pg/bookings/{id}/pay)
  Future<Response> payPgCustomerBooking(String bookingId) async {
    Response response = await apiClient.postData(
      AppConstants.pgCustomerBookingPay(id: bookingId),
      "payPgCustomerBooking",
      {},
    );
    if (response.statusCode != 200) {
      final altResp = await apiClient.postData(
        "v1/pg/customer/bookings/$bookingId/pay",
        "payPgCustomerBookingLegacy",
        {},
      );
      if (altResp.statusCode == 200) return altResp;
    }
    return response;
  }

  /// 17. Fetch Customer Wallet (/api/v1/pg/customer/wallet)
  Future<Response> fetchPgCustomerWallet() async {
    return await apiClient.getData(
      AppConstants.pgCustomerWallet,
      "fetchPgCustomerWallet",
    );
  }

  /// 18. Fetch Customer Profile (/api/v1/pg/customer/profile)
  Future<Response> fetchPgCustomerProfile() async {
    return await apiClient.getData(
      AppConstants.pgCustomerProfile,
      "fetchPgCustomerProfile",
    );
  }

  /// 19. Fetch PG Customer Invoices (/api/v1/pg/customer/invoices)
  Future<Response> fetchPgCustomerInvoices() async {
    return await apiClient.getData(
      AppConstants.pgCustomerInvoices,
      "fetchPgCustomerInvoices",
    );
  }

  /// 19b. Fetch PG Customer Invoice Detail (/api/v1/pg/customer/invoices/{id})
  Future<Response> fetchPgCustomerInvoiceDetail(String id) async {
    return await apiClient.getData(
      AppConstants.pgCustomerInvoiceDetail(id),
      "fetchPgCustomerInvoiceDetail",
    );
  }

  /// 20. Fetch PG Customer Subscriptions (/api/v1/pg/customer/subscriptions)
  Future<Response> fetchPgCustomerSubscriptions() async {
    return await apiClient.getData(
      AppConstants.pgCustomerSubscriptions,
      "fetchPgCustomerSubscriptions",
    );
  }

  /// 21. Fetch PG Customer Subscription Detail (/api/v1/pg/customer/subscriptions/{id})
  Future<Response> fetchPgCustomerSubscriptionDetail(String id) async {
    return await apiClient.getData(
      AppConstants.pgCustomerSubscriptionDetail(id),
      "fetchPgCustomerSubscriptionDetail",
    );
  }

  /// 22. Fetch PG Customer Attendance (/api/v1/pg/customer/attendance)
  Future<Response> fetchPgCustomerAttendance({
    int? month,
    int? year,
    String? fromDate,
    String? toDate,
  }) async {
    String url = AppConstants.pgCustomerAttendance;
    final List<String> query = [];
    if (month != null) query.add("month=$month");
    if (year != null) query.add("year=$year");
    if (fromDate != null && fromDate.isNotEmpty) query.add("from_date=$fromDate");
    if (toDate != null && toDate.isNotEmpty) query.add("to_date=$toDate");
    if (query.isNotEmpty) url = "$url?${query.join('&')}";
    return await apiClient.getData(url, "fetchPgCustomerAttendance");
  }

  /// 23. Punch In PG Customer Attendance (/api/v1/pg/customer/attendance/punch-in)
  Future<Response> punchInPgCustomerAttendance({Map<String, dynamic>? data}) async {
    return await apiClient.postData(
      AppConstants.pgCustomerAttendancePunchIn,
      "punchInPgCustomerAttendance",
      data ?? {},
    );
  }

  /// 24. Punch Out PG Customer Attendance (/api/v1/pg/customer/attendance/punch-out)
  Future<Response> punchOutPgCustomerAttendance({Map<String, dynamic>? data}) async {
    return await apiClient.postData(
      AppConstants.pgCustomerAttendancePunchOut,
      "punchOutPgCustomerAttendance",
      data ?? {},
    );
  }

  /// 25. Verify PG Booking Check-in OTP (/api/v1/pg/customer/bookings/{id}/verify-otp)
  Future<Response> verifyPgBookingOtp(String bookingId, String otp) async {
    return await apiClient.postData(
      AppConstants.pgCustomerBookingVerifyOtp(id: bookingId),
      "verifyPgBookingOtp",
      {"otp": otp},
    );
  }

  /// 26. Cancel PG Booking (/api/v1/pg/customer/bookings/{id}/cancel)
  Future<Response> cancelPgBooking(String bookingId) async {
    return await apiClient.postData(
      AppConstants.pgCustomerBookingCancel(id: bookingId),
      "cancelPgBooking",
      {},
    );
  }

  /// 27. Fetch PG Booking Invoice (/api/v1/pg/customer/bookings/{id}/invoice)
  Future<Response> fetchPgBookingInvoice(String bookingId) async {
    return await apiClient.getData(
      AppConstants.pgCustomerBookingInvoice(id: bookingId),
      "fetchPgBookingInvoice",
    );
  }

  /// 28. Pay PG Customer Invoice (/api/v1/pg/customer/invoice/{id}/pay)
  Future<Response> payPgCustomerInvoice(String invoiceId) async {
    return await apiClient.postData(
      AppConstants.pgCustomerInvoicePay(invoiceId),
      "payPgCustomerInvoice",
      {},
    );
  }

  /// 29. Fetch PG Customer Payment Transactions (/api/v1/pg/customer/payment)
  Future<Response> fetchPgCustomerPayments() async {
    return await apiClient.getData(
      AppConstants.pgCustomerPayment,
      "fetchPgCustomerPayments",
    );
  }

  /// 30. Recharge PG Customer Wallet (/api/v1/pg/customer/wallet/recharge)
  Future<Response> rechargePgCustomerWallet(num amount) async {
    return await apiClient.postData(
      AppConstants.pgCustomerWalletRecharge,
      "rechargePgCustomerWallet",
      {"amount": amount},
    );
  }

  /// 31. Fetch PG Customer Scheduled Visits (/api/v1/pg/customer/visits)
  Future<Response> fetchPgCustomerVisits() async {
    return await apiClient.getData(
      AppConstants.pgCustomerVisitsList,
      "fetchPgCustomerVisits",
    );
  }

  /// 32. Create PG Customer Visit (/api/v1/pg/customer/visit)
  Future<Response> createPgCustomerVisit(Map<String, dynamic> data) async {
    return await apiClient.postData(
      AppConstants.pgCustomerCreateVisit,
      "createPgCustomerVisit",
      data,
    );
  }

  /// 33. Cancel PG Customer Visit (/api/v1/pg/customer/visits/{id}/cancel)
  Future<Response> cancelPgCustomerVisit(String visitId) async {
    return await apiClient.postData(
      AppConstants.pgCustomerVisitCancel(id: visitId),
      "cancelPgCustomerVisit",
      {},
    );
  }

  /// 34. Fetch PG Customer Saved Listings / Favorites (/api/v1/pg/customer/saved-listings)
  Future<Response> fetchPgSavedListings() async {
    return await apiClient.getData(
      AppConstants.pgCustomerSavedListings,
      "fetchPgSavedListings",
    );
  }

  /// 35. Remove PG Customer Saved Listing (/api/v1/pg/customer/saved-listings/{id})
  Future<Response> removePgSavedListing(String favoriteId) async {
    return await apiClient.deleteData(
      AppConstants.pgCustomerSavedListingRemove(favoriteId),
      "removePgSavedListing",
    );
  }

  /// 36. Update PG Customer Profile (/api/v1/pg/customer/profile)
  Future<Response> updatePgCustomerProfile(Map<String, dynamic> data) async {
    return await apiClient.postData(
      AppConstants.pgCustomerProfile,
      "updatePgCustomerProfile",
      data,
    );
  }
}
