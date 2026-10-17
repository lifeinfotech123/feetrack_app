import 'dart:developer';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';
import 'package:vlr/services/constants.dart';

import '../data/model/medicine_model.dart';
import '../data/model/pharmacy_category_model.dart';
import '../data/model/pharmacy_store_model.dart';
import '../data/model/order_model.dart';
import '../data/model/pharmacy_invoice_model.dart';
import '../data/reposetries/pharmacy_repo.dart';

class PharmacyController extends GetxController implements GetxService {
  final PharmacyRepo pharmacyRepo;

  PharmacyController({PharmacyRepo? pharmacyRepo})
      : pharmacyRepo = pharmacyRepo ??
            (Get.isRegistered<PharmacyRepo>()
                ? Get.find<PharmacyRepo>()
                : Get.put(PharmacyRepo()));

  bool get isLoggedIn =>
      Get.isRegistered<AuthController>() &&
      Get.find<AuthController>().isLoggedIn();

  // ----------------- Observables & States -----------------
  final RxBool isLoading = false.obs;
  final RxBool isMedicinesLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxBool isCategoriesLoading = false.obs;
  final RxBool isStoresLoading = false.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxBool isVerifyingPayment = false.obs;
  final RxBool isInvoiceLoading = false.obs;

  final RxString errorMessage = ''.obs;

  // Data lists
  final RxList<MedicineModel> catalogMedicines = <MedicineModel>[].obs;
  final RxList<MedicineModel> medicines = <MedicineModel>[].obs;
  final RxList<PharmacyCategoryModel> categories = <PharmacyCategoryModel>[].obs;
  final RxList<PharmacyStoreModel> stores = <PharmacyStoreModel>[].obs;

  // Detail selections
  final Rxn<MedicineModel> selectedMedicine = Rxn<MedicineModel>();
  final Rxn<PharmacyCategoryModel> selectedCategory = Rxn<PharmacyCategoryModel>();

  // Cart
  final RxMap<String, CartItem> cart = <String, CartItem>{}.obs;

  // Order & Payment
  final Rxn<PlaceOrderResponse> currentOrder = Rxn<PlaceOrderResponse>();
  final Rxn<VerifyPaymentResponse> verifiedPayment = Rxn<VerifyPaymentResponse>();
  final Rxn<PharmacyInvoiceModel> currentInvoice = Rxn<PharmacyInvoiceModel>();

  // Patient Booked Medicine Orders
  final RxList<PatientMedicineOrder> patientOrders = <PatientMedicineOrder>[].obs;
  final RxBool isOrdersLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initPharmacyData();
  }

  Future<void> initPharmacyData() async {
    await Future.wait([
      fetchCatalog(),
      fetchCategories(),
      fetchStores(),
      fetchMedicines(),
      fetchPatientOrders(),
    ]);
  }

  // ----------------- Cart Operations -----------------

  int get cartCount => cart.length;

  int get cartTotalItems {
    return cart.values.fold(0, (sum, item) => sum + item.qty);
  }

  num get cartSubtotal {
    return cart.values.fold(0, (sum, item) => sum + item.totalItemPrice);
  }

  num get cartTax {
    return cart.values.fold(0, (sum, item) => sum + item.totalItemTax);
  }

  num get cartDeliveryFee {
    if (cart.isEmpty) return 0;
    // Check if store specifies delivery fee
    if (stores.isNotEmpty) {
      final store = stores.first;
      if (store.minFreeDeliveryAmount > 0 && cartSubtotal >= store.minFreeDeliveryAmount) {
        return 0;
      }
      return store.deliveryCharge > 0 ? store.deliveryCharge : 40;
    }
    return 40;
  }

  num get cartGrandTotal {
    if (cart.isEmpty) return 0;
    final total = cartSubtotal + cartTax + cartDeliveryFee;
    return double.parse(total.toStringAsFixed(2));
  }

  bool isInCart(MedicineModel medicine) {
    return cart.containsKey(medicine.cartKey);
  }

  int getMedicineQuantity(MedicineModel medicine) {
    return cart[medicine.cartKey]?.qty ?? 0;
  }

  void addToCart(MedicineModel medicine, {int qty = 1, AvailableBatch? batch}) {
    // If cart has items from another hospital, switch store cleanly
    if (cart.isNotEmpty) {
      final existingHosp = cart.values.first.medicine.hospital?.domain;
      final newHosp = medicine.hospital?.domain;
      if (existingHosp != null && newHosp != null && existingHosp != newHosp) {
        cart.clear();
        try {
          showToast(
            message: 'Switched store to ${medicine.hospital?.name ?? newHosp}',
            toastType: ToastType.warning,
          );
        } catch (_) {}
      }
    }

    final key = medicine.cartKey;
    if (cart.containsKey(key)) {
      cart[key]!.qty += qty;
    } else {
      cart[key] = CartItem(
        medicine: medicine,
        qty: qty,
        selectedBatch: batch ?? (medicine.availableBatches.isNotEmpty ? medicine.availableBatches.first : null),
      );
    }
    cart.refresh();
    try {
      showToast(
        message: '${medicine.name} added to cart',
        toastType: ToastType.success,
      );
    } catch (_) {}
  }

  void updateQuantity(dynamic itemOrKey, int newQty) {
    String? key;
    if (itemOrKey is MedicineModel) {
      key = itemOrKey.cartKey;
    } else if (itemOrKey is CartItem) {
      key = itemOrKey.cartKey;
    } else if (itemOrKey is String) {
      key = itemOrKey;
    } else if (itemOrKey is int) {
      for (final k in cart.keys) {
        if (cart[k]?.medicine.id == itemOrKey) {
          key = k;
          break;
        }
      }
    }

    if (key == null) return;

    if (newQty <= 0) {
      removeFromCart(key);
    } else if (cart.containsKey(key)) {
      cart[key]!.qty = newQty;
      cart.refresh();
    }
  }

  void removeFromCart(dynamic itemOrKey) {
    String? key;
    if (itemOrKey is MedicineModel) {
      key = itemOrKey.cartKey;
    } else if (itemOrKey is CartItem) {
      key = itemOrKey.cartKey;
    } else if (itemOrKey is String) {
      key = itemOrKey;
    } else if (itemOrKey is int) {
      for (final k in cart.keys) {
        if (cart[k]?.medicine.id == itemOrKey) {
          key = k;
          break;
        }
      }
    }

    if (key != null && cart.containsKey(key)) {
      cart.remove(key);
      cart.refresh();
    }
  }

  void clearCart() {
    cart.clear();
    cart.refresh();
  }

  // ----------------- 1. Fetch Catalog Listing -----------------
  Future<void> fetchCatalog({String? search}) async {
    try {
      isLoading.value = true;
      final response = await pharmacyRepo.getPharmacyCatalog(search: search);

      if (response['status'] == true && response['data'] is List) {
        final List list = response['data'];
        catalogMedicines.assignAll(
          list.map((e) => MedicineModel.fromJson(Map<String, dynamic>.from(e))).toList(),
        );

        // Also update categories and stores if present in response
        if (response['categories'] is List && (response['categories'] as List).isNotEmpty) {
          final catList = response['categories'] as List;
          categories.assignAll(
            catList.map((e) => PharmacyCategoryModel.fromJson(Map<String, dynamic>.from(e))).toList(),
          );
        }

        if (response['pharmacies'] is List && (response['pharmacies'] as List).isNotEmpty) {
          final pList = response['pharmacies'] as List;
          stores.assignAll(
            pList.map((e) => PharmacyStoreModel.fromJson(Map<String, dynamic>.from(e))).toList(),
          );
        }
      }
    } catch (e) {
      log('Error fetching pharmacy catalog: $e', name: 'PharmacyController');
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------- 2. Fetch Medicines Listing -----------------
  Future<void> fetchMedicines({String? search, int? categoryId}) async {
    try {
      isMedicinesLoading.value = true;
      final response = await pharmacyRepo.getPharmacyMedicines(
        search: search,
        categoryId: categoryId,
      );

      if (response['status'] == true && response['data'] is List) {
        final List list = response['data'];
        medicines.assignAll(
          list.map((e) => MedicineModel.fromJson(Map<String, dynamic>.from(e))).toList(),
        );

        if (response['categories'] is List && (response['categories'] as List).isNotEmpty) {
          final catList = response['categories'] as List;
          categories.assignAll(
            catList.map((e) => PharmacyCategoryModel.fromJson(Map<String, dynamic>.from(e))).toList(),
          );
        }

        if (response['pharmacies'] is List && (response['pharmacies'] as List).isNotEmpty) {
          final pList = response['pharmacies'] as List;
          stores.assignAll(
            pList.map((e) => PharmacyStoreModel.fromJson(Map<String, dynamic>.from(e))).toList(),
          );
        }
      }
    } catch (e) {
      log('Error fetching medicines: $e', name: 'PharmacyController');
    } finally {
      isMedicinesLoading.value = false;
    }
  }

  // ----------------- 3. Fetch Medicine Details By ID -----------------
  Future<MedicineModel?> fetchMedicineDetails(dynamic id) async {
    try {
      isDetailsLoading.value = true;
      final response = await pharmacyRepo.getMedicineById(id);

      if (response['status'] == true && response['data'] is Map) {
        final model = MedicineModel.fromJson(Map<String, dynamic>.from(response['data']));
        selectedMedicine.value = model;
        return model;
      }
    } catch (e) {
      log('Error fetching medicine details: $e', name: 'PharmacyController');
    } finally {
      isDetailsLoading.value = false;
    }
    return null;
  }

  // ----------------- 4. Fetch Categories -----------------
  Future<void> fetchCategories({String? search}) async {
    try {
      isCategoriesLoading.value = true;
      final response = await pharmacyRepo.getPharmacyCategories(search: search);

      if (response['status'] == true && response['data'] is List) {
        final List list = response['data'];
        categories.assignAll(
          list.map((e) => PharmacyCategoryModel.fromJson(Map<String, dynamic>.from(e))).toList(),
        );
      }
    } catch (e) {
      log('Error fetching categories: $e', name: 'PharmacyController');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  // ----------------- 5. Fetch Stores -----------------
  Future<void> fetchStores({String? search}) async {
    try {
      isStoresLoading.value = true;
      final response = await pharmacyRepo.getPharmacyStores(search: search);

      if (response['status'] == true && response['data'] is List) {
        final List list = response['data'];
        stores.assignAll(
          list.map((e) => PharmacyStoreModel.fromJson(Map<String, dynamic>.from(e))).toList(),
        );
      }
    } catch (e) {
      log('Error fetching stores: $e', name: 'PharmacyController');
    } finally {
      isStoresLoading.value = false;
    }
  }

  // ----------------- 6. Place Order -----------------
  Future<PlaceOrderResponse?> placeOrder({
    required String customerName,
    required String customerPhone,
    required String customerEmail,
    required String shippingAddress,
    String paymentMode = 'online',
    String? hospital,
    List<PlaceOrderItem>? customItems,
  }) async {
    try {
      isPlacingOrder.value = true;
      errorMessage.value = '';

      final itemsToSend = customItems ??
          cart.values.map((c) => PlaceOrderItem(id: c.medicine.id, qty: c.qty)).toList();

      if (itemsToSend.isEmpty) {
        showToast(message: 'Your cart is empty', toastType: ToastType.warning);
        return null;
      }

      // Automatically resolve hospital dynamically from cart items, stores, or fallback to 'usha'
      final resolvedHospital = (hospital != null && hospital.isNotEmpty)
          ? hospital
          : (cart.isNotEmpty && cart.values.first.medicine.hospital?.domain != null && cart.values.first.medicine.hospital!.domain!.isNotEmpty
              ? cart.values.first.medicine.hospital!.domain!
              : (stores.isNotEmpty && stores.first.hospitalDomain != null && stores.first.hospitalDomain!.isNotEmpty
                  ? stores.first.hospitalDomain!
                  : (categories.isNotEmpty && categories.first.hospitalDomain != null && categories.first.hospitalDomain!.isNotEmpty
                      ? categories.first.hospitalDomain!
                      : 'usha')));

      final req = PlaceOrderRequest(
        customerName: customerName,
        customerPhone: customerPhone,
        customerEmail: customerEmail,
        shippingAddress: shippingAddress,
        paymentMode: paymentMode,
        hospital: resolvedHospital,
        items: itemsToSend,
      );

      final response = await pharmacyRepo.placeOrder(req.toJson());

      if (response['status'] == true || response['success'] == true || response['data'] != null) {
        Map<String, dynamic> dataMap = {};
        if (response['data'] is Map) {
          dataMap = Map<String, dynamic>.from(response['data']);
        } else if (response['data'] is List && (response['data'] as List).isNotEmpty) {
          dataMap = Map<String, dynamic>.from((response['data'] as List).first);
        } else {
          dataMap = Map<String, dynamic>.from(response);
        }

        final orderRes = PlaceOrderResponse.fromJson(
          dataMap,
          msg: response['message']?.toString(),
        );
        currentOrder.value = orderRes;

        // Only clear cart immediately if Cash on Delivery.
        // For online payment, cart will be cleared once Razorpay verification succeeds!
        if (paymentMode == 'cash' ||
            paymentMode == 'cod' ||
            paymentMode.toLowerCase().contains('cash') ||
            paymentMode.toLowerCase().contains('cod')) {
          clearCart();
        }

        // Refresh patient orders list in background
        fetchPatientOrders();

        return orderRes;
      } else {
        String msg = response['message']?.toString() ?? 'Failed to place order';
        if (response['errors'] is Map) {
          final errMap = Map<String, dynamic>.from(response['errors']);
          final errorList = <String>[];
          errMap.forEach((key, val) {
            if (val is List && val.isNotEmpty) {
              errorList.add(val.first.toString());
            } else if (val is String) {
              errorList.add(val);
            }
          });
          if (errorList.isNotEmpty) {
            msg = errorList.join('\n');
          }
        }
        errorMessage.value = msg;
        try {
          showToast(
            message: msg,
            toastType: ToastType.error,
          );
        } catch (_) {}
      }
    } catch (e) {
      log('Error placing order: $e', name: 'PharmacyController');
      errorMessage.value = e.toString();
      try {
        showToast(message: 'Error: $e', toastType: ToastType.error);
      } catch (_) {}
    } finally {
      isPlacingOrder.value = false;
    }
    return null;
  }

  // ----------------- 7. Verify Payment -----------------
  Future<VerifyPaymentResponse?> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String groupOrderNo,
    required int billId,
    String? hospital,
  }) async {
    try {
      isVerifyingPayment.value = true;
      errorMessage.value = '';

      final resolvedHospital = (hospital != null && hospital.isNotEmpty)
          ? hospital
          : (currentOrder.value?.hospital?.domain ??
              (cart.isNotEmpty && cart.values.first.medicine.hospital?.domain != null
                  ? cart.values.first.medicine.hospital!.domain!
                  : (stores.isNotEmpty && stores.first.hospitalDomain != null ? stores.first.hospitalDomain! : '')));

      final req = VerifyPaymentRequest(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        groupOrderNo: groupOrderNo,
        billId: billId,
        hospital: resolvedHospital,
      );

      final response = await pharmacyRepo.verifyPayment(req.toJson());

      if (response['status'] == true && response['data'] is Map) {
        final verifyRes = VerifyPaymentResponse.fromJson(
          Map<String, dynamic>.from(response['data']),
          msg: response['message']?.toString(),
        );
        verifiedPayment.value = verifyRes;
        if (verifyRes.success) {
          clearCart();
          fetchPatientOrders();
        }
        return verifyRes;
      } else {
        final msg = response['message']?.toString() ?? 'Verification failed';
        errorMessage.value = msg;
        try {
          showToast(
            message: msg,
            toastType: ToastType.error,
          );
        } catch (_) {}
      }
    } catch (e) {
      log('Error verifying payment: $e', name: 'PharmacyController');
      errorMessage.value = e.toString();
      try {
        showToast(message: 'Verification Error: $e', toastType: ToastType.error);
      } catch (_) {}
    } finally {
      isVerifyingPayment.value = false;
    }
    return null;
  }

  // ----------------- 8. Fetch Invoice Details -----------------
  Future<PharmacyInvoiceModel?> fetchInvoice(dynamic billId) async {
    try {
      isInvoiceLoading.value = true;
      final response = await pharmacyRepo.getInvoiceById(billId);

      if (response['status'] == true && response['data'] is Map) {
        final invoice = PharmacyInvoiceModel.fromJson(Map<String, dynamic>.from(response['data']));
        currentInvoice.value = invoice;
        return invoice;
      } else {
        showToast(
          message: response['message']?.toString() ?? 'Invoice not found',
          toastType: ToastType.error,
        );
      }
    } catch (e) {
      log('Error fetching invoice: $e', name: 'PharmacyController');
    } finally {
      isInvoiceLoading.value = false;
    }
    return null;
  }

  // ----------------- 9. Fetch Patient Booked Medicine Orders -----------------
  Future<void> fetchPatientOrders() async {
    if (!isLoggedIn) {
      patientOrders.clear();
      isOrdersLoading.value = false;
      return;
    }
    try {
      isOrdersLoading.value = true;
      final response = await pharmacyRepo.getPatientMedicineOrders();

      if (response['status'] == true && response['data'] is List) {
        final List list = response['data'];
        patientOrders.assignAll(
          list.map((e) => PatientMedicineOrder.fromJson(Map<String, dynamic>.from(e))).toList(),
        );
      }
    } catch (e) {
      log('Error fetching patient medicine orders: $e', name: 'PharmacyController');
    } finally {
      isOrdersLoading.value = false;
    }
  }
}