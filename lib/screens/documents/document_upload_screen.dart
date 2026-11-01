import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/document_apis.dart';
import '../../components/app_scaffold.dart';
import '../../main.dart';
import '../../utils/colors.dart';
import '../dashboard/dashboard_screen.dart';
import '../home/home_controller.dart';
import 'document_upload_controller.dart';

class DocumentUploadScreen extends StatelessWidget {
  final bool isFromRegistration;

  DocumentUploadScreen({super.key, this.isFromRegistration = false});

  final DocumentUploadController controller =
      Get.put(DocumentUploadController());

  void _navigateToDashboard() {
    // Initialize HomeController before navigation
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }

    Get.offAll(() => DashboardScreen());
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBartitleText: locale.value.uploadDocuments,
      hideAppBar: isFromRegistration,
      body: RefreshIndicator(
        onRefresh: controller.fetchDocuments,
        child: Obx(
          () => controller.isLoading.value
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    // Custom header for registration flow
                    if (isFromRegistration) ...[
                      SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                locale.value.uploadDocuments,
                                style: boldTextStyle(size: 24),
                              ),
                              8.height,
                              Text(
                                locale.value.documentUploadSubtitle,
                                style: secondaryTextStyle(),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Info card
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: appColorSecondary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline,
                                      color: appColorSecondary),
                                  12.width,
                                  Expanded(
                                    child: Text(
                                      locale.value.documentUploadInfo,
                                      style: secondaryTextStyle(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            24.height,

                            // Emirates ID Section
                            _buildDocumentCard(
                              context: context,
                              title: locale.value.emiratesId,
                              description: locale.value.emiratesIdDescription,
                              documentType: 'emirates_id',
                              document:
                                  controller.getDocumentByType('emirates_id'),
                              isUploading:
                                  controller.isUploadingEmiratesId.value,
                              icon: Icons.credit_card,
                            ),
                            16.height,

                            // Passport Section
                            _buildDocumentCard(
                              context: context,
                              title: locale.value.passport,
                              description: locale.value.passportDescription,
                              documentType: 'passport',
                              document:
                                  controller.getDocumentByType('passport'),
                              isUploading: controller.isUploadingPassport.value,
                              icon: Icons.book,
                            ),
                            16.height,

                            // Insurance Section (Optional)
                            _buildDocumentCard(
                              context: context,
                              title: locale.value.insuranceDocument,
                              description: locale.value.insuranceDescription,
                              documentType: 'insurance',
                              document:
                                  controller.getDocumentByType('insurance'),
                              isUploading:
                                  controller.isUploadingInsurance.value,
                              icon: Icons.health_and_safety,
                              isOptional: true,
                            ),
                            24.height,
                          ],
                        ),
                      ),
                    ),
                    // Continue to Dashboard button for registration flow
                    if (isFromRegistration) ...[
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _navigateToDashboard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appColorPrimary,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  locale.value.continueToDashboard,
                                  style: boldTextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            8.height,
                            TextButton(
                              onPressed: _navigateToDashboard,
                              child: Text(
                                locale.value.skipForNow,
                                style: secondaryTextStyle(
                                    color: appColorSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDocumentCard({
    required BuildContext context,
    required String title,
    required String description,
    required String documentType,
    required UserDocumentModel? document,
    required bool isUploading,
    required IconData icon,
    bool isOptional = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: document != null
              ? Colors.green.withValues(alpha: 0.5)
              : borderColor.withValues(alpha: 0.3),
          width: document != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: appColorSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: appColorSecondary, size: 24),
              ),
              16.width,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(title, style: boldTextStyle()),
                        if (isOptional) ...[
                          8.width,
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              locale.value.optional,
                              style: secondaryTextStyle(size: 10),
                            ),
                          ),
                        ],
                      ],
                    ),
                    4.height,
                    Text(
                      description,
                      style: secondaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ),
              if (document != null) ...[
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ],
          ),
          16.height,

          // Document preview or upload button
          if (document != null)
            _buildUploadedDocument(context, document, documentType)
          else if (isUploading)
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  8.height,
                  Text(locale.value.uploading, style: secondaryTextStyle()),
                ],
              ),
            )
          else
            _buildUploadButton(context, documentType),
        ],
      ),
    );
  }

  Widget _buildUploadedDocument(
      BuildContext context, UserDocumentModel document, String documentType) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            document.mimeType.contains('pdf')
                ? Icons.picture_as_pdf
                : Icons.image,
            color: Colors.green,
          ),
          12.width,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.originalName,
                  style: primaryTextStyle(size: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.height,
                Text(
                  '${(document.fileSize / 1024).toStringAsFixed(1)} KB • ${document.createdAt.toString().split(' ')[0]}',
                  style: secondaryTextStyle(size: 10),
                ),
              ],
            ),
          ),
          // Replace button
          IconButton(
            onPressed: () =>
                controller.showUploadOptions(context, documentType),
            icon: const Icon(Icons.refresh, size: 20),
            tooltip: locale.value.replace,
          ),
          // Delete button
          IconButton(
            onPressed: () =>
                controller.deleteDocument(document.id, documentType),
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
            tooltip: locale.value.delete,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(BuildContext context, String documentType) {
    return InkWell(
      onTap: () => controller.showUploadOptions(context, documentType),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: appColorSecondary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_upload_outlined, color: appColorSecondary),
            12.width,
            Text(
              locale.value.tapToUpload,
              style: primaryTextStyle(color: appColorSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
