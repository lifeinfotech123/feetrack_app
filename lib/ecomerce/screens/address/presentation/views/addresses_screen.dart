import 'package:flutter/material.dart';
import '../../../../constants.dart';
import '../../../../controllers/address_controller.dart';
import '../../../../models/ecommerce_address_model.dart';
import '../../../checkout/views/payment_method_screen.dart';
import 'add_new_address_screen.dart';

class AddressesScreen extends StatefulWidget {
  final bool selectAndReturn;
  final String? storeDomain;

  const AddressesScreen({
    super.key,
    this.selectAndReturn = false,
    this.storeDomain,
  });

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AddressController.instance.fetchAddresses(domain: widget.storeDomain);
    });
  }

  void _openAddNewAddress() async {
    final isLoggedIn = AddressController.instance.isLoggedIn;
    if (!isLoggedIn) {
      final loggedIn = await AddressController.showLoginRequiredModal(
        context,
        title: "Login Required",
        message:
            "Customer login is strictly required. Please login first to fill and save your delivery address.",
        onLoginSuccess: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddNewAddressScreen(
                storeDomain: widget.storeDomain,
                onAddressSaved: () {
                  AddressController.instance
                      .fetchAddresses(domain: widget.storeDomain);
                },
              ),
            ),
          );
        },
      );
      if (loggedIn != true) return;
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AddNewAddressScreen(
            storeDomain: widget.storeDomain,
            onAddressSaved: () {
              AddressController.instance
                  .fetchAddresses(domain: widget.storeDomain);
            },
          ),
        ),
      );
    }
  }

  void _openEditAddress(EcommerceAddressModel address) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddNewAddressScreen(
          addressToEdit: address,
          storeDomain: widget.storeDomain,
          onAddressSaved: () {
            AddressController.instance
                .fetchAddresses(domain: widget.storeDomain);
          },
        ),
      ),
    );
  }

  void _confirmDeleteAddress(EcommerceAddressModel address) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final dialogBg = isDark ? const Color(0xFF1E1E28) : Colors.white;
        final cardSurface =
            isDark ? const Color(0xFF282836) : const Color(0xFFF7F7F9);
        final borderColor = isDark ? Colors.white12 : Colors.grey.shade200;
        bool isDeleting = false;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: dialogBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 8,
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Warning Trash Icon
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: errorColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.delete_forever_rounded,
                        color: errorColor,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    const Text(
                      "Delete Delivery Address",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Are you sure you want to delete this address? Once deleted, it cannot be recovered.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: isDark ? Colors.white70 : blackColor60,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address preview card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  address.addressType.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                address.phone,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark ? Colors.white60 : blackColor60,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            address.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            address.formattedAddress,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : blackColor80,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),

                    // BADA DELETE BUTTON (Large, full width, prominent)
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isDeleting
                            ? null
                            : () async {
                                if (address.id == null) {
                                  Navigator.pop(dialogContext);
                                  return;
                                }

                                setDialogState(() {
                                  isDeleting = true;
                                });

                                final response = await AddressController
                                    .instance
                                    .deleteAddress(address.id!);

                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }

                                final isSuccess = response['status'] == true;
                                final message = (response['message']
                                            is String &&
                                        (response['message'] as String)
                                            .isNotEmpty)
                                    ? response['message'] as String
                                    : (isSuccess
                                        ? "Delivery address deleted successfully."
                                        : "Failed to delete delivery address.");

                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(
                                            isSuccess
                                                ? Icons.check_circle_rounded
                                                : Icons.error_outline_rounded,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              message,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      backgroundColor: isSuccess
                                          ? const Color(0xFF2E7D32)
                                          : errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              },
                        child: isDeleting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.delete_forever_rounded,
                                      size: 22, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    "Delete Address",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: isDeleting
                            ? null
                            : () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : greyColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? darkGreyColor : Colors.white;
    final bodyBg = isDark ? const Color(0xFF121218) : const Color(0xFFF6F6F9);

    return AnimatedBuilder(
      animation: AddressController.instance,
      builder: (context, _) {
        final controller = AddressController.instance;
        final isLoading = controller.isLoading;
        final isLoggedIn = controller.isLoggedIn;
        final customer = controller.customer;
        final addresses = controller.addresses;
        final selectedAddress = controller.selectedAddress;

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
            title: const Text(
              "Delivery Addresses",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh_rounded),
                onPressed: () =>
                    controller.fetchAddresses(domain: widget.storeDomain),
                tooltip: "Refresh Addresses",
              ),
            ],
          ),
          body: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: primaryColor),
                )
              : !isLoggedIn && addresses.isEmpty
                  ? _buildLoginRequiredView(cardBg, isDark)
                  : RefreshIndicator(
                      color: primaryColor,
                      onRefresh: () =>
                          controller.fetchAddresses(domain: widget.storeDomain),
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(
                          parent: BouncingScrollPhysics(),
                        ),
                        padding: const EdgeInsets.all(defaultPadding),
                        children: [
                          // 1. Customer Info Banner
                          if (customer != null)
                            _buildCustomerBanner(customer, cardBg, isDark),

                          const SizedBox(height: 16),

                          // 2. Section Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Saved Addresses (${addresses.length})",
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _openAddNewAddress,
                                icon: const Icon(Icons.add_rounded,
                                    size: 16, color: primaryColor),
                                label: const Text(
                                  "Add New",
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // 3. Addresses List or Empty State
                          if (addresses.isEmpty)
                            _buildEmptyAddressesView(cardBg, isDark)
                          else
                            ...addresses.map((addr) {
                              final isSelected = selectedAddress?.id != null &&
                                  selectedAddress?.id == addr.id;
                              return _buildAddressCard(
                                address: addr,
                                isSelected: isSelected,
                                cardBg: cardBg,
                                isDark: isDark,
                              );
                            }),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: primaryColor,
            elevation: 4,
            shape: const CircleBorder(),
            tooltip: "Add New Address",
            onPressed: _openAddNewAddress,
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding * 0.75,
            ),
            decoration: BoxDecoration(
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: widget.selectAndReturn &&
                      AddressController.instance.addresses.isNotEmpty
                  ? SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final addressCtrl = AddressController.instance;
                          if (addressCtrl.selectedAddress == null &&
                              addressCtrl.addresses.isNotEmpty) {
                            addressCtrl.selectAddress(
                              addressCtrl.addresses.firstWhere(
                                (a) => a.isDefault,
                                orElse: () => addressCtrl.addresses.first,
                              ),
                            );
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentMethodScreen(
                                storeDomain: widget.storeDomain,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(
                          Icons.payment_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          "PROCEED TO PAYMENT",
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _openAddNewAddress,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(defaultBorderRadious),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.add_location_alt_rounded,
                            color: Colors.white, size: 20),
                        label: const Text(
                          "Add New Delivery Address",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomerBanner(
      CustomerProfileModel customer, Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: primaryColor.withValues(alpha: 0.12),
            child: Text(
              customer.name.isNotEmpty ? customer.name[0].toUpperCase() : "U",
              style: const TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: successColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 11, color: successColor),
                          SizedBox(width: 2),
                          Text(
                            "Logged In",
                            style: TextStyle(
                              color: successColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  "${customer.phone} • ${customer.email}",
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white70 : blackColor60,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard({
    required EcommerceAddressModel address,
    required bool isSelected,
    required Color cardBg,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        border: Border.all(
          color: isSelected
              ? primaryColor
              : (isDark ? Colors.white12 : Colors.grey.shade200),
          width: isSelected ? 1.8 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          AddressController.instance.selectAddress(address);
        },
        borderRadius: BorderRadius.circular(defaultBorderRadious),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          address.addressType.toLowerCase() == 'work' ||
                                  address.addressType.toLowerCase() == 'office'
                              ? Icons.work_rounded
                              : Icons.home_rounded,
                          size: 12,
                          color: primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          address.addressType.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (address.isDefault) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded,
                              size: 10, color: Colors.green),
                          SizedBox(width: 3),
                          Text(
                            "DEFAULT",
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // if (isSelected) ...[
                  //   const SizedBox(width: 6),
                  //   Container(
                  //     padding: const EdgeInsets.symmetric(
                  //         horizontal: 6, vertical: 2.5),
                  //     decoration: BoxDecoration(
                  //       color: primaryColor.withValues(alpha: 0.12),
                  //       borderRadius: BorderRadius.circular(6),
                  //       border: Border.all(
                  //           color: primaryColor.withValues(alpha: 0.3)),
                  //     ),
                  //     child: const Text(
                  //       "SELECTED",
                  //       style: TextStyle(
                  //         fontSize: 9.5,
                  //         fontWeight: FontWeight.bold,
                  //         color: primaryColor,
                  //         letterSpacing: 0.4,
                  //       ),
                  //     ),
                  //   ),
                  // ],

                  // // Edit Icon Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openEditAddress(address),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 16,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Delete Icon Button
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _confirmDeleteAddress(address),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: errorColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: errorColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Active Selection Radio Icon
                  Icon(
                    isSelected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
                    color: isSelected ? primaryColor : greyColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                address.name,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                address.formattedAddress,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : blackColor60,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Phone: ${address.phone}",
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : blackColor80,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        AddressController.instance.selectAddress(address);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Selected: ${address.name} (${address.addressType.toUpperCase()})",
                            ),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        if (widget.selectAndReturn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PaymentMethodScreen(
                                storeDomain: widget.storeDomain,
                                addressId: address.id,
                              ),
                            ),
                          );
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(
                          color:
                              isSelected ? primaryColor : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isSelected ? "Selected for Delivery" : "Deliver Here",
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? primaryColor
                              : (isDark ? Colors.white70 : blackColor80),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyAddressesView(Color cardBg, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(defaultBorderRadious),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_rounded,
              color: primaryColor,
              size: 36,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "No Delivery Addresses Saved",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Please add a delivery address so that orders can be delivered to your doorstep.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white60 : blackColor60,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _openAddNewAddress,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
            label: const Text(
              "Add Address Now",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginRequiredView(Color cardBg, bool isDark) {
    final message = AddressController.instance.loginRequiredMessage;

    return Padding(
      padding: const EdgeInsets.all(defaultPadding),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: errorColor,
                  size: 34,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Customer Login Required",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                message.isNotEmpty
                    ? message
                    : "Customer login is strictly required. Please pass a valid Bearer Token in Authorization header (Authorization: Bearer <token>).",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: isDark ? Colors.white70 : blackColor60,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    AddressController.showLoginRequiredModal(
                      context,
                      title: "Login Required",
                      message: message,
                      onLoginSuccess: () {
                        AddressController.instance.fetchAddresses();
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(defaultBorderRadious),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.login_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    "Login to Continue",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
