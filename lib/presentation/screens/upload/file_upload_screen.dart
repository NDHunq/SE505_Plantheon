import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/services/supabase_service.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:toastification/toastification.dart';

class FileUploadScreen extends StatefulWidget {
  const FileUploadScreen({super.key});

  @override
  State<FileUploadScreen> createState() => _FileUploadScreenState();
}

class _FileUploadScreenState extends State<FileUploadScreen> {
  final TextEditingController _bucketNameController = TextEditingController(
    text: 'uploads',
  );
  List<UploadedFile> _uploadedFiles = [];
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _availableBuckets = [];

  @override
  void initState() {
    super.initState();
    _loadBuckets();
  }

  @override
  void dispose() {
    _bucketNameController.dispose();
    super.dispose();
  }

  Future<void> _loadBuckets() async {
    try {
      final buckets = await SupabaseService.client.storage.listBuckets();
      setState(() {
        _availableBuckets = buckets.map((b) => b.name).toList();
      });
    } catch (e) {
      print('Lỗi load buckets: $e');
    }
  }

  Future<void> _pickAndUploadFile() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      // Chọn file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: true, // Đọc file thành bytes
      );

      if (result != null && result.files.single.bytes != null) {
        await _uploadFileFromBytes(
          result.files.single.bytes!,
          result.files.single.name,
          result.files.single.size,
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi chọn file: $e';
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        await _uploadFileFromBytes(bytes, image.name, bytes.length);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi chọn ảnh: $e';
      });
    }
  }

  Future<void> _takePhotoAndUpload() async {
    try {
      setState(() {
        _errorMessage = null;
      });

      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        await _uploadFileFromBytes(bytes, photo.name, bytes.length);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi chụp ảnh: $e';
      });
    }
  }

  Future<void> _uploadFileFromBytes(
    Uint8List fileBytes,
    String fileName,
    int fileSize,
  ) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Tạo tên file unique với timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uniqueFileName = '${timestamp}_$fileName';

      // Upload file
      final publicUrl = await SupabaseService.uploadFileFromBytes(
        bucketName: _bucketNameController.text.trim(),
        fileBytes: fileBytes,
        fileName: uniqueFileName,
      );

      setState(() {
        _uploadedFiles.insert(
          0,
          UploadedFile(
            name: fileName,
            url: publicUrl,
            uploadedAt: DateTime.now(),
            size: fileSize,
          ),
        );
        _isLoading = false;
      });

      // Hiển thị thông báo thành công và dialog với URL
      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text('Upload thành công!'),
          autoCloseDuration: const Duration(seconds: 2),
          alignment: Alignment.bottomCenter,
          showProgressBar: true,
        );

        // Hiển thị dialog với URL để copy
        _showUrlDialog(publicUrl, fileName);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text('Upload thất bại: $e'),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          showProgressBar: true,
        );
      }
    }
  }

  void _showUrlDialog(String url, String fileName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            const Text('Upload Thành Công!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'File: $fileName',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Public URL (không expire):',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: SelectableText(
                url,
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () async {
              // Copy to clipboard
              await Clipboard.setData(ClipboardData(text: url));
              if (context.mounted) {
                Navigator.pop(context);
                toastification.show(
                  context: context,
                  type: ToastificationType.success,
                  style: ToastificationStyle.flat,
                  title: Text('✓ URL đã được copy vào clipboard!'),
                  autoCloseDuration: const Duration(seconds: 2),
                  alignment: Alignment.bottomCenter,
                  showProgressBar: true,
                );
              }
            },
            icon: const Icon(Icons.copy),
            label: const Text('Copy URL'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload File lên Supabase'),
        backgroundColor: AppColors.primary_600,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Bucket name input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _bucketNameController,
                  decoration: InputDecoration(
                    labelText: 'Bucket Name',
                    hintText: 'Nhập tên bucket (ví dụ: uploads, images)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.folder),
                  ),
                ),
                if (_availableBuckets.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _availableBuckets
                        .map(
                          (bucket) => ActionChip(
                            label: Text(bucket),
                            onPressed: () {
                              _bucketNameController.text = bucket;
                            },
                            backgroundColor:
                                _bucketNameController.text == bucket
                                ? AppColors.primary_600
                                : Colors.grey.shade200,
                            labelStyle: TextStyle(
                              color: _bucketNameController.text == bucket
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),

          // Upload buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAndUploadFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Chọn File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _pickAndUploadImage,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Chọn Ảnh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _takePhotoAndUpload,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Chụp Ảnh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LoadingIndicator(),
            ),

          // Error message
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Uploaded files list
          Expanded(
            child: _uploadedFiles.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có file nào được upload',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _uploadedFiles.length,
                    itemBuilder: (context, index) {
                      final file = _uploadedFiles[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary_600,
                            child: Icon(
                              _getFileIcon(file.name),
                              color: Colors.white,
                            ),
                          ),
                          title: Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_formatFileSize(file.size)),
                              Text(
                                'Uploaded: ${file.uploadedAt.hour}:${file.uploadedAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.copy, size: 20),
                                tooltip: 'Copy URL',
                                onPressed: () async {
                                  // Copy URL to clipboard
                                  await Clipboard.setData(
                                    ClipboardData(text: file.url),
                                  );
                                  if (context.mounted) {
                                    toastification.show(
                                      context: context,
                                      type: ToastificationType.success,
                                      style: ToastificationStyle.flat,
                                      title: Text(
                                        '✓ URL đã copy vào clipboard!',
                                      ),
                                      autoCloseDuration: const Duration(
                                        seconds: 2,
                                      ),
                                      alignment: Alignment.bottomCenter,
                                      showProgressBar: true,
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.link, size: 20),
                                tooltip: 'Xem URL',
                                onPressed: () {
                                  // Show full URL
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Public URL'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            file.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.grey.shade100,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: SelectableText(
                                              file.url,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontFamily: 'monospace',
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      actions: [
                                        TextButton.icon(
                                          onPressed: () async {
                                            await Clipboard.setData(
                                              ClipboardData(text: file.url),
                                            );
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              toastification.show(
                                                context: context,
                                                type:
                                                    ToastificationType.success,
                                                style: ToastificationStyle.flat,
                                                title: Text('✓ URL đã copy!'),
                                                autoCloseDuration:
                                                    const Duration(seconds: 2),
                                                alignment:
                                                    Alignment.bottomCenter,
                                                showProgressBar: true,
                                              );
                                            }
                                          },
                                          icon: const Icon(Icons.copy),
                                          label: const Text('Copy'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Đóng'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return Icons.image;
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      case 'mp4':
      case 'mov':
      case 'avi':
        return Icons.video_file;
      case 'mp3':
      case 'wav':
        return Icons.audio_file;
      default:
        return Icons.insert_drive_file;
    }
  }
}

class UploadedFile {
  final String name;
  final String url;
  final DateTime uploadedAt;
  final int size;

  UploadedFile({
    required this.name,
    required this.url,
    required this.uploadedAt,
    required this.size,
  });
}
