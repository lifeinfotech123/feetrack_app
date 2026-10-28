import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/colors.dart';
import '../../../lab_reports/controller/lab_controller.dart';
import '../../../lab_reports/data/model/lab_model.dart';
import 'lab_tests_screen.dart';

class DiagnosticLabsScreen extends StatefulWidget {
  final String? userId;

  const DiagnosticLabsScreen({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<DiagnosticLabsScreen> createState() => _DiagnosticLabsScreenState();
}

class _DiagnosticLabsScreenState extends State<DiagnosticLabsScreen> {
  late final LabController controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LabController>()
        ? Get.find<LabController>()
        : Get.put(LabController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchLabListing();
      controller.fetchCategories();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DiagnosticLabModel> _getFilteredLabs(List<DiagnosticLabModel> allLabs) {
    return allLabs.where((lab) {
      final matchesSearch = _searchQuery.isEmpty ||
          lab.labName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (lab.category?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (lab.city?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (lab.location?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
              false) ||
          (lab.labClassification
                  ?.toLowerCase()
                  .contains(_searchQuery.toLowerCase()) ??
              false);

      final matchesCategory = _selectedCategory == 'All' ||
          (lab.category?.toLowerCase() == _selectedCategory.toLowerCase());

      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> _extractCategories(List<DiagnosticLabModel> labs) {
    final set = <String>{'All'};
    for (var l in labs) {
      if (l.category != null && l.category!.trim().isNotEmpty) {
        set.add(l.category!.trim());
      }
    }
    return set.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Diagnostic Labs',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: colorWhite,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: colorWhite),
            onPressed: () => controller.fetchLabListing(),
          ),
        ],
      ),
      body: Obx(() {
        final allLabs = controller.diagnosticLabs;
        final isLoading = controller.isLoading.value && allLabs.isEmpty;
        final filteredLabs = _getFilteredLabs(allLabs);
        final categories = _extractCategories(allLabs);

        return RefreshIndicator(
          color: diagnosticViolet,
          onRefresh: () async {
            await controller.fetchLabListing();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Top Search Bar Section
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() => _searchQuery = val.trim());
                      },
                      decoration: InputDecoration(
                        hintText: 'Search labs (Usha Lab, Akash, Lucknow)...',
                        hintStyle: TextStyle(
                            color: Colors.grey.shade400, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: diagnosticViolet),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: textMuted),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 14),
                      ),
                    ),
                  ),
                ),
              ),

              // Overview Banner
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: diagnosticViolet.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.biotech_rounded,
                            color: diagnosticViolet, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Pathology Labs (${filteredLabs.length})',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textDark,
                              ),
                            ),
                            const Text(
                              'Choose your preferred center for sample collection',
                              style: TextStyle(fontSize: 11, color: textMuted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Category Filter Chips
              if (categories.length > 1)
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final cat = categories[i];
                        final isSel = _selectedCategory.toLowerCase() ==
                            cat.toLowerCase();
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSel,
                          onSelected: (val) {
                            if (val) setState(() => _selectedCategory = cat);
                          },
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isSel ? FontWeight.bold : FontWeight.w500,
                            color: isSel ? colorWhite : textDark,
                          ),
                          selectedColor: diagnosticViolet,
                          backgroundColor: colorWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSel ? diagnosticViolet : borderGrey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              // Loading State
              if (isLoading)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: CircularProgressIndicator(color: diagnosticViolet),
                  ),
                )
              // Empty State
              else if (filteredLabs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.science_outlined,
                              size: 54, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'No Diagnostic Labs Found',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textDark),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Try clearing search keywords or filter to see participating labs.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: textMuted),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _selectedCategory = 'All';
                              });
                              controller.fetchLabListing();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: diagnosticViolet,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.refresh,
                                color: colorWhite, size: 18),
                            label: const Text('Reset & Reload',
                                style: TextStyle(color: colorWhite)),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // Labs List
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final lab = filteredLabs[index];
                        return _buildLabCard(context, lab);
                      },
                      childCount: filteredLabs.length,
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabCard(BuildContext context, DiagnosticLabModel lab) {
    final hospName = lab.hospital?.name ?? 'Partner Hospital';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderGrey),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => LabTestsScreen(lab: lab),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon / Avatar
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            diagnosticViolet.withValues(alpha: 0.15),
                            primaryColor.withValues(alpha: 0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: diagnosticViolet.withValues(alpha: 0.3)),
                      ),
                      child: const Center(
                        child: Icon(Icons.biotech_rounded,
                            color: diagnosticViolet, size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lab.labName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.local_hospital_outlined,
                                  size: 13, color: primaryColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '$hospName • ${lab.labClassification ?? "In-House"}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Rating Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Colors.amber, size: 15),
                          const SizedBox(width: 2),
                          Text(
                            '${lab.rating}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: textDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags Row: Category, Code, NABL
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (lab.category != null && lab.category!.isNotEmpty)
                      _buildChip(
                        icon: Icons.category_outlined,
                        label: lab.category!,
                        color: diagnosticViolet,
                      ),
                    if (lab.labCode != null && lab.labCode!.isNotEmpty)
                      _buildChip(
                        icon: Icons.tag_rounded,
                        label: lab.labCode!,
                        color: primaryColor,
                      ),
                    if (lab.timing != null && lab.timing!.isNotEmpty)
                      _buildChip(
                        icon: Icons.schedule_rounded,
                        label: lab.timing!,
                        color: const Color(0xFF2E7D32),
                      ),
                    if (lab.homeCollectionAvailable)
                      _buildChip(
                        icon: Icons.home_rounded,
                        label: 'Home Sample Pickup',
                        color: Colors.orange.shade800,
                      ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: lightGrey),
                const SizedBox(height: 10),

                // Address & Incharge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 15, color: textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        lab.location ??
                            lab.address ??
                            'Hospital Diagnostic Premises',
                        style: const TextStyle(fontSize: 11.5, color: textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (lab.inchargeName != null &&
                    lab.inchargeName!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.person_pin_circle_outlined,
                          size: 15, color: textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Incharge: ${lab.inchargeName}',
                        style: const TextStyle(fontSize: 11, color: textMuted),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 14),

                // Bottom Action Button
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LabTestsScreen(lab: lab),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'View Lab Tests & Book',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: colorWhite,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16, color: colorWhite),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
