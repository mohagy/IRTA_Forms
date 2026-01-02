import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload a file to Firebase Storage
  Future<String?> uploadFile({
    required String path,
    required File file,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  // Upload multiple files
  Future<List<String>> uploadFiles({
    required String basePath,
    required List<File> files,
    List<String>? fileNames,
  }) async {
    final List<String> urls = [];
    
    for (int i = 0; i < files.length; i++) {
      final fileName = fileNames?[i] ?? 'file_$i';
      final path = '$basePath/$fileName';
      final url = await uploadFile(path: path, file: files[i]);
      if (url != null) {
        urls.add(url);
      }
    }
    
    return urls;
  }

  // Pick a file from device
  Future<FilePickerResult?> pickFile({
    List<String>? allowedExtensions,
    String? type,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type == 'image' 
            ? FileType.image 
            : type == 'pdf' 
                ? FileType.custom 
                : FileType.any,
        allowedExtensions: allowedExtensions,
      );
      return result;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  // Pick multiple files
  Future<FilePickerResult?> pickFiles({
    List<String>? allowedExtensions,
    String? type,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type == 'image' 
            ? FileType.image 
            : type == 'pdf' 
                ? FileType.custom 
                : FileType.any,
        allowedExtensions: allowedExtensions,
        allowMultiple: true,
      );
      return result;
    } catch (e) {
      throw Exception('Failed to pick files: $e');
    }
  }

  // Delete a file from Firebase Storage
  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref(path).delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }

  // Get file size in MB
  double getFileSizeInMB(int bytes) {
    return bytes / (1024 * 1024);
  }

  // Validate file size (max 10MB)
  bool validateFileSize(int bytes, {double maxSizeMB = 10.0}) {
    return getFileSizeInMB(bytes) <= maxSizeMB;
  }
}

