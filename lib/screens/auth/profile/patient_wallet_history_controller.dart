import 'package:get/get.dart';
import '/api/auth_apis.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../utils/app_common.dart';
import '../model/patient_wallet_history_res.dart';

class PatientWalletHistoryController extends GetxController {
  RxBool isLoading = false.obs;
  Rx<Future<RxList<WalletHistoryElement>>> walletHistoryFuture =
      Future(() => RxList<WalletHistoryElement>()).obs;
  RxList<WalletHistoryElement> historyData = RxList();
  RxBool isPatientLastPage = false.obs;
  RxInt historyPage = 1.obs;

  @override
  void onInit() {
    // Only fetch wallet history if user is logged in
    if (isLoggedIn.value) {
      getWalletHistory();
    }
    super.onInit();
  }

  Future<void> getWalletHistory({bool showloader = true}) async {
    // Skip API call if user is not logged in
    if (!isLoggedIn.value) {
      historyData.clear();
      isLoading(false);
      return;
    }

    if (showloader) {
      isLoading(true);
    }
    await walletHistoryFuture(AuthServiceApis.getWalletHistory(
      historyData: historyData,
      page: historyPage.value,
      lastPageCallBack: (p0) {
        isPatientLastPage(p0);
      },
    )).then((value) {}).catchError((e) {
      toast("Error: $e");
      log("getWalletHistory err: $e");
    }).whenComplete(() => isLoading(false));
  }
}
