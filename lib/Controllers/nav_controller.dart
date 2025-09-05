import 'package:get/get.dart';

enum PageType { stock, clients, costing, sales, purchases, companyLedger }

class NavController extends GetxController {
  var selectedPage = PageType.stock.obs;
  var isDrawerOpen = true.obs;

  void setPage(PageType page) {
    selectedPage.value = page;
  }

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }
}
