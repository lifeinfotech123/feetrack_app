import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/widgets/animated_widgets.dart';
import 'package:vlr/hospital/features/pharmacy/presentation/screens/pharmacy_medicine_detail_screen.dart';
// import 'package:hospital_management_system/core/constants/colors.dart';
// import 'package:hospital_management_system/core/widgets/animated_widgets.dart';

class MedicineOrderScreen extends StatefulWidget {
  const MedicineOrderScreen({Key? key}) : super(key: key);

  @override
  State<MedicineOrderScreen> createState() => _MedicineOrderScreenState();
}

class _MedicineOrderScreenState extends State<MedicineOrderScreen> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  final Map<String, int> _cartQuantities = {};

  final List<Map<String, dynamic>> _categories = [
    {'id': 'C1', 'name': 'Pain Relief', 'image': 'https://cdn-icons-png.flaticon.com/512/3028/3028570.png'},
    {'id': 'C2', 'name': 'Antibiotics', 'image': 'https://cdn-icons-png.flaticon.com/512/822/822143.png'},
    {'id': 'C3', 'name': 'Supplements', 'image': 'https://cdn-icons-png.flaticon.com/512/2721/2721091.png'},
    {'id': 'C4', 'name': 'Personal Care', 'image': 'https://cdn-icons-png.flaticon.com/512/2965/2965608.png'},
    {'id': 'C5', 'name': 'Baby Care', 'image': 'https://cdn-icons-png.flaticon.com/512/2329/2329865.png'},
    {'id': 'C6', 'name': 'Diabetes', 'image': 'https://cdn-icons-png.flaticon.com/512/2965/2965567.png'},
  ];

  final List<Map<String, dynamic>> _medicines = [
    {
      'id': 'M1',
      'name': 'Amoxicillin 500mg',
      'brand': 'Cipla Healthcare',
      'price': 12,
      'discount': '15% OFF',
      'prescriptionRequired': true,
      'categoryId': 'C2',
      'image': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?q=80&w=200&auto=format&fit=crop',
    },
    {
      'id': 'M2',
      'name': 'Paracetamol 650mg',
      'brand': 'GSK Pharma',
      'price': 5,
      'discount': '10% OFF',
      'prescriptionRequired': false,
      'categoryId': 'C1',
      'image': 'https://images.unsplash.com/photo-1550572017-ed200f5e6383?q=80&w=200&auto=format&fit=crop',
    },
    {
      'id': 'M3',
      'name': 'Vitamin C + Zinc',
      'brand': 'Abbott Nutrition',
      'price': 8,
      'discount': '20% OFF',
      'prescriptionRequired': false,
      'categoryId': 'C3',
      'image': 'https://images.unsplash.com/photo-1616671285442-297390708682?q=80&w=200&auto=format&fit=crop',
    },
    {
      'id': 'M4',
      'name': 'Pantoprazole 40mg',
      'brand': 'Sun Pharma',
      'price': 9,
      'discount': '12% OFF',
      'prescriptionRequired': true,
      'categoryId': 'C1',
      'image': 'https://images.unsplash.com/photo-1471864190281-ad5fe9bb0724?q=80&w=200&auto=format&fit=crop',
    },
    {
      'id': 'M5',
      'name': 'Cetirizine 10mg',
      'brand': 'Dr. Reddy Labs',
      'price': 4,
      'discount': '5% OFF',
      'prescriptionRequired': false,
      'categoryId': 'C1',
      'image': 'https://images.unsplash.com/photo-1576602976047-174e57a47881?q=80&w=200&auto=format&fit=crop',
    },
    {
      'id': 'M6',
      'name': 'Accu-Chek Test Strips',
      'brand': 'Roche',
      'price': 25,
      'discount': '8% OFF',
      'prescriptionRequired': false,
      'categoryId': 'C6',
      'image': 'https://images.unsplash.com/photo-1579152276506-5d5ee2af8b67?q=80&w=200&auto=format&fit=crop',
    },
  ];

  int get _totalAmount {
    int sum = 0;
    _cartQuantities.forEach((id, qty) {
      final med = _medicines.firstWhere((m) => m['id'] == id);
      sum += (med['price'] as int) * qty;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final filteredMedicines = _medicines.where((med) {
      return med['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          med['brand'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: pharmacyTeal,
        elevation: 0,
        title: const Text('Pharmacy & Medicine Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: colorWhite)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: colorWhite, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header & Prescription Upload banner
          Container(
            padding: const EdgeInsets.all(16),
            color: pharmacyTeal,
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search medicines, wellness supplements...',
                    hintStyle: const TextStyle(fontSize: 13, color: textMuted),
                    prefixIcon: const Icon(Icons.search, color: pharmacyTeal),
                    filled: true,
                    fillColor: colorWhite,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: pharmacyTeal, content: Text('Prescription uploaded! Pharmacist will verify & add items.'), behavior: SnackBarBehavior.floating),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white30),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.upload_file, color: colorWhite, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text('Have a prescription? Upload Rx & We Deliver', style: TextStyle(color: colorWhite, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        Icon(Icons.arrow_forward_ios, color: colorWhite, size: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category / Medicine View
          Expanded(
            child: CustomScrollView(
              slivers: [
                if (_searchQuery.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Shop by Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark)),
                          SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                
                if (_searchQuery.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.85,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final cat = _categories[index];
                          final isSelected = _selectedCategoryId == cat['id'];
                          return FadeSlideTransitionWidget(
                            index: index,
                            child: InkWell(
                              onTap: () => setState(() => _selectedCategoryId = cat['id']),
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isSelected ? pharmacyTeal.withOpacity(0.05) : colorWhite,
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: isSelected ? pharmacyTeal : borderGrey, width: isSelected ? 2 : 1),
                                      ),
                                      padding: const EdgeInsets.all(10),
                                      child: Image.network(cat['image'], fit: BoxFit.contain),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    cat['name'], 
                                    textAlign: TextAlign.center, 
                                    style: TextStyle(
                                      fontSize: 9, 
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, 
                                      color: isSelected ? pharmacyTeal : textDark
                                    )
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: _categories.length,
                      ),
                    ),
                  ),

                if (_searchQuery.isNotEmpty || _selectedCategoryId != null)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            _searchQuery.isNotEmpty 
                                ? 'Search Results' 
                                : '${_categories.firstWhere((c) => c['id'] == _selectedCategoryId)['name']} Products',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () => setState(() {
                              _selectedCategoryId = null;
                              _searchQuery = '';
                            }),
                            child: const Text('Clear', style: TextStyle(fontSize: 12, color: pharmacyTeal)),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_searchQuery.isNotEmpty || _selectedCategoryId != null)
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.72,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final med = _searchQuery.isNotEmpty 
                              ? filteredMedicines[index]
                              : filteredMedicines.where((m) => m['categoryId'] == _selectedCategoryId).toList()[index];
                          
                          final qty = _cartQuantities[med['id']] ?? 0;

                          return FadeSlideTransitionWidget(
                            index: index,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const PharmacyMedicineDetailScreen(medicineId: 22),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorWhite,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: borderGrey),
                                ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Image & Discount
                                  Expanded(
                                    child: Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                                          child: Image.network(med['image'], width: double.infinity, fit: BoxFit.cover),
                                        ),
                                        Positioned(
                                          top: 8, left: 8,
                                          child: StatusBadgeWidget(label: med['discount'], textColor: colorWhite, bgColor: wellnessGreen),
                                        ),
                                        if (med['prescriptionRequired'])
                                          const Positioned(
                                            top: 8, right: 8,
                                            child: CircleAvatar(backgroundColor: Colors.amber, radius: 10, child: Icon(Icons.receipt_long, size: 12, color: colorWhite)),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(med['name'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                                        Text(med['brand'], style: const TextStyle(color: textMuted, fontSize: 11)),
                                        const SizedBox(height: 8),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('\$${med['price']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark)),
                                            qty == 0
                                                ? InkWell(
                                                    onTap: () => setState(() => _cartQuantities[med['id']] = 1),
                                                    child: Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                      decoration: BoxDecoration(color: pharmacyTeal, borderRadius: BorderRadius.circular(8)),
                                                      child: const Text('ADD', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold, fontSize: 10)),
                                                    ),
                                                  )
                                                : Container(
                                                    decoration: BoxDecoration(color: pharmacyTealBg, borderRadius: BorderRadius.circular(8)),
                                                    child: Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () => setState(() {
                                                            if (qty <= 1) _cartQuantities.remove(med['id']);
                                                            else _cartQuantities[med['id']] = qty - 1;
                                                          }),
                                                          child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.remove, size: 14, color: pharmacyTeal)),
                                                        ),
                                                        Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: pharmacyTeal)),
                                                        InkWell(
                                                          onTap: () => setState(() => _cartQuantities[med['id']] = qty + 1),
                                                          child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.add, size: 14, color: pharmacyTeal)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                        },
                        childCount: _searchQuery.isNotEmpty 
                            ? filteredMedicines.length 
                            : filteredMedicines.where((m) => m['categoryId'] == _selectedCategoryId).length,
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // Bottom Checkout Bar
          if (_cartQuantities.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorWhite,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Home Delivery ETA: 2-4 hrs', style: TextStyle(fontSize: 11, color: wellnessGreen, fontWeight: FontWeight.bold)),
                        Text('\$$_totalAmount Total', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pharmacyTeal,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: pharmacyTeal,
                            content: Text('Order placed successfully! Delivery agent assigned.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        setState(() => _cartQuantities.clear());
                      },
                      icon: const Icon(Icons.check_circle_outline, color: colorWhite),
                      label: const Text('Place Order', style: TextStyle(color: colorWhite, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
