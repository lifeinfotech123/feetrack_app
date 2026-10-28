import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

enum HomeServiceType {
  gym,
  room,
}

class DashBoardController extends GetxController implements GetxService {
  static const List<HomeServiceType> homeServices = HomeServiceType.values;

  int _dashPage = 0;
  HomeServiceType _homeServiceType = HomeServiceType.gym;

  int get dashPage => _dashPage;
  HomeServiceType get homeServiceType => _homeServiceType;
  int get homeServiceIndex => homeServices.indexOf(_homeServiceType);

  set dashPage(int page) {
    _dashPage = page;
    update();
  }

  void selectHomeService(HomeServiceType serviceType) {
    if (_homeServiceType == serviceType) {
      return;
    }

    _homeServiceType = serviceType;
    update(["home_switch", "home_content"]);
  }

  void selectHomeServiceByIndex(int index) {
    if (index < 0 || index >= homeServices.length) {
      return;
    }

    selectHomeService(homeServices[index]);
  }
}
