import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:nb_utils/nb_utils.dart';
import '../network/network_utils.dart';
import '../utils/api_end_points.dart';

/// Model for user document
class UserDocumentModel {
  final int id;
  final int userId;
  final String documentType;
  final String fileName;
  final String originalName;
  final String mimeType;
  final int fileSize;
  final String url;
  final DateTime createdAt;

  UserDocumentModel({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.fileName,
    required this.originalName,
    required this.mimeType,
    required this.fileSize,
    required this.url,
    required this.createdAt,
  });

  factory UserDocumentModel.fromJson(Map<String, dynamic> json) {
    return UserDocumentModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      documentType: json['document_type'] ?? '',
      fileName: json['file_name'] ?? '',
      originalName: json['original_name'] ?? '',
      mimeType: json['mime_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
      url: json['url'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }
}

/// API service for document operations
class DocumentApis {
  /// Get all documents for the authenticated user
  static Future<List<UserDocumentModel>> getDocuments() async {
    final response = await handleResponse(
      await buildHttpResponse(
        APIEndPoints.documents,
        method: HttpMethodType.GET,
      ),
    );

    if (response['status'] == true && response['data'] != null) {
      return (response['data'] as List)
          .map((doc) => UserDocumentModel.fromJson(doc))
          .toList();
    }
    return [];
  }

  /// Upload a document
  static Future<UserDocumentModel?> uploadDocument({
    required File file,
    required String documentType,
    Function(UserDocumentModel)? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      MultipartRequest multiPartRequest = await getMultiPartRequest(
        APIEndPoints.documentsUpload,
      );

      // Add document type field
      multiPartRequest.fields['document_type'] = documentType;

      // Add file
      multiPartRequest.files
          .add(await MultipartFile.fromPath('file', file.path));

      // Add auth headers
      multiPartRequest.headers.addAll(buildHeaderTokens());

      UserDocumentModel? result;

      await sendMultiPartRequest(
        multiPartRequest,
        onSuccess: (temp) async {
          // Parse the String response to Map (same pattern as core_apis.dart)
          final data = jsonDecode(temp);
          if (data['status'] == true && data['data'] != null) {
            result = UserDocumentModel.fromJson(data['data']);
            onSuccess?.call(result!);
          }
        },
        onError: (error) {
          onError?.call(error.toString());
        },
      );

      return result;
    } catch (e) {
      onError?.call(e.toString());
      return null;
    }
  }

  /// Delete a document
  static Future<bool> deleteDocument(int documentId) async {
    try {
      final response = await handleResponse(
        await buildHttpResponse(
          '${APIEndPoints.documents}/$documentId',
          method: HttpMethodType.DELETE,
        ),
      );
      return response['status'] == true;
    } catch (e) {
      toast(e.toString());
      return false;
    }
  }
}
