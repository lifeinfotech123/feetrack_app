import 'package:get/get.dart';

import '../../../data/models/category_model/category_model.dart';
import '../../services/category_service.dart';

class CategoriesController extends GetxController implements GetxService {
  final CategoryService _categoryService = CategoryService();

  // All categories list
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt selectedIndex = 0.obs;

  // Selected category detail & subcategories
  final Rxn<CategoryModel> selectedCategoryDetails = Rxn<CategoryModel>();
  final RxBool isSubCategoryLoading = false.obs;
  final RxString subCategoryError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  void selectCategory(int index) {
    selectedIndex.value = index;
    if (index >= 0 && index < categories.length) {
      final category = categories[index];
      if (category.slug != null && category.slug!.isNotEmpty) {
        fetchCategoryDetails(category.slug!);
      } else {
        selectedCategoryDetails.value = category;
      }
    }
  }

  Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedCategories = await _categoryService.getCategories();
      if (fetchedCategories.isNotEmpty) {
        categories.assignAll(fetchedCategories as Iterable<CategoryModel>);
        if (categories.first.slug != null &&
            categories.first.slug!.isNotEmpty) {
          fetchCategoryDetails(categories.first.slug!);
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
        selectedCategoryDetails.value = details as CategoryModel?;
      } else {
        subCategoryError.value = "Subcategories not found";
      }
    } catch (e) {
      subCategoryError.value = e.toString();
    } finally {
      isSubCategoryLoading.value = false;
    }
  }
}
