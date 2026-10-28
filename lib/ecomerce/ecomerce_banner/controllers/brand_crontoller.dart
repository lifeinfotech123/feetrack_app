import 'package:get/get.dart';
import '../../models/brand_model.dart';
import '../../services/brand_service.dart';


class BrandCrontoller extends GetxController implements GetxService {
  final BrandService _brandService = BrandService();

  final RxList<BrandModel> brands = <BrandModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Brand Details state
  final Rxn<BrandDetailModel> brandDetail = Rxn<BrandDetailModel>();
  final RxBool isDetailLoading = false.obs;
  final RxString detailError = ''.obs;
  final RxInt selectedCategoryId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  Future<void> fetchBrands() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final fetchedBrands = await _brandService.getBrands();
      if (fetchedBrands.isNotEmpty) {
        brands.assignAll(fetchedBrands);
      } else {
        errorMessage.value = "No brands found";
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBrandDetails(String slug) async {
    try {
      isDetailLoading.value = true;
      detailError.value = '';
      selectedCategoryId.value = 0;
      final details = await _brandService.getBrandDetails(slug);
      if (details != null) {
        brandDetail.value = details;
      } else {
        detailError.value = "Brand details not found";
      }
    } catch (e) {
      detailError.value = e.toString();
    } finally {
      isDetailLoading.value = false;
    }
  }

  void selectCategory(int categoryId) {
    selectedCategoryId.value = categoryId;
  }

  List<BrandProductModel> get filteredProducts {
    final details = brandDetail.value;
    if (details == null) return [];
    if (selectedCategoryId.value == 0) {
      return details.products;
    }
    return details.products
        .where((p) => p.categoryId == selectedCategoryId.value)
        .toList();
  }
}

typedef BrandController = BrandCrontoller;
