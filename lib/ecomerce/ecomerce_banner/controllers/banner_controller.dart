import 'package:get/get.dart';
import 'package:vlr/ecomerce/models/banner_model.dart';
import 'package:vlr/ecomerce/services/banner_service.dart';

class BannerController extends GetxController implements GetxService {
  final BannerService _bannerService = BannerService();

  // Main Banners list
  final RxList<BannerModel> mainBanners = <BannerModel>[].obs;
  final RxBool isMainLoading = false.obs;
  final RxString mainErrorMessage = ''.obs;

  // Footer Banners list
  final RxList<BannerModel> footerBanners = <BannerModel>[].obs;
  final RxBool isFooterLoading = false.obs;
  final RxString footerErrorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMainBanners();
    fetchFooterBanners();
  }

  Future<void> fetchMainBanners() async {
    try {
      isMainLoading.value = true;
      mainErrorMessage.value = '';
      final fetched = await _bannerService.getBanners(bannerType: 'main-banner');
      if (fetched.isNotEmpty) {
        mainBanners.assignAll(fetched);
      } else {
        mainErrorMessage.value = "No main banners found";
      }
    } catch (e) {
      mainErrorMessage.value = e.toString();
    } finally {
      isMainLoading.value = false;
    }
  }

  Future<void> fetchFooterBanners() async {
    try {
      isFooterLoading.value = true;
      footerErrorMessage.value = '';
      final fetched = await _bannerService.getBanners(bannerType: 'footer-banner');
      if (fetched.isNotEmpty) {
        footerBanners.assignAll(fetched);
      } else {
        footerErrorMessage.value = "No footer banners found";
      }
    } catch (e) {
      footerErrorMessage.value = e.toString();
    } finally {
      isFooterLoading.value = false;
    }
  }
}
