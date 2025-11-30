import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/disease_prediction_service.dart';
import 'package:se501_plantheon/data/models/disease_prediction_model.dart';
import 'package:se501_plantheon/core/services/disease_prediction_service.dart';
import 'package:se501_plantheon/data/models/disease_prediction_model.dart';

class Scan extends StatefulWidget {
  const Scan({super.key});

  @override
  State<Scan> createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  File? _image;
  bool _loading = false;
  DiseasePredictionResponse? _predictionResult;
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraReady = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _cameraError = 'Không tìm thấy camera');
        return;
      }
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
      );
      await _cameraController!.initialize();
      setState(() => _isCameraReady = true);
    } catch (e) {
      setState(() => _cameraError = 'Lỗi camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      // Pause camera to save resources
      await _cameraController?.pausePreview();
      setState(() {
        _image = File(pickedFile.path);
        _predictionResult = null;
      });
    }
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _cameraController == null) return;
    try {
      final image = await _cameraController!.takePicture();
      // Pause camera to save resources
      await _cameraController?.pausePreview();
      setState(() {
        _image = File(image.path);
        _predictionResult = null;
      });
    } catch (e) {
      setState(() => _cameraError = 'Chụp ảnh thất bại: $e');
    }
  }

  Future<void> _analyzeImage() async {
    if (_image == null) return;

    setState(() {
      _loading = true;
      _predictionResult = null;
      _cameraError = null;
    });

    try {
      // Gọi API prediction
      final result = await DiseasePredictionService.instance.predictDisease(
        _image!,
      );

      setState(() {
        _loading = false;
        _predictionResult = result;
      });

      print('✅ Phân tích thành công: ${result.topPrediction?.label}');
    } catch (e) {
      setState(() {
        _loading = false;
        _cameraError = 'Lỗi phân tích: $e';
      });

      // Show error dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Không thể phân tích ảnh. Vui lòng kiểm tra kết nối server.',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      print('❌ Lỗi phân tích: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: BasicAppbar(title: "Quét ảnh"),
      body: Stack(
        children: [
          // Hiển thị camera preview hoặc ảnh đã chụp
          Positioned.fill(
            child: _image != null
                ? Image.file(
                    _image!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : _cameraError != null
                ? Center(
                    child: Text(
                      _cameraError!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  )
                : (!_isCameraReady || _cameraController == null)
                ? const Center(child: CircularProgressIndicator())
                : CameraPreview(_cameraController!),
          ),
          // Overlay nút chức năng
          if (_image == null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút chọn ảnh từ gallery
                  FloatingActionButton(
                    heroTag: 'gallery',
                    backgroundColor: Colors.white70,
                    onPressed: () => _pickImage(ImageSource.gallery),
                    mini: true,
                    child: SvgPicture.asset(
                      AppVectors.gallery,
                      color: AppColors.primary_600,
                      height: 32,
                      width: 32,
                    ),
                  ),
                  const SizedBox(width: 40),
                  // Nút chụp ảnh trực tiếp
                  FloatingActionButton(
                    heroTag: 'camera',
                    backgroundColor: Colors.white,
                    onPressed: _takePicture,
                    elevation: 4,
                    shape: const CircleBorder(),
                    child: SvgPicture.asset(
                      AppVectors.camera,
                      color: AppColors.primary_600,
                      height: 35,
                      width: 35,
                    ),
                  ),
                ],
              ),
            ),
          // Nút quay lại camera nếu đã có ảnh
          if (_image != null)
            Positioned(
              top: 32,
              left: 16,
              child: FloatingActionButton(
                heroTag: 'backToCamera',
                mini: true,
                backgroundColor: AppColors.white,
                onPressed: () async {
                  await _cameraController?.resumePreview();
                  setState(() {
                    _image = null;
                    _predictionResult = null;
                    _cameraError = null;
                  });
                },
                child: const Icon(Icons.refresh, color: AppColors.primary_600),
              ),
            ),
          // Nút phân tích ảnh và kết quả
          if (_image != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 70,
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary_main,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: !_loading ? _analyzeImage : null,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Phân tích ảnh',
                            style: AppTextStyles.s16SemiBold(),
                          ),
                  ),
                  if (_predictionResult != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top prediction
                          Row(
                            children: [
                              Icon(
                                _predictionResult!.topPrediction!.isHealthy
                                    ? Icons.check_circle
                                    : Icons.warning,
                                color:
                                    _predictionResult!.topPrediction!.isHealthy
                                    ? Colors.green
                                    : Colors.orange,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _predictionResult!
                                          .topPrediction!
                                          .plantType,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _predictionResult!
                                          .topPrediction!
                                          .diseaseName,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Độ tin cậy: ${_predictionResult!.topPrediction!.confidencePercent}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thời gian xử lý: ${_predictionResult!.inferenceTimeMs.toStringAsFixed(0)}ms',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 12,
                            ),
                          ),
                          // Show top 3 predictions
                          if (_predictionResult!.topPredictions.length > 1) ...[
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 8),
                            const Text(
                              'Các khả năng khác:',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ...(_predictionResult!.topPredictions
                                .skip(1)
                                .take(2)
                                .map(
                                  (pred) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            pred.diseaseName,
                                            style: const TextStyle(
                                              color: Colors.white60,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          pred.confidencePercent,
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList()),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          if (_image == null)
            Positioned.fill(
              child: Align(
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  AppVectors.qr,
                  color: AppColors.primary_600,
                  height: 350,
                  width: 350,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
