import 'package:get/get.dart';
import '../models/deal_model.dart';
import '../services/deals_service.dart';

class DealsController extends GetxController implements GetxService {
  final DealsService _apiService = DealsService();

  final RxList<FlashDealModel> flashDeals = <FlashDealModel>[].obs;
  final RxList<FlashDealModel> featuredDeals = <FlashDealModel>[].obs;
  final Rx<DealOfTheDayModel?> dealOfTheDay = Rx<DealOfTheDayModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllDeals();
  }

  Future<void> fetchAllDeals() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await Future.wait([
        _apiService.getFlashDeals(),
        _apiService.getDealOfTheDay(),
        _apiService.getFeaturedDeals(),
      ]);

      final flashList = results[0] as List<FlashDealModel>;
      final dayList = results[1] as List<DealOfTheDayModel>;
      final featList = results[2] as List<FlashDealModel>;

      flashDeals.assignAll(flashList);
      featuredDeals.assignAll(featList);
      if (dayList.isNotEmpty) {
        dealOfTheDay.value = dayList.first;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
