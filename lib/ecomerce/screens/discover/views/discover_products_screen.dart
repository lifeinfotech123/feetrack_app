import 'package:flutter/material.dart';

import '../../../models/category_model.dart';
import '../../product/views/category_products_screen.dart';

/// DiscoverProductsScreen now delegates to the comprehensive Flipkart-style CategoryProductsScreen
class DiscoverProductsScreen extends StatelessWidget {
  final String categoryTitle;
  final String? categoryImage;
  final CategoryModel? category;

  const DiscoverProductsScreen({
    super.key,
    required this.categoryTitle,
    this.categoryImage,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return CategoryProductsScreen(
      category: category,
      categoryTitle: categoryTitle,
      categoryImage: categoryImage,
    );
  }
}
