import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/appbar/basic_appbar.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/core/configs/assets/app_text_styles.dart';
import 'package:se501_plantheon/core/configs/assets/app_vectors.dart';
import 'package:se501_plantheon/core/configs/theme/app_colors.dart';
import 'package:se501_plantheon/core/services/disease_prediction_service.dart';
import 'package:se501_plantheon/data/models/disease_prediction_model.dart';
import 'package:se501_plantheon/presentation/screens/scan/disease_description.dart';
import 'package:se501_plantheon/presentation/bloc/disease/disease_bloc.dart';
import 'package:se501_plantheon/data/datasources/disease_remote_datasource.dart';
import 'package:se501_plantheon/data/repository/disease_repository_impl.dart';
import 'package:se501_plantheon/domain/usecases/disease/get_disease.dart';
import 'package:se501_plantheon/core/configs/constants/api_constants.dart';

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

      // Hiển thị gif magnify.gif trong 2 giây trước khi chuyển trang
      if (mounted && result.topPrediction != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: SizedBox(
              width: 100,
              height: 100,
              child: Image.asset('assets/gif/magnify.gif', fit: BoxFit.contain),
            ),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider<DiseaseBloc>(
                create: (context) => DiseaseBloc(
                  getDisease: GetDisease(
                    repository: DiseaseRepositoryImpl(
                      remoteDataSource: DiseaseRemoteDataSourceImpl(
                        client: http.Client(),
                        baseUrl: ApiConstants.diseaseApiUrl,
                      ),
                    ),
                  ),
                ),
                child: DiseaseDescriptionScreen(
                  diseaseLabel: result.topPrediction!.label,
                  myImage: _image,
                ),
              ),
            ),
          );
        }
      }
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
                ? const Center(child: LoadingIndicator())
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
                            child: LoadingIndicator(),
                          )
                        : Text(
                            'Phân tích ảnh',
                            style: AppTextStyles.s16SemiBold(),
                          ),
                  ),
                  if (_predictionResult != null) ...[],
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
