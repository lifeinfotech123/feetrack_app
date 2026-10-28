import 'package:get/get.dart';
import '../models/top_slider_model.dart';
import '../services/top_slider_service.dart';

class TopSliderController extends GetxController implements GetxService {
  final TopSliderService _apiService = TopSliderService();

  final RxList<TopSliderModel> sliders = <TopSliderModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxInt activeIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTopSliders();
  }

  Future<void> fetchTopSliders() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      final list = await _apiService.getTopSliders();
      sliders.assignAll(list);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setActiveIndex(int index) {
    activeIndex.value = index;
  }
}
