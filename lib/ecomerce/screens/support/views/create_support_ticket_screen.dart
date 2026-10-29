import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../constants.dart';
import '../../../controllers/support_ticket_controller.dart';

class CreateSupportTicketScreen extends StatefulWidget {
  final int? prefilledOrderId;

  const CreateSupportTicketScreen({
    super.key,
    this.prefilledOrderId,
  });

  @override
  State<CreateSupportTicketScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState extends State<CreateSupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  late final SupportTicketController _controller;

  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _orderIdController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedType;
  String _selectedPriority = 'high';

  final List<String> _fallbackTypes = [
    "Order & Delivery Issue",
    "Payment & Billing Problem",
    "Refund & Return Inquiry",
    "Product Quality / Damaged Item",
    "Account & Login Assistance",
    "Complaint & Customer Feedback",
    "Partner / Vendor Inquiry",
    "Technical & Website Issue",
    "General Support Question"
  ];

  final Map<String, String> _fallbackPriorities = {
    "low": "Low - General inquiry",
    "medium": "Medium - Standard support",
    "high": "High - Urgent order/payment issue",
    "urgent": "Urgent - Critical issue requiring immediate help",
  };

  @override
  void initState() {
    super.initState();
    _controller = SupportTicketController.instance;

    if (widget.prefilledOrderId != null) {
      _orderIdController.text = widget.prefilledOrderId.toString();
      _selectedType = "Order & Delivery Issue";
    }

    _controller.fetchMetadata().then((_) {
      if (mounted) {
        final types = _controller.metadata.value?.types ?? _fallbackTypes;
        if (types.isNotEmpty && _selectedType == null) {
          setState(() {
            _selectedType = types.first;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _orderIdController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFD32F2F);
      case 'high':
        return const Color(0xFFFF5722);
      case 'medium':
        return const Color(0xFFFFA000);
      case 'low':
      default:
        return const Color(0xFF1976D2);
    }
  }

  Future<void> _submitTicket() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null || _selectedType!.isEmpty) {
      Get.snackbar(
        "Required",
        "Please select an issue type",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    final int? orderId = _orderIdController.text.trim().isNotEmpty
        ? int.tryParse(_orderIdController.text.trim())
        : null;

    final success = await _controller.createTicket(
      subject: _subjectController.text.trim(),
      type: _selectedType!,
      priority: _selectedPriority,
      description: _descriptionController.text.trim(),
      orderId: orderId,
    );

    if (success && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF101015) : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF1C1C24) : Colors.white;
    final inputFill =
        isDark ? const Color(0xFF22222E) : const Color(0xFFF3F4F8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text(
          "Create Support Ticket",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: primaryColor.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.headset_mic_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Customer Support Help Desk",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: primaryColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Submit your inquiry below and our support team will get back to you shortly.",
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Form Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color:
                          Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Issue Type Dropdown
                    _buildFieldLabel("Issue Type *", isDark),
                    const SizedBox(height: 6),
                    Obx(() {
                      final types =
                          _controller.metadata.value?.types ?? _fallbackTypes;
                      if (!types.contains(_selectedType) && types.isNotEmpty) {
                        _selectedType = types.first;
                      }

                      return DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        isExpanded: true,
                        decoration: _buildInputDecoration(
                          hint: "Select Issue Type",
                          prefixIcon: Icons.category_rounded,
                          fillColor: inputFill,
                          isDark: isDark,
                        ),
                        dropdownColor: cardBg,
                        items: types.map((t) {
                          return DropdownMenuItem<String>(
                            value: t,
                            child: Text(
                              t,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedType = val;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 16),

                    // 2. Priority Selector
                    _buildFieldLabel("Priority *", isDark),
                    const SizedBox(height: 6),
                    Obx(() {
                      final priorities =
                          _controller.metadata.value?.priorities ??
                              _fallbackPriorities;

                      return DropdownButtonFormField<String>(
                        initialValue: priorities.containsKey(_selectedPriority)
                            ? _selectedPriority
                            : priorities.keys.first,
                        isExpanded: true,
                        decoration: _buildInputDecoration(
                          hint: "Select Priority",
                          prefixIcon: Icons.flag_rounded,
                          fillColor: inputFill,
                          isDark: isDark,
                        ),
                        dropdownColor: cardBg,
                        items: priorities.entries.map((entry) {
                          final color = _getPriorityColor(entry.key);
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          isDark ? Colors.white : Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedPriority = val;
                            });
                          }
                        },
                      );
                    }),
                    const SizedBox(height: 16),

                    // 3. Order ID (Optional)
                    _buildFieldLabel("Order ID (Optional)", isDark),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _orderIdController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _buildInputDecoration(
                        hint: "e.g. 100007",
                        prefixIcon: Icons.receipt_long_rounded,
                        fillColor: inputFill,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 4. Subject
                    _buildFieldLabel("Subject *", isDark),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _subjectController,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Please enter a subject";
                        }
                        if (val.trim().length < 5) {
                          return "Subject should be at least 5 characters";
                        }
                        return null;
                      },
                      decoration: _buildInputDecoration(
                        hint: "e.g. Delay in delivery for my weekend dinner order",
                        prefixIcon: Icons.title_rounded,
                        fillColor: inputFill,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 5. Description
                    _buildFieldLabel("Description *", isDark),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 4,
                      maxLines: 8,
                      textCapitalization: TextCapitalization.sentences,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Please explain your issue in detail";
                        }
                        if (val.trim().length < 10) {
                          return "Description should be at least 10 characters";
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText:
                            "Provide all necessary details so our support team can resolve your issue quickly...",
                        hintStyle: TextStyle(
                          color: isDark ? Colors.white38 : Colors.black38,
                          fontSize: 13.5,
                        ),
                        filled: true,
                        fillColor: inputFill,
                        contentPadding: const EdgeInsets.all(14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              Obx(() {
                final isLoading = _controller.isCreatingTicket.value;

                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Submit Ticket",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : Colors.black87,
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    required Color fillColor,
    required bool isDark,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark ? Colors.white38 : Colors.black38,
        fontSize: 13.5,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: isDark ? Colors.white54 : Colors.black54,
      ),
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
