import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vlr/controllers/auth_controller.dart';

import '../../../../constants.dart';
import '../../../../controllers/address_controller.dart';
import '../../../../models/ecommerce_address_model.dart';

class AddNewAddressScreen extends StatefulWidget {
  final VoidCallback? onAddressSaved;
  final EcommerceAddressModel? addressToEdit;
  final String? storeDomain;

  const AddNewAddressScreen({
    super.key,
    this.onAddressSaved,
    this.addressToEdit,
    this.storeDomain,
  });

  @override
  State<AddNewAddressScreen> createState() => _AddNewAddressScreenState();
}

class _AddNewAddressScreenState extends State<AddNewAddressScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _zipController = TextEditingController();

  String _selectedAddressType = 'home';
  bool _isDefault = true;

  bool get _isEditing => widget.addressToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final addr = widget.addressToEdit!;
      _nameController.text = addr.name;
      _phoneController.text = addr.phone;
      _addressController.text = addr.address;
      _cityController.text = addr.city ?? '';
      _stateController.text = addr.state ?? '';
      _zipController.text = addr.zip ?? '';
      _selectedAddressType = addr.addressType.toLowerCase();
      _isDefault = addr.isDefault;
    } else {
      _prefillCustomerInfo();
    }

    // Check login after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!AddressController.instance.isLoggedIn) {
        AddressController.showLoginRequiredModal(
          context,
          title: "Login Required to Add Address",
          message:
              "Customer login is strictly required. Please login first to fill and save your delivery address.",
          onLoginSuccess: () {
            setState(() {
              _prefillCustomerInfo();
            });
          },
        );
      }
    });
  }

  void _prefillCustomerInfo() {
    final customer = AddressController.instance.customer;
    if (customer != null) {
      if (customer.name.isNotEmpty && _nameController.text.isEmpty) {
        _nameController.text = customer.name;
      }
      if (customer.phone.isNotEmpty && _phoneController.text.isEmpty) {
        _phoneController.text = customer.phone;
      }
    } else if (Get.isRegistered<AuthController>()) {
      final authCtrl = Get.find<AuthController>();
      final user = authCtrl.userModel;
      if (user != null) {
        if (_nameController.text.isEmpty && user.name != null && user.name!.isNotEmpty) {
          _nameController.text = user.name!;
        }
        if (_phoneController.text.isEmpty && user.phone != null && user.phone.toString().isNotEmpty) {
          _phoneController.text = user.phone.toString();
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }

  Future<void> _submitAddress() async {
    // If user is not logged in, show required login modal first!
    if (!AddressController.instance.isLoggedIn) {
      final didLogin = await AddressController.showLoginRequiredModal(
        context,
        title: "Login Required",
        message:
            "Customer login is strictly required. Please pass a valid Bearer Token in Authorization header (Authorization: Bearer <token>).",
        onLoginSuccess: () {
          setState(() {
            _prefillCustomerInfo();
          });
        },
      );
      if (didLogin != true && !AddressController.instance.isLoggedIn) {
        return;
      }
    }

    if (!_formKey.currentState!.validate()) return;

    final effectiveDomain = widget.storeDomain ??
        widget.addressToEdit?.domain ??
        AddressController.instance.activeDomain;

    final addressModel = EcommerceAddressModel(
      id: widget.addressToEdit?.id,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zip: _zipController.text.trim(),
      addressType: _selectedAddressType,
      isDefault: _isDefault,
      domain: effectiveDomain,
      customerId: widget.addressToEdit?.customerId,
      country: widget.addressToEdit?.country ?? 'IN',
    );

    final bool success;
    if (_isEditing) {
      success = await AddressController.instance.updateAddress(
        address: addressModel,
        domain: effectiveDomain,
      );
    } else {
      success = await AddressController.instance.saveAddress(
        address: addressModel,
        domain: effectiveDomain,
      );
    }

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(_isEditing
                    ? "Delivery address updated successfully!"
                    : "Delivery address saved successfully!"),
              ],
            ),
            backgroundColor: successColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
        widget.onAddressSaved?.call();
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing
                ? "Failed to update address. Please try again."
                : "Failed to save address. Please try again."),
            backgroundColor: errorColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    return AnimatedBuilder(
      animation: AddressController.instance,
      builder: (context, _) {
        final isSaving = AddressController.instance.isSaving;
        final isLoggedIn = AddressController.instance.isLoggedIn;

        return Scaffold(
          backgroundColor: bodyBg,
          appBar: AppBar(
            backgroundColor: bodyBg,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              _isEditing ? "Edit Delivery Address" : "Add New Delivery Address",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: 8),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Banner Header
                  _buildHeaderBanner(isDark),

                  const SizedBox(height: 16),

                  // Auth Status Notice if not logged in
                  if (!isLoggedIn) ...[
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: warningColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: warningColor.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: warningColor, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Login Required",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: blackColor,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Customer login is required before saving address. Tap to login.",
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: blackColor.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              AddressController.showLoginRequiredModal(
                                context,
                                onLoginSuccess: () {
                                  setState(() {
                                    _prefillCustomerInfo();
                                  });
                                },
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Section 1: Contact Details
                  _buildSectionHeader(
                    title: "Contact Person Details",
                    subtitle: "Delivery person will contact this receiver",
                    icon: Icons.person_pin_rounded,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          textInputAction: TextInputAction.next,
                          decoration: _buildInputDecoration(
                            label: "Receiver's Full Name *",
                            hint: "e.g. Arjun Kumar",
                            prefixIcon: Icons.person_outline_rounded,
                            isDark: isDark,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter recipient name";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          textInputAction: TextInputAction.next,
                          decoration: _buildInputDecoration(
                            label: "Phone Number *",
                            hint: "10-digit mobile number",
                            prefixIcon: Icons.phone_android_rounded,
                            isDark: isDark,
                            counterText: "",
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter mobile number";
                            }
                            if (value.trim().length < 10) {
                              return "Please enter a valid 10-digit number";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 2: Address Location
                  _buildSectionHeader(
                    title: "Delivery Address Details",
                    subtitle: "Complete address for accurate doorstep arrival",
                    icon: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _addressController,
                          maxLines: 2,
                          textInputAction: TextInputAction.next,
                          decoration: _buildInputDecoration(
                            label: "Flat, House no., Building, Street *",
                            hint: "e.g. Flat 402, Lotus Arena, Sector 62",
                            prefixIcon: Icons.home_work_outlined,
                            isDark: isDark,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter street address";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                textInputAction: TextInputAction.next,
                                decoration: _buildInputDecoration(
                                  label: "City *",
                                  hint: "e.g. Lucknow",
                                  prefixIcon: Icons.location_city_rounded,
                                  isDark: isDark,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Enter city";
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _stateController,
                                textInputAction: TextInputAction.next,
                                decoration: _buildInputDecoration(
                                  label: "State *",
                                  hint: "e.g. UP",
                                  prefixIcon: Icons.map_outlined,
                                  isDark: isDark,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Enter state";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _zipController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textInputAction: TextInputAction.done,
                          decoration: _buildInputDecoration(
                            label: "Pincode / Zip Code *",
                            hint: "e.g. 226016",
                            prefixIcon: Icons.pin_drop_outlined,
                            isDark: isDark,
                            counterText: "",
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return "Please enter pincode";
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Section 3: Address Type Selection
                  _buildSectionHeader(
                    title: "Save Address As",
                    subtitle: "Helps us tag your delivery address",
                    icon: Icons.bookmarks_rounded,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildTypeChip("home", "Home", Icons.home_rounded, isDark),
                      const SizedBox(width: 10),
                      _buildTypeChip(
                          "work", "Work / Office", Icons.work_rounded, isDark),
                      const SizedBox(width: 10),
                      _buildTypeChip(
                          "other", "Other", Icons.location_on_rounded, isDark),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Default Switch Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Make this default address",
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "Will be selected automatically for your future orders",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: greyColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: _isDefault,
                          activeTrackColor: primaryColor,
                          onChanged: (val) {
                            setState(() {
                              _isDefault = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Bottom Sticky Save Button
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding * 0.75,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 50,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submitAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              _isEditing
                                  ? "UPDATE DELIVERY ADDRESS"
                                  : "SAVE & DELIVER TO THIS ADDRESS",
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBanner(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primaryColor.withValues(alpha: 0.12),
            primaryColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_location_alt_rounded,
              color: primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditing
                      ? "Update Delivery Location"
                      : "Add New Delivery Address",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Enter recipient and address details for fast, reliable doorstep shipping.",
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white70 : blackColor60,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String label,
    required String hint,
    required IconData prefixIcon,
    required bool isDark,
    String? counterText,
  }) {
    final borderSide = BorderSide(
      color: isDark ? Colors.white24 : Colors.grey.shade300,
      width: 1,
    );

    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 13,
        color: isDark ? Colors.white70 : blackColor60,
        fontWeight: FontWeight.w500,
      ),
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12,
        color: isDark ? Colors.white38 : Colors.black38,
      ),
      counterText: counterText,
      prefixIcon: Icon(prefixIcon, size: 20, color: primaryColor),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      filled: true,
      fillColor: isDark
          ? Colors.white.withValues(alpha: 0.03)
          : const Color(0xFFF9F9FC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: borderSide,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: borderSide,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorColor, width: 1.6),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryColor),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: greyColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeChip(
      String type, String label, IconData icon, bool isDark) {
    final isSelected = _selectedAddressType == type;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedAddressType = type;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: 0.12)
                : (isDark ? darkGreyColor : Colors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isDark ? Colors.white12 : Colors.grey.shade300),
              width: isSelected ? 1.8 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? primaryColor : greyColor,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? primaryColor
                      : (isDark ? Colors.white70 : blackColor80),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
