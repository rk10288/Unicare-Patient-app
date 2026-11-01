import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/screens/category/model/category_list_model.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../../../components/loader_widget.dart';
import '../../../../../main.dart';
import '../../../../../utils/empty_error_state_widget.dart';
import '../filter_controller.dart';

class FilterServiceComponent extends StatelessWidget {
  final FilterController filterCont = Get.put(FilterController());

  FilterServiceComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => SnapHelperWidget(
            future: filterCont.categoryListFuture.value,
            errorBuilder: (error) {
              return AnimatedScrollView(
                padding: const EdgeInsets.all(16),
                children: [
                  NoDataWidget(
                    title: error,
                    retryText: locale.value.reload,
                    imageWidget: const ErrorStateWidget(),
                    onRetry: () {
                      filterCont.categoryPage(1);
                      filterCont.getCategoryList();
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
                    filterCont.categoryPage(1);
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
                                filterCont.categoryList.length, (index) {
                              CategoryElement service =
                                  filterCont.categoryList[index];
                              return InkWell(
                                onTap: () {
                                  // filterCont.selectedCategoryData(service);
                                  filterCont.selectedCategoryDataFunc(service);
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
                                    if (filterCont
                                            .selectedCategoryData.value.id ==
                                        service.id)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.green,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(Icons.check,
                                              color: Colors.white, size: 14),
                                        ),
                                      ),
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
                            filterCont.getClinicsList();
                          }
                        },
                        onSwipeRefresh: () async {
                          filterCont.clinicPage(1);
                          return await filterCont.getCategoryList(
                              showLoader: false);
                        },
                      ),
                      if (filterCont.isCategoryLoading.isTrue)
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
