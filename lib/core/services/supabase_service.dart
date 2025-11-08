import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://qlxcxrrhrrlfaqplqkmz.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFseGN4cnJocnJsZmFxcGxxa216Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NDI4MjMsImV4cCI6MjA3MzUxODgyM30.OlcWxyXO_p8Frfu81UTmQmZyzrGhe9Dtcel5-ghS2Ko';

  static SupabaseClient? _client;

  static Future<void> initialize() async {
    await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
    _client = Supabase.instance.client;
  }

  static SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase chưa được khởi tạo. Gọi initialize() trước.');
    }
    return _client!;
  }

  /// Upload file từ bytes (dùng cho cả mobile và web)
  /// [bucketName] - Tên bucket (ví dụ: 'images', 'documents')
  /// [fileBytes] - Nội dung file dạng bytes
  /// [fileName] - Tên file muốn lưu trên storage
  /// Returns: URL public của file đã upload
  static Future<String> uploadFileFromBytes({
    required String bucketName,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      // Upload file từ bytes
      final response = await client.storage
          .from(bucketName)
          .uploadBinary(fileName, fileBytes);

      if (response.isEmpty) {
        throw Exception('Upload thất bại');
      }

      // Lấy public URL
      final publicUrl = client.storage.from(bucketName).getPublicUrl(fileName);

      return publicUrl;
    } catch (e) {
      throw Exception('Lỗi upload file: $e');
    }
  }

  /// Xóa file từ storage
  static Future<void> deleteFile({
    required String bucketName,
    required String fileName,
  }) async {
    try {
      await client.storage.from(bucketName).remove([fileName]);
    } catch (e) {
      throw Exception('Lỗi xóa file: $e');
    }
  }

  /// Lấy danh sách file trong bucket
  static Future<List<FileObject>> listFiles({
    required String bucketName,
    String? path,
  }) async {
    try {
      final files = await client.storage.from(bucketName).list(path: path);
      return files;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách file: $e');
    }
  }

  /// Tạo bucket mới (cần quyền admin)
  static Future<void> createBucket({
    required String bucketName,
    bool isPublic = true,
  }) async {
    try {
      await client.storage.createBucket(
        bucketName,
        BucketOptions(public: isPublic),
      );
    } catch (e) {
      throw Exception('Lỗi tạo bucket: $e');
    }
  }
}
