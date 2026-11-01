import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../api/auth_apis.dart';
import '../../components/app_scaffold.dart';
import '../../generated/assets.dart';
import '../../main.dart';
import '../../utils/app_common.dart';
import '../../utils/colors.dart';
import '../../utils/common_base.dart';
import '../../utils/constants.dart';
import '../../utils/price_widget.dart';
import '../dashboard/dashboard_controller.dart';
import 'payment_controller.dart';

class PaymentScreen extends StatelessWidget {
  final bool isQuickBook;
  const PaymentScreen({super.key, this.isQuickBook = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffoldNew(
      appBartitleText: locale.value.payment,
      isLoading: paymentController.isLoading,
      appBarVerticalSize: Get.height * 0.12,
      body: RefreshIndicator(
        onRefresh: () async {
          await AuthServiceApis.getUserWallet();
          await getAppConfigurations();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 80),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "* ${locale.value.noteForCashPaymentPurposesDontUseThePayNowBut}",
                  style: secondaryTextStyle(
                      color: appColorSecondary,
                      size: 11,
                      fontStyle: FontStyle.italic),
                ).paddingTop(16).visible(
                    paymentController.isFromBookingDetail &&
                        !paymentController.isAdvancePaymentFailed),
                16.height,
                Text(locale.value.choosePaymentMethod,
                    style: primaryTextStyle(size: 18)),
                8.height,
                Text(locale.value.chooseOurConvenientPaymentOptionAndUnlockUnli,
                    style: secondaryTextStyle()),

                // Coupon Section - Only visible when Wallet payment is selected
                Obx(() => Container(
                      padding: const EdgeInsets.all(16),
                      decoration:
                          boxDecorationDefault(color: context.cardColor),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.local_offer_outlined,
                                  color: appColorPrimary, size: 20),
                              8.width,
                              Text('Have a coupon? (Wallet only)',
                                  style: boldTextStyle(size: 14)),
                            ],
                          ),
                          12.height,
                          Obx(
                            () => paymentController.isCouponApplied.value
                                ? Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: boxDecorationDefault(
                                      color: completedStatusColor.withValues(
                                          alpha: 0.1),
                                      border: Border.all(
                                          color: completedStatusColor),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check_circle,
                                            color: completedStatusColor,
                                            size: 20),
                                        8.width,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Coupon "${paymentController.appliedCouponCode.value}" applied',
                                                style: primaryTextStyle(
                                                    color: completedStatusColor,
                                                    size: 13),
                                              ),
                                              4.height,
                                              Row(
                                                children: [
                                                  Text('You save: ',
                                                      style: secondaryTextStyle(
                                                          size: 12)),
                                                  PriceWidget(
                                                    price: paymentController
                                                        .discountAmount.value,
                                                    color: completedStatusColor,
                                                    size: 13,
                                                    isBoldText: true,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.close,
                                              color: Colors.red.shade400,
                                              size: 20),
                                          onPressed: () =>
                                              paymentController.removeCoupon(),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: paymentController
                                              .couponController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter coupon code',
                                            hintStyle: secondaryTextStyle(),
                                            filled: true,
                                            fillColor:
                                                context.scaffoldBackgroundColor,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 12),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide.none,
                                            ),
                                          ),
                                          textCapitalization:
                                              TextCapitalization.characters,
                                        ),
                                      ),
                                      12.width,
                                      Obx(
                                        () => paymentController
                                                .isCouponLoading.value
                                            ? const SizedBox(
                                                width: 80,
                                                child: Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2)),
                                              )
                                            : AppButton(
                                                text: 'Apply',
                                                color: appColorPrimary,
                                                textStyle: boldTextStyle(
                                                    color: Colors.white,
                                                    size: 13),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 20,
                                                        vertical: 10),
                                                onTap: () => paymentController
                                                    .applyCoupon(),
                                              ),
                                      ),
                                    ],
                                  ),
                          ),

                          // Show price breakdown when coupon applied
                          Obx(
                            () => paymentController.isCouponApplied.value
                                ? Column(
                                    children: [
                                      12.height,
                                      Divider(color: context.dividerColor),
                                      8.height,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Original Amount:',
                                              style: secondaryTextStyle()),
                                          PriceWidget(
                                            price: paymentController
                                                .originalPayAmount,
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                      4.height,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Discount:',
                                              style: secondaryTextStyle(
                                                  color: completedStatusColor)),
                                          Row(
                                            children: [
                                              Text('- ',
                                                  style: primaryTextStyle(
                                                      color:
                                                          completedStatusColor)),
                                              PriceWidget(
                                                price: paymentController
                                                    .discountAmount.value,
                                                color: completedStatusColor,
                                                size: 14,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      8.height,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Final Amount:',
                                              style: boldTextStyle()),
                                          PriceWidget(
                                            price: paymentController.payAmount,
                                            size: 16,
                                            isBoldText: true,
                                            color: appColorPrimary,
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ).visible(paymentController.paymentOption.value ==
                        PaymentMethods.PAYMENT_METHOD_WALLET)),

                24.height,
                cashAfterService(context)
                    .visible(isQuickBook)
                    .paddingOnly(bottom: 8),
                Column(
                  //spacing: 8,
                  children: [
                    if (!paymentController.bookingData.isOnlineService &&
                        !paymentController.isFromBookingDetail &&
                        !paymentController.bookingData.isEnableAdvancePayment)
                      cashAfterService(context).paddingOnly(bottom: 8),
                    walletPayment(context).paddingOnly(bottom: 8),
                    stripePaymentWidget(context).paddingOnly(bottom: 8).visible(
                        appConfigs.value.stripePay.stripePublickey.isNotEmpty &&
                            appConfigs
                                .value.stripePay.stripeSecretkey.isNotEmpty),
                    razorPaymentWidget(context).paddingOnly(bottom: 8).visible(
                        appConfigs.value.razorPay.razorpaySecretkey.isNotEmpty),
                    phonePayPaymentWidget(context).visible(appConfigs
                            .value.phonepe.phonepeAppId.isNotEmpty &&
                        appConfigs.value.phonepe.phonepeMerchantId.isNotEmpty &&
                        appConfigs.value.phonepe.phonepeSaltKey.isNotEmpty &&
                        appConfigs.value.phonepe.phonepeSaltIndex.isNotEmpty),
                    payStackPaymentWidget(context)
                        .visible(appConfigs.value.paystackPay.paystackPublickey
                                .isNotEmpty &&
                            appConfigs
                                .value.paystackPay.paystackSecretkey.isNotEmpty)
                        .paddingOnly(bottom: 8),
                    payPalPaymentWidget(context)
                        .visible(appConfigs
                                .value.paypalPay.paypalClientid.isNotEmpty &&
                            appConfigs
                                .value.paypalPay.paypalSecretkey.isNotEmpty)
                        .paddingOnly(bottom: 8),
                    flutterWavePaymentWidget(context)
                        .visible(appConfigs.value.flutterwavePay
                                .flutterwaveSecretkey.isNotEmpty &&
                            appConfigs.value.flutterwavePay.flutterwavePublickey
                                .isNotEmpty)
                        .paddingOnly(bottom: 8),
                    airtelMoneyPaymentWidget(context)
                        .visible(appConfigs
                                .value.airtelMoney.airtelSecretkey.isNotEmpty &&
                            appConfigs
                                .value.airtelMoney.airtelClientid.isNotEmpty)
                        .paddingOnly(bottom: 8),
                    midtransPay(context)
                        .visible(appConfigs
                            .value.midtransPay.midtransClientKey.isNotEmpty)
                        .paddingOnly(bottom: 8),
                    sadadPay(context)
                        .visible(appConfigs
                                .value.sadadPay.sadadSecretKey.isNotEmpty &&
                            appConfigs.value.sadadPay.sadadId.isNotEmpty &&
                            appConfigs.value.sadadPay.sadadDomain.isNotEmpty)
                        .paddingOnly(bottom: 8),
                    cinetPay(context).visible(appConfigs
                            .value.cinetPay.siteId.isNotEmpty &&
                        appConfigs.value.cinetPay.cinetPayAPIKey.isNotEmpty),
                  ],
                ).visible(!isQuickBook)
              ],
            ).paddingSymmetric(horizontal: 16),
          ),
        ).makeRefreshable,
      ),
      widgetsStackedOverBody: [
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: AppButton(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            color: appColorSecondary,
            onTap: () {
              paymentController.handleBookNowClick(context, isQuickBook);
            },
            textStyle: appButtonFontColorText,
            child: Text(locale.value.proceed,
                style: primaryTextStyle(color: Colors.white)),
          ),
        )
      ],
    );
  }

  Widget stripePaymentWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesStripeLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("Stripe", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_STRIPE,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget razorPaymentWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesRazorpayLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("Razor Pay", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_RAZORPAY,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget phonePayPaymentWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesPhonepeLogo),
                height: 18,
                width: 24,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("PhonePe", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_PHONEPE,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget payStackPaymentWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesPaystackLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("PaysStack", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_PAYSTACK,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget payPalPaymentWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesPaypalLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("PayPal", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_PAYPAL,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget flutterWavePaymentWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesFlutterWaveLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("FlutterWave", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_FLUTTER_WAVE,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget airtelMoneyPaymentWidget(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesAirtelLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("Airtel Money", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_AIRTEL,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget midtransPay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesMidtransLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("Midtrans", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_MIDTRANS,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget sadadPay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: Image(
                color: isDarkMode.value ? white : black,
                image: const AssetImage(Assets.imagesSadadLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("Sadad", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_SADAD,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget cinetPay(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        children: [
          Obx(
            () => RadioListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 2),
              tileColor: context.cardColor,
              controlAffinity: ListTileControlAffinity.trailing,
              shape: RoundedRectangleBorder(borderRadius: radius()),
              secondary: const Image(
                image: AssetImage(Assets.imagesCinetpayLogo),
                height: 16,
                width: 22,
              ),
              fillColor: WidgetStateProperty.all(appColorPrimary),
              title: Text("CinetPay", style: primaryTextStyle()),
              value: PaymentMethods.PAYMENT_METHOD_CINETPAY,
              groupValue: paymentController.paymentOption.value,
              onChanged: (value) {
                paymentController.changePaymentOption(value.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget cashAfterService(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Obx(
        () => RadioListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          tileColor: context.cardColor,
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(borderRadius: radius()),
          secondary: const Image(
            image: AssetImage(Assets.iconsIcCash),
            color: appColorPrimary,
            height: 18,
            width: 24,
          ),
          fillColor: WidgetStateProperty.all(appColorPrimary),
          title: Text("Cash after service", style: primaryTextStyle()),
          value: PaymentMethods.PAYMENT_METHOD_CASH,
          groupValue: paymentController.paymentOption.value,
          onChanged: (value) {
            paymentController.changePaymentOption(value.toString());
          },
        ),
      ),
    );
  }

  Widget walletPayment(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Obx(
        () => RadioListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 2),
          tileColor: context.cardColor,
          controlAffinity: ListTileControlAffinity.trailing,
          shape: RoundedRectangleBorder(borderRadius: radius()),
          secondary: const Image(
            image: AssetImage(Assets.iconsIcUnFillWallet),
            color: appColorPrimary,
            height: 18,
            width: 24,
          ),
          fillColor: WidgetStateProperty.all(appColorPrimary),
          title: Row(
            children: [
              Text("Wallet", style: primaryTextStyle()),
              8.width,
              Text("( ", style: primaryTextStyle(color: completedStatusColor)),
              PriceWidget(
                price: userWalletData.value.walletAmount,
                color: completedStatusColor,
                size: 14,
                isBoldText: true,
              ),
              Text(" )", style: primaryTextStyle(color: completedStatusColor)),
            ],
          ),
          value: PaymentMethods.PAYMENT_METHOD_WALLET,
          groupValue: paymentController.paymentOption.value,
          onChanged: (value) {
            if (userWalletData.value.walletAmount
                    .toStringAsFixed(appCurrency.value.noOfDecimal)
                    .toDouble() >=
                paymentController.payAmount
                    .toStringAsFixed(appCurrency.value.noOfDecimal)
                    .toDouble()) {
              paymentController.paymentOption(value.toString());
            } else {
              toast(locale.value.youDontHaveEnoughBalanceToCompleteThePaymentU);
            }
          },
        ),
      ),
    );
  }
}
