import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../../api/auth_apis.dart';
import '../../../main.dart';
import '../../../utils/colors.dart';

class AddFundsDialog extends StatefulWidget {
  final VoidCallback? onSuccess;

  const AddFundsDialog({super.key, this.onSuccess});

  @override
  State<AddFundsDialog> createState() => _AddFundsDialogState();
}

class _AddFundsDialogState extends State<AddFundsDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  RxBool isLoading = false.obs;

  String selectedPaymentMethod = 'Cash';
  List<String> paymentMethods = [
    'Cash',
    'Credit Card',
    'Debit Card',
    'Online Transfer',
    'Other'
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _addFunds() async {
    if (_formKey.currentState!.validate()) {
      isLoading(true);

      try {
        final response = await AuthServiceApis.addFundsToWallet(
          amount: double.parse(_amountController.text.trim()),
          paymentMethod: selectedPaymentMethod,
          transactionId: DateTime.now().millisecondsSinceEpoch.toString(),
          notes: _notesController.text.trim(),
        );

        if (response.status == true) {
          toast(response.message, bgColor: completedStatusColor);

          // Refresh wallet balance
          await AuthServiceApis.getUserWallet();

          // Call success callback
          widget.onSuccess?.call();

          // Close dialog
          Get.back();
        } else {
          toast(response.message, bgColor: cancelStatusColor);
        }
      } catch (e) {
        toast(locale.value.somethingWentWrong, bgColor: cancelStatusColor);
        log('Add funds error: $e');
      } finally {
        isLoading(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Funds',
                      style: boldTextStyle(size: 20),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.close),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                16.height,
                Text(
                  'Amount',
                  style: secondaryTextStyle(),
                ),
                8.height,
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                16.height,
                Text(
                  'Payment Method',
                  style: secondaryTextStyle(),
                ),
                8.height,
                DropdownButtonFormField<String>(
                  value: selectedPaymentMethod,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: paymentMethods.map((method) {
                    return DropdownMenuItem(
                      value: method,
                      child: Text(method),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedPaymentMethod = value;
                      });
                    }
                  },
                ),
                16.height,
                Text(
                  'Notes (Optional)',
                  style: secondaryTextStyle(),
                ),
                8.height,
                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter notes',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                24.height,
                Obx(
                  () => ElevatedButton(
                    onPressed: isLoading.value ? null : _addFunds,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: appColorPrimary,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Add Funds',
                            style: boldTextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
