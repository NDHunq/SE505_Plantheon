# Hướng dẫn sử dụng Supabase Storage Upload

## Cài đặt

Các package đã được thêm vào `pubspec.yaml`:
- `supabase_flutter: ^2.5.0` - SDK Supabase cho Flutter
- `file_picker: ^8.0.0+1` - Chọn file từ thiết bị
- `path_provider: ^2.1.0` - Quản lý đường dẫn file

## Cấu trúc File

### 1. Supabase Service (`lib/core/services/supabase_service.dart`)
Service xử lý tất cả các tương tác với Supabase Storage.

**Các phương thức chính:**
- `initialize()` - Khởi tạo Supabase client
- `uploadFile()` - Upload file từ đường dẫn local
- `uploadFileFromBytes()` - Upload file từ bytes (Uint8List)
- `deleteFile()` - Xóa file
- `listFiles()` - Lấy danh sách file trong bucket
- `createBucket()` - Tạo bucket mới

### 2. File Upload Screen (`lib/presentation/screens/upload/file_upload_screen.dart`)
Màn hình UI để upload file với các tính năng:
- Upload file bất kỳ
- Upload ảnh từ thư viện
- Chụp ảnh và upload
- Hiển thị danh sách file đã upload
- Copy/xem public URL

## Cách sử dụng

### Bước 1: Khởi tạo Supabase trong main.dart

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const MainApp());
}
```

### Bước 2: Tạo Bucket trên Supabase Dashboard

1. Truy cập: https://qlxcxrrhrrlfaqplqkmz.supabase.co
2. Vào **Storage** > **Create new bucket**
3. Tạo bucket với tên: `uploads` (hoặc tên khác)
4. Chọn **Public bucket** để file có thể truy cập công khai

### Bước 3: Thiết lập Storage Policies (quan trọng!)

Vào **Storage** > chọn bucket > **Policies** và thêm policy:

**Policy cho INSERT (upload):**
```sql
CREATE POLICY "Allow public uploads"
ON storage.objects
FOR INSERT
TO public
WITH CHECK (bucket_id = 'uploads');
```

**Policy cho SELECT (read):**
```sql
CREATE POLICY "Allow public reads"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'uploads');
```

**Policy cho DELETE:**
```sql
CREATE POLICY "Allow public deletes"
ON storage.objects
FOR DELETE
TO public
USING (bucket_id = 'uploads');
```

### Bước 4: Sử dụng màn hình Upload

#### Option 1: Navigate từ màn hình khác
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const FileUploadScreen(),
  ),
);
```

#### Option 2: Thêm vào route
```dart
MaterialApp(
  routes: {
    '/upload': (context) => const FileUploadScreen(),
  },
);
```

#### Option 3: Test nhanh - Thay đổi home trong main.dart
```dart
MaterialApp(
  home: const FileUploadScreen(),  // Thay vì Login()
)
```

## Sử dụng SupabaseService trong code

### Upload file
```dart
try {
  final publicUrl = await SupabaseService.uploadFile(
    bucketName: 'uploads',
    filePath: '/path/to/file.jpg',
    fileName: 'my-image.jpg',
  );
  print('File URL: $publicUrl');
} catch (e) {
  print('Error: $e');
}
```

### Upload từ bytes
```dart
import 'dart:typed_data';

Uint8List fileBytes = ...; // File data
final url = await SupabaseService.uploadFileFromBytes(
  bucketName: 'uploads',
  fileBytes: fileBytes,
  fileName: 'document.pdf',
);
```

### Xóa file
```dart
await SupabaseService.deleteFile(
  bucketName: 'uploads',
  fileName: 'my-image.jpg',
);
```

### Lấy danh sách file
```dart
final files = await SupabaseService.listFiles(
  bucketName: 'uploads',
  path: 'subfolder', // Optional
);

for (var file in files) {
  print('${file.name} - ${file.metadata?['size']}');
}
```

## Thông tin Supabase

- **URL**: https://qlxcxrrhrrlfaqplqkmz.supabase.co
- **Anon Key**: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFseGN4cnJocnJsZmFxcGxxa216Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5NDI4MjMsImV4cCI6MjA3MzUxODgyM30.OlcWxyXO_p8Frfu81UTmQmZyzrGhe9Dtcel5-ghS2Ko

## Lưu ý bảo mật

⚠️ **Quan trọng**: 
- Anon key hiện đang được hardcode trong code. Trong production, nên sử dụng environment variables hoặc secure storage.
- Storage policies cần được cấu hình cẩn thận để tránh truy cập trái phép.
- Với public bucket, bất kỳ ai cũng có thể truy cập file qua URL.

## Troubleshooting

### Lỗi: "new row violates row-level security policy"
→ Cần thêm Storage Policies như hướng dẫn ở Bước 3

### Lỗi: "Bucket not found"
→ Kiểm tra bucket đã được tạo trên Supabase Dashboard chưa

### Lỗi: "Upload failed"
→ Kiểm tra:
- Kết nối internet
- Bucket name đúng
- File size không vượt quá giới hạn (mặc định 50MB)

## Giới hạn

- **File size**: Mặc định 50MB (có thể tăng trong dashboard)
- **Upload concurrent**: Khuyến nghị không quá 10 file cùng lúc
- **Storage**: Free tier có 1GB storage

## Demo

Chạy app và:
1. Nhập bucket name (mặc định: `uploads`)
2. Chọn một trong các nút:
   - **Chọn File**: Chọn bất kỳ file nào từ thiết bị
   - **Chọn Ảnh**: Chọn ảnh từ thư viện
   - **Chụp Ảnh**: Mở camera để chụp ảnh mới
3. File sẽ được upload và hiển thị trong danh sách
4. Nhấn icon để copy hoặc xem public URL

## Tích hợp với form diary

Để thêm upload ảnh vào các form (chiTieu, banSanPham, etc.):

```dart
// Trong form state
String? uploadedImageUrl;

// Thêm button upload
ElevatedButton(
  onPressed: () async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      final url = await SupabaseService.uploadFile(
        bucketName: 'diary-images',
        filePath: image.path,
        fileName: '${DateTime.now().millisecondsSinceEpoch}_${image.name}',
      );
      
      setState(() {
        uploadedImageUrl = url;
      });
    }
  },
  child: const Text('Upload Ảnh'),
),

// Hiển thị ảnh đã upload
if (uploadedImageUrl != null)
  Image.network(uploadedImageUrl!),
```
