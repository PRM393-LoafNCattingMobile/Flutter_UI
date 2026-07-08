import 'package:image_picker/image_picker.dart';
import 'package:loafncatting_mobile/services/api_service.dart';

enum MediaUploadType { avatar, product, cat }

class UploadedImageResult {
  UploadedImageResult({
    required this.s3Key,
    required this.displayUrl,
  });

  final String s3Key;
  final String displayUrl;
}

class ImageUploadException implements Exception {
  ImageUploadException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ImageUploadService {
  ImageUploadService(this.api, {ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  static const int _maxUploadBytes = 1024 * 1024;

  final ApiService api;
  final ImagePicker _picker;

  Future<UploadedImageResult?> pickAndUpload(MediaUploadType type) async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return null;
    }

    return uploadFile(type, file);
  }

  Future<UploadedImageResult> uploadFile(
      MediaUploadType type, XFile file) async {
    final bytes = await file.readAsBytes();
    if (bytes.isEmpty || bytes.lengthInBytes > _maxUploadBytes) {
      throw ImageUploadException('Ảnh phải nhỏ hơn hoặc bằng 1 MB.');
    }

    final contentType = _resolveContentType(file.name);
    final uploadTarget = switch (type) {
      MediaUploadType.avatar => await api.createAvatarUploadUrl(
          fileName: file.name,
          contentType: contentType,
          fileSizeBytes: bytes.lengthInBytes,
        ),
      MediaUploadType.product => await api.createProductUploadUrl(
          fileName: file.name,
          contentType: contentType,
          fileSizeBytes: bytes.lengthInBytes,
        ),
      MediaUploadType.cat => await api.createCatUploadUrl(
          fileName: file.name,
          contentType: contentType,
          fileSizeBytes: bytes.lengthInBytes,
        ),
    };

    await api.uploadFileToPresignedUrl(
      uploadTarget.uploadUrl,
      bytes,
      contentType: contentType,
    );

    return UploadedImageResult(
      s3Key: uploadTarget.s3Key,
      displayUrl: uploadTarget.fileUrl,
    );
  }

  String _resolveContentType(String fileName) {
    final normalized = fileName.trim().toLowerCase();
    if (normalized.endsWith('.jpg') || normalized.endsWith('.jpeg')) {
      return 'image/jpeg';
    }
    if (normalized.endsWith('.png')) {
      return 'image/png';
    }
    throw ImageUploadException('Chỉ hỗ trợ ảnh JPG/PNG.');
  }
}
