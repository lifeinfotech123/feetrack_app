import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/data/models/bill_model.dart';
import 'package:vlr/data/models/response/response_model.dart';
import 'package:vlr/data/models/transaction_model.dart';
import 'package:vlr/data/models/wallet_transaction_model.dart';
import 'package:vlr/data/repositories/wallet_repo.dart';
import 'package:vlr/services/constants.dart';
import 'package:vlr/services/theme.dart';
import 'package:vlr/views/screens/dashboard/wallet_screen/add_money_screen/add_money_screen.dart';
import 'package:share_plus/share_plus.dart';

class WalletController extends GetxController implements GetxService {
  final WalletRepo walletRepo;
  WalletController({required this.walletRepo});

  bool isLoading = false;

  Future<ResponseModel> fetchPaymentHistory() async {
    log('-----------  fetchPaymentHistory ----------');

    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await walletRepo.fetchPaymentHistory();

      if (response.body['status'] == "success") {
        responseModel = ResponseModel(
            true, response.body['message'] ?? "success fetchPaymentHistory  ");
      } else {
        responseModel = ResponseModel(false,
            response.body['message'] ?? "Error while fetchPaymentHistory  ");
      }
    } catch (e) {
      log('ERROR AT fetchPaymentHistory(): $e');
      responseModel =
          ResponseModel(false, "Error while fetchPaymentHistory   $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<void> fetchWalletBalance() async {
    try {
      Response response = await walletRepo.fetchGymCustomerWallet();
      if (_isSuccess(response.body)) {
        final data = response.body['data'];
        if (data is Map) {
          walletBalance = _toDouble(data['wallet_balance'] ??
              (data['wallet'] is Map ? data['wallet']['balance'] : null));
          totalCredit = _toDouble(data['total_credited'] ??
              (data['summary'] is Map
                  ? data['summary']['total_credited']
                  : null));
          totalDebit = _toDouble(data['total_debited'] ??
              (data['summary'] is Map
                  ? data['summary']['total_debited']
                  : null));
        }
        update();
        return;
      }
    } catch (e) {
      log('ERROR AT fetchWalletBalance(): $e');
    }

    try {
      Response response = await walletRepo.fetchMyWalletBalance();
      if (_isSuccess(response.body)) {
        final data = response.body['data'];
        final wallet = data is Map ? data['wallet'] : null;
        walletBalance = _toDouble(wallet is Map
            ? wallet['balance']
            : (data is Map
                ? (data['wallet_balance'] ?? data['balance'])
                : null));
        totalCredit = _toDouble(wallet is Map
            ? wallet['total_credited']
            : (data is Map
                ? (data['total_credited'] ?? data['total_credit'])
                : null));
        totalDebit = _toDouble(wallet is Map
            ? wallet['total_debited']
            : (data is Map
                ? (data['total_debited'] ?? data['total_debit'])
                : null));
        update();
        return;
      }
    } catch (e) {
      log('ERROR AT fetchWalletBalance(): $e');
    }
  }

  bool _isSuccess(dynamic body) {
    if (body is! Map) return false;
    final status = body['status'];
    return status == true || status?.toString().toLowerCase() == 'success';
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  List<dynamic> myTransactions = [];
  Map<String, dynamic> myTransactionSummary = {};
  bool isTransactionsLoading = false;

  double get totalSpent => _toDouble(myTransactionSummary['total_spent']);

  Future<void> fetchMyTransactions() async {
    isTransactionsLoading = true;
    update();
    try {
      Response response = await walletRepo.fetchGymCustomerWalletTransactions();
      if (_isSuccess(response.body)) {
        final data = response.body['data'];
        if (data is Map) {
          myTransactionSummary = data['summary'] is Map
              ? Map<String, dynamic>.from(data['summary'])
              : {};
          myTransactions = data['transactions'] is List
              ? data['transactions']
              : (data['recent_transactions'] is List
                  ? data['recent_transactions']
                  : []);
        }
        update();
        isTransactionsLoading = false;
        update();
        return;
      }
    } catch (e) {
      log('ERROR AT fetchMyTransactions(): $e');
    }

    try {
      Response response = await walletRepo.fetchMyTransactions();
      if (_isSuccess(response.body)) {
        final data = response.body['data'];
        if (data is Map) {
          myTransactionSummary = data['summary'] is Map
              ? Map<String, dynamic>.from(data['summary'])
              : {};
          myTransactions =
              data['transactions'] is List ? data['transactions'] : [];
        }
        update();
      }
    } catch (e) {
      log('ERROR AT fetchMyTransactions(): $e');
    }
    isTransactionsLoading = false;
    update();
  }

  Future<ResponseModel> rechargeMyWallet(double amount,
      {String? paymentId, String? orderId, String? razorpaySignature}) async {
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      final int amountInt = amount.round();
      Map<String, dynamic> body = {
        "amount": amountInt,
        "payment_method": "razorpay",
        "notes": "Topup from mobile app",
      };

      Response response = await walletRepo.rechargeGymCustomerWallet(body);

      if (_isSuccess(response.body)) {
        final data = response.body['data'];
        if (data is Map && paymentId != null && paymentId.isNotEmpty && orderId != null && orderId.isNotEmpty) {
          final verifyBody = {
            "order_id": orderId,
            "razorpay_payment_id": paymentId,
            "razorpay_signature": razorpaySignature ?? "",
          };
          try {
            await walletRepo.verifyGymCustomerWalletRecharge(verifyBody);
          } catch (_) {}
        }

        if (data is Map) {
          final walletBalanceData = data['wallet_balance'];
          if (walletBalanceData != null) {
            walletBalance = _toDouble(walletBalanceData);
          }
        }
        await fetchWalletBalance();
        await fetchMyTransactions();
        responseModel = ResponseModel(
            true, response.body['message'] ?? "Wallet recharged successfully.");
      } else {
        responseModel = ResponseModel(
            false, response.body['message'] ?? "Wallet recharge failed.");
      }
    } catch (e) {
      log('ERROR AT rechargeMyWallet(): $e');
      try {
        final String amountValue = amount == amount.roundToDouble()
            ? amount.toStringAsFixed(0)
            : amount.toStringAsFixed(2);
        Map<String, dynamic> body = {
          "amount": amountValue,
          if (paymentId != null && paymentId.isNotEmpty)
            "razorpay_payment_id": paymentId,
        };
        Response response = await walletRepo.rechargeMyWallet(body);
        if (_isSuccess(response.body)) {
          final data = response.body['data'];
          final wallet = data is Map ? data['wallet'] : null;
          if (wallet is Map && wallet['balance'] != null) {
            walletBalance = _toDouble(wallet['balance']);
          } else {
            await fetchWalletBalance();
          }
          await fetchMyTransactions();
          responseModel = ResponseModel(
              true, response.body['message'] ?? "Wallet recharged successfully.");
        } else {
          responseModel = ResponseModel(false, response.body['message'] ?? "Wallet recharge failed.");
        }
      } catch (e2) {
        responseModel = ResponseModel(false, "Error while recharging wallet $e2");
      }
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<void> fetchWalletSummary() async {
    try {
      Response response = await walletRepo.fetchWalletSummary();
      if (response.body != null && response.body['status'] == "success") {
        var data = response.body['data'];
        walletBalance = (data['wallet_balance'] as num?)?.toDouble() ?? 0.0;
        totalCredit = (data['total_credit'] as num?)?.toDouble() ?? 0.0;
        totalDebit = (data['total_debit'] as num?)?.toDouble() ?? 0.0;
        update();
      }
    } catch (e) {
      log('ERROR AT fetchWalletSummary(): $e');
    }
  }

  double walletBalance = 0.00;
  double totalCredit = 0.00;
  double totalDebit = 0.00;
  double totalReservedAmount = 0.00;
  int selectedBottomNavIndex = 1;
  int paymentFailedNavIndex = 1;
  RxDouble addMoneyAmount = 100.00.obs;
  RxInt selectedPresetIndex = 1.obs;
  RxString selectedPaymentMethod = "qr".obs;
  final TextEditingController addMoneyAmountController =
      TextEditingController(text: "100.00");
  final TextEditingController utrController = TextEditingController();

  final TextEditingController withdrawalAmountController =
      TextEditingController();
  final TextEditingController withdrawalPaymentMethodController =
      TextEditingController();
  final TextEditingController withdrawalNotesController =
      TextEditingController();

  final List<double> presetAmounts = [50, 100, 500];

  int historyTabIndex = 0;
  List<dynamic> reserveHistory = [];
  List<dynamic> rechargeHistory = [];
  List<dynamic> withdrawalHistory = [];
  List<dynamic> walletHistory = [];

  bool isHistoryLoading = false;

  void setHistoryTabIndex(int index) {
    historyTabIndex = index;
    fetchHistoryData();
    update();
  }

  Future<void> fetchHistoryData() async {
    isHistoryLoading = true;
    update();

    try {
      Response response;
      switch (historyTabIndex) {
        case 0:
          await fetchReserveHistory();
          break;
        case 1:
          response = await walletRepo.fetchRechargeHistory();
          if (response.body['status'] == "success") {
            rechargeHistory = response.body['data']['data'] ?? [];
          }
          break;
        case 2:
          response = await walletRepo.fetchWithdrawalHistory();
          if (response.body['status'] == "success") {
            withdrawalHistory = response.body['data']['data'] ?? [];
          }
          break;
        case 3:
          response = await walletRepo.fetchWalletHistory();
          if (response.body['status'] == "success") {
            walletHistory = response.body['data']['data'] ?? [];
          }
          break;
      }
    } catch (e) {
      log('ERROR AT fetchHistoryData(): $e');
    }

    isHistoryLoading = false;
    update();
  }

  Future<void> fetchReserveHistory() async {
    try {
      Response response = await walletRepo.fetchReserveHistory();
      if (response.body['status'] == "success") {
        reserveHistory = response.body['data']['history'] ?? [];

        // Calculate total reserved amount from active history items
        totalReservedAmount = 0.0;
        for (var item in reserveHistory) {
          if (item['status'] == 'active') {
            totalReservedAmount += (item['amount'] as num?)?.toDouble() ?? 0.0;
          }
        }
      }
    } catch (e) {
      log('ERROR AT fetchReserveHistory(): $e');
    }
  }

  String currentWalletTransactionStatusType = "SUCCESS";
  TransactionModel? dynamicTransaction;

  String? adminUpiId;
  String? qrCodeUrl;

  final TransactionModel failedWalletTransaction = TransactionModel(
    transactionId: "#FT-829102",
    title: "Wallet Top Up",
    subtitle: "Transaction declined by bank",
    dateTime: DateTime(2026, 5, 20, 10, 30),
    paymentMode: "Dynamic QR / UPI",
    status: "FAILED",
    amount: 100.00,
    recipient: "Digital Curator LLC",
    payerVpa: "wallet@upi",
    gatewayId: "NA",
    rrnNumber: "NA",
    feePoints: 0,
    imagePath: "",
  );

  final TransactionModel successWalletTransaction = TransactionModel(
    transactionId: "#FT-829103",
    title: "Wallet Top Up",
    subtitle: "Money added to wallet successfully",
    dateTime: DateTime(2026, 5, 20, 10, 35),
    paymentMode: "Dynamic QR / UPI",
    status: "SUCCESS",
    amount: 100.00,
    recipient: "Digital Curator LLC",
    payerVpa: "wallet@upi",
    gatewayId: "NA",
    rrnNumber: "NA",
    feePoints: 0,
    imagePath: "",
  );

  final TransactionModel pendingWalletTransaction = TransactionModel(
    transactionId: "#FT-829104",
    title: "Wallet Top Up",
    subtitle: "Waiting for payment confirmation",
    dateTime: DateTime(2026, 5, 20, 10, 40),
    paymentMode: "Dynamic QR / UPI",
    status: "PENDING",
    amount: 100.00,
    recipient: "Digital Curator LLC",
    payerVpa: "wallet@upi",
    gatewayId: "NA",
    rrnNumber: "NA",
    feePoints: 0,
    imagePath: "",
  );

  final List<BillModel> billList = const [
    BillModel(
      category: "SUBSCRIPTION",
      billName: "Gym Fee",
      dueText: "Due in 2 days",
      amount: 0.00,
    ),
    BillModel(
      category: "RENT",
      billName: "Room Rent",
      dueText: "Due tomorrow",
      amount: 0.00,
    ),
    BillModel(
      category: "TRAINING",
      billName: "Personal Trainer",
      dueText: "Due in 5 days",
      amount: 0.00,
    ),
  ];

  final List<WalletTransactionModel> transactionHistory = [
    WalletTransactionModel(
      title: "Equinox Hudson Yards",
      subtitle: "Oct 24 • Gym",
      amount: 0.00,
      isExpense: true,
      icon: Icons.fitness_center_rounded,
      iconBackgroundColor: const Color(0xFFE7FFF8),
      iconColor: transactionSuccessText,
    ),
    const WalletTransactionModel(
      title: "Skyline Residency",
      subtitle: "Oct 22 • Rent",
      amount: 0.00,
      isExpense: true,
      icon: Icons.home_work_rounded,
      iconBackgroundColor: Color(0xFFEAF3FF),
      iconColor: Color(0xFF1A73E8),
    ),
    const WalletTransactionModel(
      title: "Wallet Top Up",
      subtitle: "Oct 20 • Added Money",
      amount: 0.00,
      isExpense: false,
      icon: Icons.account_balance_wallet_rounded,
      iconBackgroundColor: Color(0xFFEAF3FF),
      iconColor: Color(0xFF1A73E8),
    ),
  ];

  TransactionModel get currentWalletTransactionStatus {
    if (dynamicTransaction != null) {
      return dynamicTransaction!;
    }
    if (currentWalletTransactionStatusType == "SUCCESS") {
      return successWalletTransaction;
    } else if (currentWalletTransactionStatusType == "PENDING") {
      return pendingWalletTransaction;
    }

    return failedWalletTransaction;
  }

  @override
  void onClose() {
    addMoneyAmountController.dispose();
    utrController.dispose();
    withdrawalAmountController.dispose();
    withdrawalPaymentMethodController.dispose();
    withdrawalNotesController.dispose();
    super.onClose();
  }

  void changeBottomNavIndex(int index) {
    selectedBottomNavIndex = index;
    update();
  }

  void changePaymentFailedNavIndex(int index) {
    paymentFailedNavIndex = index;
    update();
  }

  void selectPresetAmount(int index) {
    selectedPresetIndex.value = index;
    addMoneyAmount.value = presetAmounts[index];
    addMoneyAmountController.text = addMoneyAmount.value.toStringAsFixed(2);
  }

  void updateAddMoneyAmount(String value) {
    final double? parsedAmount = double.tryParse(value);

    if (parsedAmount == null) {
      addMoneyAmount.value = 0;
      selectedPresetIndex.value = -1;
      return;
    }

    addMoneyAmount.value = parsedAmount;
    selectedPresetIndex.value = presetAmounts.indexOf(parsedAmount);
  }

  void selectPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  void setWalletTransactionStatusType(String status) {
    currentWalletTransactionStatusType = status;
    update();
  }

  void addMoney() {
    showToast(
      toastType: ToastType.success,
      message: "Add money action clicked",
    );
  }

  void tryAddMoneyAgain(BuildContext context) {
    navigate(
      context: context,
      page: const AddMoneyScreen(),
      isReplace: true,
    );
  }

  Future<void> shareWalletTransactionStatus() async {
    final transaction = currentWalletTransactionStatus;
    await SharePlus.instance.share(
      ShareParams(
        text: "Transaction Status: ${transaction.status}\n"
            "Amount: ₹${transaction.amount.toStringAsFixed(2)}\n"
            "Transaction ID: ${transaction.transactionId}\n"
            "Recipient: ${transaction.recipient}",
      ),
    );
  }

  void payBill(BillModel bill) {
    showToast(
      toastType: ToastType.success,
      message: "${bill.billName} payment started",
    );
  }

  void navigateToAddMoney(BuildContext context) {
    navigate(context: context, page: const AddMoneyScreen());
  }

  Future<ResponseModel> rechargeWallet(String utrNumber) async {
    ResponseModel responseModel;
    isLoading = true;
    adminUpiId = null;
    qrCodeUrl = null;
    update();

    try {
      Map<String, dynamic> body = {
        "amount": addMoneyAmount.value,
        "utr_number": utrNumber,
      };

      Response response = await walletRepo.rechargeWallet(body);

      if (response.body['status'] == "success") {
        var data = response.body['data'];

        dynamicTransaction = TransactionModel(
          transactionId: data['transaction_id'] ?? data['id'] ?? "N/A",
          title: "Wallet Top Up",
          subtitle: response.body['message'] ?? "Waiting for admin approval.",
          dateTime: DateTime.now(),
          paymentMode: selectedPaymentMethod.value.toUpperCase(),
          status: data['status']?.toString().toUpperCase() ?? "PENDING",
          amount: (data['amount'] as num?)?.toDouble() ?? addMoneyAmount.value,
          recipient: "FeeTrack Wallet",
          payerVpa: "N/A",
          gatewayId: "N/A",
          rrnNumber: utrNumber,
          feePoints: 0,
          imagePath: "",
        );

        setWalletTransactionStatusType(dynamicTransaction!.status);

        responseModel = ResponseModel(
            true,
            response.body['message'] ??
                "Recharge request submitted successfully.");
      } else {
        responseModel = ResponseModel(
            false,
            response.body['message'] ??
                "Error while submitting recharge request.");
      }
    } catch (e) {
      log('ERROR AT rechargeWallet(): $e');
      responseModel = ResponseModel(false, "Error while rechargeWallet $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> rechargeWalletInitiate() async {
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Map<String, dynamic> body = {
        "amount": addMoneyAmount.value,
      };

      Response response = await walletRepo.rechargeWalletInitiate(body);

      if (response.body['status'] == "success") {
        responseModel = ResponseModel(
          true,
          response.body['message'] ?? "Payment initiated successfully.",
          response.body,
        );
      } else {
        responseModel = ResponseModel(
          false,
          response.body['message'] ?? "Error while initiating payment.",
        );
      }
    } catch (e) {
      log('ERROR AT rechargeWalletInitiate(): $e');
      responseModel =
          ResponseModel(false, "Error while rechargeWalletInitiate $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> fetchRechargeConfig(double amount) async {
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Response response = await walletRepo.getRechargeConfig(amount);

      if (response.body['status'] == "success") {
        var data = response.body['data'];
        adminUpiId = data['admin_upi_id'];
        qrCodeUrl = data['qr_code_url'];
        responseModel = ResponseModel(true, "success");
      } else {
        responseModel =
            ResponseModel(false, response.body['message'] ?? "Error");
      }
    } catch (e) {
      log('ERROR AT fetchRechargeConfig(): $e');
      responseModel = ResponseModel(false, "Error $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  Future<ResponseModel> requestWithdrawal() async {
    ResponseModel responseModel;
    isLoading = true;
    update();

    try {
      Map<String, dynamic> body = {
        "amount": double.tryParse(withdrawalAmountController.text) ?? 0,
        "payment_method": withdrawalPaymentMethodController.text,
        "notes": withdrawalNotesController.text,
      };

      Response response = await walletRepo.requestWithdrawal(body);

      if (response.body['status'] == "success") {
        responseModel = ResponseModel(
            true,
            response.body['message'] ??
                "Withdrawal request submitted successfully.");
        withdrawalAmountController.clear();
        withdrawalPaymentMethodController.clear();
        withdrawalNotesController.clear();
      } else {
        responseModel = ResponseModel(
            false,
            response.body['message'] ??
                "Error while submitting withdrawal request.");
      }
    } catch (e) {
      log('ERROR AT requestWithdrawal(): $e');
      responseModel = ResponseModel(false, "Error while requestWithdrawal $e");
    }

    isLoading = false;
    update();
    return responseModel;
  }

  void viewAllTransactions() {
    showToast(
      toastType: ToastType.info,
      message: "View all transactions clicked",
    );
  }
}
