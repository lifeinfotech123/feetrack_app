import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vlr/services/app_router.dart';
import 'package:vlr/services/constants.dart' as vlr_constants;
import 'package:vlr/views/screens/auth_screens/login/login_screen.dart';

import '../constants.dart';
import '../models/ecommerce_address_model.dart';
import '../services/address_service.dart';

class AddressController extends ChangeNotifier {
  static final AddressController instance = AddressController._internal();
  AddressController._internal();

  final AddressService _apiService = AddressService();

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isLoggedIn = false;
  String _loginRequiredMessage =
      "Customer login is strictly required. Please pass a valid Bearer Token in Authorization header (Authorization: Bearer <token>).";
  CustomerProfileModel? _customer;
  List<EcommerceAddressModel> _addresses = [];
  EcommerceAddressModel? _selectedAddress;

  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  bool get isLoggedIn => _isLoggedIn;
  String get loginRequiredMessage => _loginRequiredMessage;
  CustomerProfileModel? get customer => _customer;
  List<EcommerceAddressModel> get addresses => List.unmodifiable(_addresses);
  EcommerceAddressModel? get selectedAddress => _selectedAddress;

  String _activeDomain = 'e-team-12';
  String get activeDomain => _activeDomain;

  void setActiveDomain(String domain) {
    if (domain.trim().isNotEmpty) {
      _activeDomain = domain.trim();
    }
  }

  /// Check whether user is currently logged in via AuthController or SharedPreferences
  Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    var token = prefs.getString(vlr_constants.AppConstants.token) ??
        prefs.getString('user_app_token') ??
        prefs.getString('token') ??
        '';

    _isLoggedIn = token.isNotEmpty;
    return _isLoggedIn;
  }

  /// Fetch addresses from live API (api/v1/ecommerce/addresses?domain=...&user_id=...)
  Future<void> fetchAddresses({String? domain, bool force = false}) async {
    if (domain != null && domain.trim().isNotEmpty) {
      _activeDomain = domain.trim();
    }
    final effectiveDomain = _activeDomain;

    _isLoading = true;
    notifyListeners();

    await checkLoginStatus();
    final prefs = await SharedPreferences.getInstance();

    try {
      final response =
          await _apiService.getCustomerAddresses(domain: effectiveDomain);
      _isLoggedIn = response.isLoggedIn;
      _loginRequiredMessage = response.message;

      if (response.customer != null) {
        _customer = response.customer;
      }

      if (response.data.isNotEmpty) {
        _addresses = response.data;
        _saveCachedAddresses(prefs, _addresses);
      } else {
        // If API returned empty for this domain (e.g. 25-ecomm),
        // check if user has an existing address from another domain/cached
        _loadCachedAddresses(prefs);

        if (_addresses.isNotEmpty) {
          final existing = _selectedAddress ?? _addresses.first;
          debugPrint(
              'AddressController: Auto-registering delivery address to domain: $effectiveDomain');
          final saveRes = await _apiService.saveCustomerAddress(
            address: existing,
            domain: effectiveDomain,
          );
          if (saveRes['status'] == true) {
            final refreshed =
                await _apiService.getCustomerAddresses(domain: effectiveDomain);
            if (refreshed.data.isNotEmpty) {
              _addresses = refreshed.data;
              _saveCachedAddresses(prefs, _addresses);
            }
          }
        }
      }

      _normalizeDefaultAndSelection(prefs);
    } catch (e) {
      debugPrint('AddressController fetchAddresses error: $e');
      _loadCachedAddresses(prefs);
      _normalizeDefaultAndSelection(prefs);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Save new address via POST api/v1/ecommerce/addresses & local cache
  Future<bool> saveAddress({
    required EcommerceAddressModel address,
    String? domain,
  }) async {
    _isSaving = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _apiService.saveCustomerAddress(
        address: address,
        domain: domain,
      );

      final isSuccess = response['status'] == true;

      // Create address with generated id if needed
      final newId = response['data'] != null && response['data']['id'] != null
          ? (response['data']['id'] is int
              ? response['data']['id'] as int
              : int.tryParse('${response['data']['id']}'))
          : DateTime.now().millisecondsSinceEpoch;

      final savedAddress = address.copyWith(id: newId);

      // Add to list and update selection
      _addresses = [
        savedAddress,
        ..._addresses.where((a) => a.id != savedAddress.id),
      ];

      _selectedAddress = savedAddress;
      if (savedAddress.id != null) {
        await prefs.setInt('ecommerce_selected_address_id', savedAddress.id!);
      }
      await _saveCachedAddresses(prefs, _addresses);

      _isSaving = false;
      notifyListeners();
      return isSuccess || true;
    } catch (e) {
      debugPrint('AddressController saveAddress error: $e');
      // Save locally so user experience isn't blocked
      final savedAddress = address.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
      );
      _addresses = [savedAddress, ..._addresses];
      _selectedAddress = savedAddress;
      await _saveCachedAddresses(prefs, _addresses);

      _isSaving = false;
      notifyListeners();
      return true;
    }
  }

  /// Update existing delivery address
  Future<bool> updateAddress({
    required EcommerceAddressModel address,
    String? domain,
  }) async {
    _isSaving = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _apiService.updateCustomerAddress(
        address: address,
        domain: domain,
      );

      EcommerceAddressModel updatedAddress = address;
      if (response['status'] == true &&
          response['data'] != null &&
          response['data'] is Map) {
        try {
          updatedAddress = EcommerceAddressModel.fromJson(
            Map<String, dynamic>.from(response['data']),
          );
        } catch (_) {}
      }

      _addresses = _addresses.map((a) {
        if (a.id == address.id || a.id == updatedAddress.id) {
          return updatedAddress;
        }
        return a;
      }).toList();

      if (_selectedAddress?.id == address.id ||
          _selectedAddress?.id == updatedAddress.id) {
        _selectedAddress = updatedAddress;
      }
      await _saveCachedAddresses(prefs, _addresses);

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('AddressController updateAddress error: $e');
      _addresses = _addresses.map((a) {
        if (a.id == address.id) {
          return address;
        }
        return a;
      }).toList();
      if (_selectedAddress?.id == address.id) {
        _selectedAddress = address;
      }
      await _saveCachedAddresses(prefs, _addresses);
      _isSaving = false;
      notifyListeners();
      return true;
    }
  }

  /// Delete delivery address (DELETE api/v1/ecommerce/addresses/delete)
  Future<Map<String, dynamic>> deleteAddress(int addressId, {String? domain}) async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final response = await _apiService.deleteCustomerAddress(
        addressId: addressId,
        domain: domain,
      );

      _addresses = _addresses.where((a) => a.id != addressId).toList();

      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
        if (_selectedAddress?.id != null) {
          await prefs.setInt(
              'ecommerce_selected_address_id', _selectedAddress!.id!);
        } else {
          await prefs.remove('ecommerce_selected_address_id');
        }
      }
      await _saveCachedAddresses(prefs, _addresses);

      notifyListeners();
      return response;
    } catch (e) {
      debugPrint('AddressController deleteAddress error: $e');
      _addresses = _addresses.where((a) => a.id != addressId).toList();
      if (_selectedAddress?.id == addressId) {
        _selectedAddress = _addresses.isNotEmpty ? _addresses.first : null;
      }
      await _saveCachedAddresses(prefs, _addresses);
      notifyListeners();
      return {
        'status': false,
        'message': e.toString(),
      };
    }
  }

  /// Set the active selected delivery address
  void selectAddress(EcommerceAddressModel address) async {
    _selectedAddress = address;
    notifyListeners();
    if (address.id != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('ecommerce_selected_address_id', address.id!);
    }
  }

  void _loadCachedAddresses(SharedPreferences prefs) {
    try {
      final jsonStr = prefs.getString('ecommerce_saved_addresses');
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List list = jsonDecode(jsonStr);
        _addresses = list
            .map((item) =>
                EcommerceAddressModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
    } catch (_) {}
    _normalizeDefaultAndSelection(prefs);
  }

  void _normalizeDefaultAndSelection(SharedPreferences prefs) {
    if (_addresses.isEmpty) return;

    final defaultIndex = _addresses.indexWhere((a) => a.isDefault);
    final targetDefaultIndex = defaultIndex >= 0 ? defaultIndex : 0;

    _addresses = _addresses.asMap().entries.map((entry) {
      final idx = entry.key;
      final addr = entry.value;
      final isDef = idx == targetDefaultIndex;
      if (addr.isDefault != isDef) {
        return addr.copyWith(isDefault: isDef);
      }
      return addr;
    }).toList();

    final savedSelectedId = prefs.getInt('ecommerce_selected_address_id');
    if (savedSelectedId != null &&
        _addresses.any((a) => a.id == savedSelectedId)) {
      _selectedAddress = _addresses.firstWhere(
        (a) => a.id == savedSelectedId,
      );
    } else {
      _selectedAddress = _addresses[targetDefaultIndex];
    }
  }

  Future<void> _saveCachedAddresses(
      SharedPreferences prefs, List<EcommerceAddressModel> list) async {
    try {
      final jsonList = list.map((a) => a.toJson()).toList();
      await prefs.setString('ecommerce_saved_addresses', jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Helper modal to show standard Login Required prompt when customer is not logged in
  static Future<bool?> showLoginRequiredModal(
    BuildContext context, {
    String? title,
    String? message,
    VoidCallback? onLoginSuccess,
  }) async {
    return await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E28) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Lock Icon Badge
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: primaryColor,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),

              // Title
              Text(
                title ?? "Login Required",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : blackColor,
                ),
              ),
              const SizedBox(height: 10),

              // Message
              Text(
                message ??
                    "Customer login is strictly required. Please login first to fill and manage your delivery address.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white70 : blackColor60,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(
                          color: isDark ? Colors.white24 : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadious),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : blackColor80,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx, true);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        );
                        AppRouter.goToLogin();

                        // After returning from login, re-check status & reload
                        await instance.fetchAddresses();
                        if (instance.isLoggedIn && onLoginSuccess != null) {
                          onLoginSuccess();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(defaultBorderRadious),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.login_rounded,
                              size: 18, color: Colors.white),
                          SizedBox(width: 6),
                          Text(
                            "Login Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
