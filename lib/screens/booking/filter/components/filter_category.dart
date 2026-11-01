import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/screens/service/model/service_list_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../components/loader_widget.dart';
import '../../../../../generated/assets.dart';
import '../../../../../main.dart';
import '../../../../../utils/colors.dart';
import '../../../../../utils/common_base.dart';
import '../../../../../utils/empty_error_state_widget.dart';
import '../filter_controller.dart';

class FilterCategoryComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterCategoryComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => SnapHelperWidget(
            future: filterCont.serviceListFuture.value,
            errorBuilder: (error) {
              return AnimatedScrollView(
                padding: const EdgeInsets.all(16),
                children: [
                  NoDataWidget(
                    title: error,
                    retryText: locale.value.reload,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () {
                      filterCont.servicePage(1);
                      filterCont.getServicesList();
                    },
                  ),
                ],
              ).paddingSymmetric(horizontal: 32);
            },
            loadingWidget: const LoaderWidget(),
            onSuccess: (data) {
              if (data.isEmpty) {
                return NoDataWidget(
                  title: locale.value.noCategoryFound,
                  retryText: locale.value.reload,
                  onRetry: () {
                    filterCont.servicePage(1);
                    filterCont.getServicesList();
                  },
                );
              } else {
                return Obx(
                  () => Stack(
                    children: [
                      AnimatedScrollView(
                        children: [
                          AnimatedWrap(
                            children: List.generate(
                                filterCont.serviceList.length, (index) {
                              ServiceElement service =
                                  filterCont.serviceList[index];
                              return InkWell(
                                onTap: () {
                                  // filterCont.selectedServiceData(service);
                                  filterCont.selectedServiceDataFunc(service);
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.all(6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 10),
                                      decoration: boxDecorationDefault(
                                        color: context.cardColor,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            service.name.toString(),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: primaryTextStyle(
                                              size: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: commonLeadingWid(
                                        imgPath: Assets.imagesConfirm,
                                        color: whiteTextColor,
                                        size: 8,
                                      ).circularLightPrimaryBg(
                                          color: appColorPrimary, padding: 6),
                                    ).visible(filterCont
                                            .selectedServiceData.value.id ==
                                        service.id),
                                  ],
                                ),
                              );
                            }),
                          ),
                        ],
                        onNextPage: () async {
                          if (!filterCont.isServiceLoading.value) {
                            filterCont
                                .servicePage(filterCont.servicePage.value + 1);
                            filterCont.getServicesList();
                          }
                        },
                        onSwipeRefresh: () async {
                          filterCont.servicePage(1);
                          return await filterCont.getServicesList(
                              showLoader: false);
                        },
                      ),
                      if (filterCont.isServiceLoading.isTrue)
                        const LoaderWidget()
                    ],
                  ),
                );
              }
            },
          ),
        ).paddingOnly(bottom: 16, left: 16, right: 16).expand(),
      ],
    );
  }
}
