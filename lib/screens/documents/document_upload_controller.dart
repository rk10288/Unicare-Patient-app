import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../api/document_apis.dart';
import '../../main.dart';

class DocumentUploadController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<UserDocumentModel> documents = <UserDocumentModel>[].obs;

  // Uploading state for each document type
  RxBool isUploadingEmiratesId = false.obs;
  RxBool isUploadingPassport = false.obs;
  RxBool isUploadingInsurance = false.obs;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    fetchDocuments();
  }

  /// Fetch all user documents
  Future<void> fetchDocuments() async {
    isLoading.value = true;
    try {
      documents.value = await DocumentApis.getDocuments();
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  /// Get document by type
  UserDocumentModel? getDocumentByType(String type) {
    return documents.firstWhereOrNull((doc) => doc.documentType == type);
  }

  /// Upload document from gallery or camera
  Future<void> uploadFromGallery(String documentType) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      await _uploadFile(File(image.path), documentType);
    }
  }

  /// Upload document from camera
  Future<void> uploadFromCamera(String documentType) async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (image != null) {
      await _uploadFile(File(image.path), documentType);
    }
  }

  /// Upload document from file picker (for PDF)
  Future<void> uploadFromFile(String documentType) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      await _uploadFile(File(result.files.single.path!), documentType);
    }
  }

  /// Internal upload method
  Future<void> _uploadFile(File file, String documentType) async {
    _setUploadingState(documentType, true);

    await DocumentApis.uploadDocument(
      file: file,
      documentType: documentType,
      onSuccess: (doc) {
        // Remove old document of same type if exists
        documents.removeWhere((d) => d.documentType == documentType);
        documents.add(doc);
        toast(
            '${_getDocumentTypeName(documentType)} ${locale.value.uploadedSuccessfully}');
      },
      onError: (error) {
        toast(error);
      },
    );

    _setUploadingState(documentType, false);
  }

  /// Delete a document
  Future<void> deleteDocument(int documentId, String documentType) async {
    bool confirmed = await showConfirmDialog(
      Get.context!,
      locale.value.deleteDocumentConfirm,
      positiveText: locale.value.delete,
      negativeText: locale.value.cancel,
    ).then((value) => value ?? false);

    if (!confirmed) return;

    isLoading.value = true;
    bool success = await DocumentApis.deleteDocument(documentId);
    if (success) {
      documents.removeWhere((doc) => doc.id == documentId);
      toast(
          '${_getDocumentTypeName(documentType)} ${locale.value.deletedSuccessfully}');
    }
    isLoading.value = false;
  }

  /// Set uploading state for document type
  void _setUploadingState(String documentType, bool isUploading) {
    switch (documentType) {
      case 'emirates_id':
        isUploadingEmiratesId.value = isUploading;
        break;
      case 'passport':
        isUploadingPassport.value = isUploading;
        break;
      case 'insurance':
        isUploadingInsurance.value = isUploading;
        break;
    }
  }

  /// Get readable name for document type
  String _getDocumentTypeName(String type) {
    switch (type) {
      case 'emirates_id':
        return locale.value.emiratesId;
      case 'passport':
        return locale.value.passport;
      case 'insurance':
        return locale.value.insuranceDocument;
      default:
        return type;
    }
  }

  /// Show upload options bottom sheet
  void showUploadOptions(BuildContext context, String documentType) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.value.uploadDocuments,
              style: boldTextStyle(size: 18),
            ),
            16.height,
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(locale.value.camera),
              onTap: () {
                Get.back();
                uploadFromCamera(documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(locale.value.gallery),
              onTap: () {
                Get.back();
                uploadFromGallery(documentType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file),
              title: Text(locale.value.chooseFile),
              onTap: () {
                Get.back();
                uploadFromFile(documentType);
              },
            ),
            16.height,
          ],
        ),
      ),
    );
  }
}
