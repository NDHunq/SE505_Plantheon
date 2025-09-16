import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  File? _image;
  bool _loading = false;
  String? _result;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _result = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;
    setState(() {
      _loading = true;
      _result = null;
    });
    // TODO: Gọi API hoặc xử lý ML tại đây
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _loading = false;
      _result = "Kết quả phân tích: Không phát hiện bệnh.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quét ảnh bệnh')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _image == null
                  ? const Center(
                      child: Text('Vui lòng chọn hoặc chụp ảnh cây bệnh'),
                    )
                  : Image.file(_image!),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Chụp ảnh'),
                ),
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Chọn ảnh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _image != null && !_loading ? _analyzeImage : null,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Phân tích ảnh'),
            ),
            if (_result != null) ...[
              const SizedBox(height: 16),
              Text(
                _result!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
