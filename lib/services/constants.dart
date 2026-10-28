// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vlr/main.dart';
import 'package:vlr/services/route_helper.dart';
import 'package:vlr/services/theme.dart';
import 'package:page_transition/page_transition.dart';
import 'package:toastification/toastification.dart';

class PriceConverter {
  static convert(price) {
    if (price == null) return '₹ 0.00';
    String cleanPrice = price.toString().replaceAll(',', '');
    final val = double.tryParse(cleanPrice);
    if (val == null) return '₹ 0.00';
    return '₹ ${val.toStringAsFixed(2)}';
  }

  static convertRound(price) {
    if (price == null) return '₹ 0';
    String cleanPrice = price.toString().replaceAll(',', '');
    final val = double.tryParse(cleanPrice);
    if (val == null) return '₹ 0';
    return '₹ ${val.toInt()}';
  }

  static convertToNumberFormat(num price) {
    final format = NumberFormat("#,##,##,##0.00", "en_IN");
    return '₹ ${format.format(price)}';
  }
}

Widget sizedBoxHeight({required double height}) {
  return SizedBox(
    height: height,
  );
}

Widget sizedBoxWidth({required double width}) {
  return SizedBox(
    width: width,
  );
}

class Helper {
  final BuildContext context;
  Helper(this.context);

  Size get size => MediaQuery.sizeOf(context);
  TextTheme get textTheme => Theme.of(context).textTheme;
}

String capitalize(String? s) {
  if (s == null || s.isEmpty) return "";
  return s[0].toUpperCase() + s.substring(1);
}

void navigate({
  PageTransitionType type = PageTransitionType.fade,
  required BuildContext context,
  required Widget page,
  bool isReplace = false,
  bool isRemoveUntil = false,
  Duration duration = const Duration(milliseconds: 300),
}) {
  if (isReplace) {
    Navigator.of(context).pushReplacement(
      getCustomRoute(
        child: page,
        type: type,
        duration: duration,
      ),
    );
  } else if (isRemoveUntil) {
    Navigator.of(context).pushAndRemoveUntil(
      getCustomRoute(
        child: page,
        type: type,
        duration: duration,
      ),
      (route) => false,
    );
  } else {
    Navigator.of(context).push(
      getCustomRoute(
        child: page,
        type: type,
        duration: duration,
      ),
    );
  }
}

void pop(BuildContext context, {dynamic data}) {
  Navigator.pop(context, data);
}

enum ToastType {
  info(ToastificationType.info),
  warning(ToastificationType.warning),
  error(ToastificationType.error),
  success(ToastificationType.success);

  const ToastType(this.value);
  final ToastificationType value;
}

void showToast(
    {ToastType? toastType,
    required String message,
    String? description,
    ToastificationStyle? toastificationStyle,
    bool? typeCheck}) {
  toastification.show(
    alignment: Alignment.topLeft,
    type: toastType?.value ??
        ((typeCheck ?? false)
            ? ToastificationType.success
            : ToastificationType.error),
    title: Text(
      message,
      style:
          Helper(navigatorKey.currentContext!).textTheme.bodyMedium!.copyWith(
                color: black,
                fontSize: 14,
              ),
    ),
    description: description != null
        ? Text(description,
            style: Helper(navigatorKey.currentContext!)
                .textTheme
                .bodySmall!
                .copyWith(
                  color: black,
                ))
        : null,
    style: toastificationStyle ?? ToastificationStyle.minimal,
    icon: toastType == ToastType.success
        ? const Icon(Icons.check_circle_outline)
        : toastType == ToastType.error
            ? const Icon(Icons.error_outline)
            : toastType == ToastType.warning
                ? const Icon(Icons.warning_amber)
                : const Icon(Icons.info_outline),
    autoCloseDuration: const Duration(seconds: 2),
  );
}

String getStringFromList(List<dynamic>? data) {
  String str = data.toString();
  return data.toString().substring(1, str.length - 1);
}

class AppConstants {
  String get getBaseUrl => baseUrl;
  set setBaseUrl(String url) => baseUrl = url;

  //TODO: Change Base Url
  static String baseUrl = 'https://orderknow.com/api/';
  //baseU

  // static String baseUrl = 'https://test.feetrack.in/api/';
  // static String baseUrl = 'https://feetrackhrms.bestitcompanylucknow.com/api/';
  // static String baseUrl = 'http://192.168.1.22:8000/api/';
  static String baseImageUrl = 'https://app.feetrack.in/';
  // static String baseUrl = 'http://192.168.1.5:9000/'; ///USE FOR LOCAL
  // static String baseImageUrl = 'http://192.168.1.5:9000/';
  // static String baseUrl = "https://orderknow.com/api/"

  //TODO: Change Base Url

  static String appName = 'FeeTrack';

  //* Auth
  static const String registrationUri = 'v1/auth/register';
  static const String verifyMobileAndEmailOtp = 'register/verify';
  static const String resendVerifyMobileAndEmailOtp = 'register/resend-otp';
  static const String loginUri = 'login/request-otp';
  static const String emailPasswordLoginUri = 'v1/auth/login';
  static const String loginOtpVerify = 'login/verify';
  static const String loginResendOtpVerify = 'login/resend-otp';
  static const String logoutUri = '';

  //* profile
  static const String getProfileUri = 'v1/auth/profile';
  static const String postLogout = 'logout';
  static const String putUpdateProfile = 'v1/auth/profile';
  static const String putUpdateFcmToken = 'fcm-token';
  static const String deleteAccountUri = 'account/destroy';

  //* Home
  static const String getCategories = 'v1/categories';
  static const String getGyms = 'v1/gym/gyms';
  static String gymDetails({required dynamic id}) => "v1/gym/gyms/$id";
  static const String gymBookVisit = 'v1/gym/my-visits';
  static const String gymBookMembership = 'v1/gym/book-membership';
  static const String gymCities = 'v1/gym/cities';
  static const String gymTrainers = 'v1/gym/trainers';
  static const List<Map<String, String>> gymBookingTimeSlots = [
    {
      "title": "Morning",
      "time": "06:00 AM - 08:00 AM",
      "label": "Morning (06:00 AM - 08:00 AM)",
    },
    {
      "title": "Evening",
      "time": "06:00 PM - 10:00 PM",
      "label": "Evening (06:00 PM - 10:00 PM)",
    },
  ];
  static String gymTrainerDetails({required dynamic id}) =>
      "v1/gym/trainers/$id";
  static const String myGymBookings = 'v1/gym/my-bookings';
  static const String myGymVisits = 'v1/gym/my-visits';
  static String myGymVisitDetails({required dynamic id}) =>
      'v1/gym/my-visits/$id';
  static const String gymVerifyPayment = 'v1/gym/book-visit';
  static const String gymShifts = 'v1/gym/shifts';
  static String gymShiftDetails({required dynamic id}) => "v1/gym/shifts/$id";
  static String gymSpecificShifts({required dynamic gymId}) =>
      "v1/gym/gyms/$gymId/shifts";
  static const String getListing = 'listings';
  static const String getListingById = 'listings';
  static const String getBanner = 'app-banners';
  static String getProfileFacilities({required dynamic id}) =>
      "listings/$id/facilities";
  static String gymStaff({required dynamic id}) => "listings/$id/staff";
  static String gymStaffProfile(
          {required dynamic id, required dynamic staffId}) =>
      "listings/$id/staff/$staffId";
  static String getProfileBranches({required int id}) =>
      "listings/$id/branches";

  //* PG / Accommodation
  static const String pgCategories = 'v1/pg/categories';
  static const String pgListings = 'v1/pg/listings';
  static String pgListingDetails({required dynamic id}) => "v1/pg/listings/$id";
  static String pgByType({required String slug}) => "v1/pg/by-type/$slug";
  static String pgByTypeAlt({required String slug}) => "pg/v1/by-type/$slug";
  static String pgPackageDetails({required dynamic id}) => "v1/pg/packages/$id";
  static String pgListingPackages({required dynamic listingId}) =>
      "v1/pg/listings/$listingId/packages";
  static const String pgRooms = 'v1/pg/rooms';
  static String pgRoomDetails({required dynamic id}) => "v1/pg/rooms/$id";
  static String pgListingRooms({required dynamic listingId}) =>
      "v1/pg/listings/$listingId/rooms";

  //* Floors & Rooms (v1/pg/floors)
  static const String pgFloors = 'v1/pg/floors';
  static String pgFloorDetails({required dynamic floorId}) =>
      "v1/pg/floors/$floorId";
  static String pgFloorRooms({required dynamic floorId}) =>
      "v1/pg/floors/$floorId/rooms";
  static String getFloors({required dynamic id}) => "listings/$id/floors";
  static String getRooms({required dynamic id, required dynamic floorId}) =>
      "listings/$id/rooms?floor_id=$floorId";
  static String getRoomDetails(
          {required dynamic id, required dynamic roomId}) =>
      "listings/$id/rooms/$roomId";

  //* PG Customer APIs
  static const String pgCustomerDashboard = 'v1/pg/customer/dashboard';
  static const String pgBookings = 'v1/pg/bookings';
  static const String pgCustomerBookings = 'v1/pg/customer/bookings';
  static String pgCustomerBookingDetails({required dynamic id}) =>
      'v1/pg/customer/bookings/$id';
  static String pgCustomerBookingVerifyOtp({required dynamic id}) =>
      'v1/pg/customer/bookings/$id/verify-otp';
  static String pgCustomerBookingPay({required dynamic id}) =>
      'v1/pg/customer/bookings/$id/pay';
  static String pgCustomerBookingCancel({required dynamic id}) =>
      'v1/pg/customer/bookings/$id/cancel';
  static String pgCustomerBookingInvoice({required dynamic id}) =>
      'v1/pg/customer/bookings/$id/invoice';
  static const String pgCustomerWallet = 'v1/pg/customer/wallet';
  static const String pgCustomerWalletRecharge =
      'v1/pg/customer/wallet/recharge';
  static const String pgCustomerProfile = 'v1/pg/customer/profile';
  static const String pgCustomerInvoices = 'v1/pg/customer/invoices';
  static String pgCustomerInvoiceDetail(dynamic id) =>
      'v1/pg/customer/invoices/$id';
  static String pgCustomerInvoicePay(dynamic id) =>
      'v1/pg/customer/invoice/$id/pay';
  static const String pgCustomerPayments = 'v1/pg/customer/payments';
  static const String pgCustomerSubscriptions = 'v1/pg/customer/subscriptions';
  static String pgCustomerSubscriptionDetail(dynamic id) =>
      'v1/pg/customer/subscriptions/$id';
  static const String pgCustomerAttendance = 'v1/pg/customer/attendance';
  static const String pgCustomerAttendancePunchIn =
      'v1/pg/customer/attendance/punch-in';
  static const String pgCustomerAttendancePunchOut =
      'v1/pg/customer/attendance/punch-out';
  static const String pgCustomerVisitsList = 'v1/pg/customer/visits';
  static const String pgCustomerCreateVisit = 'v1/pg/customer/visit';
  static const String pgCustomerSavedListings = 'v1/pg/customer/saved-listings';
  static String pgCustomerSavedListingRemove(dynamic id) =>
      'v1/pg/customer/saved-listings/$id';

  //* select plan
  static String getProfileDurations({required dynamic id}) =>
      "listings/$id/durations";
  static String getProfilePlan({required dynamic id}) => "listings/$id/plans";

  //* reviews
  static String getReviews({required dynamic id}) => "listings/$id/reviews";
  static String putSubmitReviews({required dynamic id}) =>
      "listings/$id/reviews";

  //* Single category list
  static String categoryBanner({required dynamic id}) => "listings/$id/banners";

  //* Billing summary
  static const String billingPreview = "bookings/billing-preview";

  //* Subscription

  static const String postCreateBooking = 'bookings';

//!------ check this api is working or not
  static const String postCreateSubscription = 'subscriptions';
  static const String getSubscription = 'subscriptions';
  static const String getPaymentHistory = 'payments/history';
  static const String getMyWalletBalance = 'v1/my-wallet/balance';
  static const String postMyWalletRecharge = 'v1/my-wallet/recharge';
  static const String getMyTransactions = 'v1/my-transactions';
  static const String getGymCustomerWallet = 'v1/gym/customer/wallet';
  static const String getGymCustomerWalletTransactions =
      'v1/gym/customer/wallet/transactions';
  static const String postGymCustomerWalletRecharge =
      'v1/gym/customer/wallet/recharge';
  static const String postGymCustomerWalletVerifyRecharge =
      'v1/gym/customer/wallet/verify-recharge';

  // Gym customer wallet

  static const String getWalletSummary = 'wallet/summary';
  static const String getReserveHistory = 'wallet/reserve-history';
  static const String getRechargeHistory = 'wallet/recharges';
  static const String getWithdrawalHistory = 'wallet/withdrawals';
  static const String getWalletHistory = 'wallet/history';
  static const String postWalletRecharge = 'wallet/recharge/request';
  static const String postWalletRechargeInitiate = 'wallet/recharge';
  static const String getRechargeConfig = 'wallet/recharge-config';
  static const String postWalletWithdrawal = 'wallet/withdraw';

  //* Coupons
  static String getCouponsList({required dynamic id}) =>
      "coupons?listing_id=$id";
  static String postApplyCouponCode = "coupons/apply";

  //* Visits
  static const String visitsUrl = 'visits';
  static String getVisitDetailUrl(String id) => 'visits/$id';
  static const String pgVisits = 'v1/pg/visits';
  static const String pgScheduleVisit = 'v1/pg/schedule-visit';
  static String pgVisitDetail(String id) => 'v1/pg/visits/$id';
  static String pgCustomerVisitCancel({required dynamic id}) =>
      'v1/pg/customer/visits/$id/cancel';

  static String downloadReceipt({required String type, required String id}) =>
      'invoice/$type/$id/download';

  //* Dashboard
  static const String recentTransactionsUri = 'transactions';

  //* KYC
  static const String kycUri = 'kyc';

  //* Notification
  static const String notificationUri = 'notifications';

  //* Attendance
  static const String punchInUri = 'attendance/punch-in';
  static const String punchOutUri = 'attendance/punch-out';
  static const String todayAttendanceUri = 'attendance/today';
  static const String attendanceHistoryUri = 'attendance';

  //* Gym Attendance & Invoices
  static const String gymAttendanceStatus = 'v1/gym/attendance/status';
  static const String gymAttendancePunchIn = 'v1/gym/attendance/punch-in';
  static const String gymAttendancePunchOut = 'v1/gym/attendance/punch-out';
  static const String gymAttendanceHistory = 'v1/gym/attendance/history';
  static const String gymInvoices = 'v1/gym/invoices';
  static String gymInvoiceDetails(dynamic id) => 'v1/gym/invoices/$id';
  static const String gymReviews = 'v1/gym/reviews';
  static String gymReviewsByGymId({required dynamic gymId, int? page}) =>
      page != null
          ? 'v1/gym/reviews?gym_id=$gymId&page=$page'
          : 'v1/gym/reviews?gym_id=$gymId';

  //* Hospital Module Endpoints
  // Websites & Categories
  static const String hospitalWebsitesUri = 'v1/categories/hospital/websites';
  static const String allWebsitesUri = 'v1/categories/websites';

  // Doctors & Services
  static const String hospitalDoctorsUri = 'v1/hospital/doctors';
  static const String hospitalServicesUri = 'v1/hospital/services';
  static const String hospitalDoctorSlotsUri = 'v1/hospital/slots';

  // Appointments & Payment
  static const String hospitalAppointmentsUri = 'v1/hospital/appointments';
  static const String hospitalMyAppointmentsUri = 'v1/hospital/my-appointments';
  static String hospitalMyAppointmentDetailUri(dynamic id) =>
      'v1/hospital/my-appointments/$id';
  static const String hospitalMyLiveConsultationsUri =
      'v1/hospital/my-live-consultations';
  static String hospitalMyLiveConsultationDetailUri(dynamic id) =>
      'v1/hospital/my-live-consultations/$id';
  static String hospitalAppointmentVerifyPaymentUri(dynamic appointmentId) =>
      'v1/hospital/appointments/$appointmentId/verify-payment';
  static const String hospitalPaymentGatewaysUri = 'v1/payment-gateways';

  // Pharmacy
  static const String hospitalPharmacyCatalogUri = 'v1/hospital/pharmacy';
  static const String hospitalPharmacyMedicinesUri =
      'v1/hospital/pharmacy/medicines';
  static String hospitalPharmacyMedicineByIdUri(dynamic id) =>
      'v1/hospital/pharmacy/medicines/$id';
  static const String hospitalPharmacyCategoriesUri =
      'v1/hospital/pharmacy/categories';
  static const String hospitalPharmacyStoresUri = 'v1/hospital/pharmacy/stores';
  static const String hospitalPharmacyPlaceOrderUri =
      'v1/hospital/pharmacy/place-order';
  static const String hospitalPharmacyVerifyPaymentUri =
      'v1/hospital/pharmacy/verify-payment';
  static String hospitalPharmacyInvoiceUri(dynamic billId) =>
      'v1/hospital/pharmacy/invoice/$billId';
  static const String hospitalPatientMedicineOrdersUri =
      'v1/hospital/patient/medicine-orders';

  // Lab Tests & Reports
  static const String hospitalLabListingUri = 'v1/hospital/lab';
  static const String hospitalLabTestsUri = 'v1/hospital/lab/tests';
  static String hospitalLabTestByIdUri(dynamic id) =>
      'v1/hospital/lab/tests/$id';
  static const String hospitalLabCentersUri = 'v1/hospital/lab/centers';
  static const String hospitalLabCategoriesUri = 'v1/hospital/lab/categories';
  static const String hospitalLabBookUri = 'v1/hospital/lab/book';
  static const String hospitalLabVerifyPaymentUri =
      'v1/hospital/lab/verify-payment';
  static const String hospitalPatientLabBookingsUri =
      'v1/hospital/patient/lab-bookings';

  // Legacy PHP Endpoints (Hospital Core Network)
  static const String hospitalGetListsPhp = '/getLists.php';
  static const String hospitalMarkAsReceivedPhp = '/markAsReceived.php';
  static const String hospitalCancelAppointmentPhp = '/cancelAppointment.php';
  static const String hospitalChargePhp = '/charge.php';
  static const String hospitalUserLoginPhp = '/userLogin.php';
  static const String hospitalRegisterUserPhp = '/registerUser.php';

  //
  static const double horizontalPadding = 16;
  static const double verticalPadding = 20;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
      horizontal: AppConstants.horizontalPadding,
      vertical: AppConstants.verticalPadding);

  // Shared Key
  static const String token = 'user_app_token';
  static const String userId = 'user_app_id';
  static const String razorpayKey = 'razorpay_key';
  static const String recentOrders = 'recent_orders';
  static const String isUser = 'is_user';
  static const String fcmToken = 'fcmToken';
}
