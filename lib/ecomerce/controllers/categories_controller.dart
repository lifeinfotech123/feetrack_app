import 'package:get/get.dart';
import '../models/category_model.dart';
import '../models/home_screen_models.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

class CategoriesController extends GetxController implements GetxService {
  final CategoryService _categoryService = CategoryService();
  final ProductService _productService = ProductService();

  // All categories list from API
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  // Deduplicated categories by slug/name for clean presentation
  final RxList<CategoryModel> uniqueCategories = <CategoryModel>[].obs;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedIndex = 0.obs;

  // Category type filter: 'all', 'ecommerce', 'food'
  final RxString selectedCategoryType = 'all'.obs;

  // Selected category detail & subcategories
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final Rxn<CategoryModel> selectedCategoryDetails = Rxn<CategoryModel>();
  final RxBool isSubCategoryLoading = false.obs;
  final RxString subCategoryError = ''.obs;

  // Products belonging to the selected category (Flipkart PLP)
  final RxList<ApiProductModel> categoryProducts = <ApiProductModel>[].obs;
  final RxBool isProductsLoading = false.obs;
  final RxString productsErrorMessage = ''.obs;
  final RxString currentSort = 'popular'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  /// List of categories filtered by current type ('all', 'ecommerce', 'food')
  List<CategoryModel> get displayCategories {
    final baseList = uniqueCategories.isNotEmpty ? uniqueCategories : categories;
    if (selectedCategoryType.value == 'all') {
      return baseList;
    }
    return baseList.where((cat) {
      if (selectedCategoryType.value == 'ecommerce') {
        return cat.isEcommerce;
      } else if (selectedCategoryType.value == 'food') {
        return cat.isFood;
      }
      return true;
    }).toList();
  }

  /// List of non-food categories strictly for eCommerce home screen
  List<CategoryModel> get homeCategories {
    final baseList = uniqueCategories.isNotEmpty ? uniqueCategories : categories;
    return baseList.where((cat) => !cat.isFood).toList();
  }

  void setCategoryType(String type) {
    selectedCategoryType.value = type;
    final list = displayCategories;
    if (list.isNotEmpty) {
      selectCategoryModel(list.first);
    }
  }

  void selectCategory(int index) {
    final list = displayCategories;
    if (index >= 0 && index < list.length) {
      selectedIndex.value = index;
      selectCategoryModel(list[index]);
    }
  }

  void selectCategoryModel(CategoryModel category) {
    selectedCategory.value = category;
    selectedCategoryDetails.value = category;

    // Fetch details/subcategories if available
    if (category.slug != null && category.slug!.isNotEmpty) {
      fetchCategoryDetails(category.slug!);
    }

    // Fetch live products for this category (Flipkart style)
    fetchCategoryProducts(category);
  }

  Future<void> fetchCategories({String? store, String? domain}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final fetchedCategories =
          await _categoryService.getCategories(store: store, domain: domain);
      if (fetchedCategories.isNotEmpty) {
        categories.assignAll(fetchedCategories);

        // Deduplicate for display
        final seen = <String>{};
        final unique = <CategoryModel>[];
        for (final cat in fetchedCategories) {
          final key = (cat.slug ?? cat.name).toLowerCase().trim();
          if (!seen.contains(key)) {
            seen.add(key);
            unique.add(cat);
          }
        }
        uniqueCategories.assignAll(unique);

        if (displayCategories.isNotEmpty) {
          selectCategory(0);
        }
      } else {
        errorMessage.value = "No categories found";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCategoryDetails(String slug) async {
    try {
      isSubCategoryLoading.value = true;
      subCategoryError.value = '';
      final details = await _categoryService.getCategoryDetails(slug);
      if (details != null) {
        selectedCategoryDetails.value = details;
      }
    } catch (e) {
      subCategoryError.value = e.toString();
    } finally {
      isSubCategoryLoading.value = false;
    }
  }

  /// Fetch live products matching category by slug or id (Flipkart style)
  Future<void> fetchCategoryProducts(
    CategoryModel category, {
    String? sortBy,
    double? minPrice,
    double? maxPrice,
  }) async {
    try {
      isProductsLoading.value = true;
      productsErrorMessage.value = '';
      currentSort.value = sortBy ?? currentSort.value;

      final products = await _productService.getProducts(
        category: category.slug,
        categoryId: category.id,
        domain: category.store?.domain,
        sortBy: sortBy ?? (currentSort.value != 'popular' ? currentSort.value : null),
        minPrice: minPrice,
        maxPrice: maxPrice,
      );

      if (products.isNotEmpty) {
        categoryProducts.assignAll(products);
      } else {
        // Fallback: If products endpoint with category filter returned empty,
        // query all products and filter client-side by category name, slug or id
        final all = await _productService.getProducts(domain: category.store?.domain);
        final filtered = all.where((p) {
          final matchesId = category.id != null && p.category?.id == category.id;
          final matchesSlug = category.slug != null &&
              p.category?.slug?.toLowerCase() == category.slug?.toLowerCase();
          final matchesName = category.name.isNotEmpty &&
              (p.category?.name.toLowerCase() == category.name.toLowerCase() ||
                  p.name.toLowerCase().contains(category.name.toLowerCase()));
          return matchesId || matchesSlug || matchesName;
        }).toList();

        categoryProducts.assignAll(filtered);
      }
    } catch (e) {
      productsErrorMessage.value = e.toString();
      categoryProducts.clear();
    } finally {
      isProductsLoading.value = false;
    }
  }
}
