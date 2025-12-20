import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
import 'package:se501_plantheon/common/widgets/fast_lottie_loading.dart';
import 'package:se501_plantheon/common/widgets/dialog/basic_dialog.dart';
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
import 'package:toastification/toastification.dart';
import 'package:se501_plantheon/core/services/camera_service.dart';

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
  bool _flashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras ??= await CameraService.getCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() => _cameraError = 'Không tìm thấy camera');
        return;
      }
      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.max,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await _cameraController!.initialize();
      setState(() => _isCameraReady = true);
      // Thực hiện các cấu hình bổ sung sau khi preview đã sẵn sàng để giảm thời gian chờ
      unawaited(_configureCameraAfterInit());
    } catch (e) {
      setState(() => _cameraError = 'Lỗi camera: $e');
    }
  }

  Future<void> _configureCameraAfterInit() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }
    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      await _cameraController!.setExposureMode(ExposureMode.auto);
      await _cameraController!.setFocusPoint(const Offset(0.5, 0.5));
      await _cameraController!.setExposurePoint(const Offset(0.5, 0.5));
    } catch (_) {
      // Một số thiết bị không hỗ trợ đặt điểm thủ công, bỏ qua
    }
  }

  Future<void> _toggleFlash() async {
    // Toggle the torch/flash mode on the camera when available
    if (_cameraController == null || !_isCameraReady) {
      // still update UI state so user sees change (optional)
      setState(() => _flashOn = !_flashOn);
      return;
    }

    try {
      if (_flashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
      }
      setState(() => _flashOn = !_flashOn);
    } catch (e) {
      // ignore errors from camera flash toggle
      setState(() => _flashOn = !_flashOn);
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

    // Show loading gif dialog immediately
    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: FastLottieLoading(
            assetPath: 'assets/animations/Search.json',
            width: 250.sp,
            height: 250.sp,
            speed: 2.0, // 2x speed
          ),
        ),
      );
    }

    try {
      // Gọi API prediction v2 (with plant detection)
      final result = await DiseasePredictionService.instance.predictDiseaseV2(
        _image!,
      );

      setState(() {
        _loading = false;
        _predictionResult = result;
      });

      print('✅ Phân tích thành công: ${result.topPrediction?.label}');

      if (mounted && result.topPrediction != null) {
        // Wait a bit to show the loading animation
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();
          // Navigate to result screen
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
                  confidenceScore: result.topPrediction!.probability,
                ),
              ),
            ),
          );
        }
      }
    } on NoPlantDetectedException catch (e) {
      // Handle no plant detected error specifically
      setState(() {
        _loading = false;
        _cameraError = 'Không phát hiện cây trong ảnh';
      });

      // Close loading dialog and show error dialog
      if (mounted) {
        // Wait a bit to show the loading animation
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => BasicDialog(
              title: 'Không phát hiện cây :(',
              content:
                  'Hình như đây không phải là cây nhỉ? Hãy thử chụp lại ảnh lá cây rõ nét hơn để tôi có thể giúp bạn chẩn đoán bệnh chính xác nhé!',
              confirmText: 'Chụp lại',
              onConfirm: () async {
                Navigator.of(context).pop();
                await _cameraController?.resumePreview();
                setState(() {
                  _image = null;
                  _predictionResult = null;
                  _cameraError = null;
                });
              },
            ),
          );
        }
      }

      print('⚠️ Không phát hiện cây: $e');
    } on LowConfidencePredictionException catch (e) {
      // Handle low confidence prediction error
      setState(() {
        _loading = false;
        _cameraError = 'Độ tin cậy dự đoán thấp';
      });

      // Close loading dialog and show error dialog
      if (mounted) {
        // Wait a bit to show the loading animation
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          // Close loading dialog
          Navigator.of(context).pop();
          // Show error dialog
          showDialog(
            context: context,
            builder: (context) => BasicDialog(
              title: 'Không thể nhận diện chính xác',
              content:
                  'Hệ thống chưa thể nhận diện chính xác loại cây này (độ tin cậy: ${(e.confidence * 100).toStringAsFixed(1)}%). '
                  'Có thể đây là loại cây mà hệ thống chưa được huấn luyện. '
                  'Hãy thử chụp lại ảnh rõ nét hơn hoặc thử với loại cây khác nhé!',
              confirmText: 'Chụp lại',
              onConfirm: () async {
                Navigator.of(context).pop();
                await _cameraController?.resumePreview();
                setState(() {
                  _image = null;
                  _predictionResult = null;
                  _cameraError = null;
                });
              },
            ),
          );
        }
      }

      print('⚠️ Độ tin cậy thấp: $e');
    } catch (e) {
      setState(() {
        _loading = false;
        _cameraError = 'Lỗi phân tích: $e';
      });

      // Close loading dialog and show error toast
      if (mounted) {
        // Close loading dialog first
        Navigator.of(context).pop();

        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text(
            'Không thể phân tích ảnh. Vui lòng kiểm tra kết nối server.',
          ),
          autoCloseDuration: const Duration(seconds: 3),
          alignment: Alignment.bottomCenter,
          showProgressBar: true,
        );
      }

      print('❌ Lỗi phân tích: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_image != null) {
          try {
            await _cameraController?.resumePreview();
          } catch (_) {}
          if (mounted) {
            setState(() {
              _image = null;
              _predictionResult = null;
              _cameraError = null;
            });
          }
          return false;
        }
        return true;
      },
      child: Scaffold(
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
                  : ClipRect(
                      child: FittedBox(
                        fit: BoxFit.cover, // lấp đầy mà không méo
                        child: SizedBox(
                          width: _cameraController!.value.previewSize!.height,
                          height: _cameraController!.value.previewSize!.width,
                          child: CameraPreview(_cameraController!),
                        ),
                      ),
                    ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                color: Colors.black.withOpacity(0.7),
                padding: EdgeInsets.symmetric(vertical: 10.sp),
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 16.sp,
                    left: 10.sp,
                    right: 10.sp,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_image == null) ...[
                        IconButton(
                          icon: SvgPicture.asset(
                            AppVectors.arrowBack,
                            width: 28.sp,
                            height: 28.sp,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          "Quét bệnh",
                          style: TextStyle(
                            color: AppColors.primary_700,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 4.sp),
                          child: GestureDetector(
                            onTap: _toggleFlash,
                            child: SvgPicture.asset(
                              _flashOn ? AppVectors.flash : AppVectors.unflash,
                              height: 24.sp,
                              width: 24.sp,
                              color: _flashOn
                                  ? AppColors.primary_main
                                  : AppColors.primary_600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            if (_image == null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: EdgeInsets.symmetric(vertical: 20.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 64.sp,
                    children: [
                      InkWell(
                        onTap: () => _pickImage(ImageSource.gallery),
                        child: SvgPicture.asset(
                          AppVectors.gallery,
                          color: AppColors.primary_600,
                          height: 34,
                          width: 34,
                        ),
                      ),
                      Container(
                        height: 64.sp,
                        width: 64.sp,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary_300,
                            width: 6,
                          ),
                          borderRadius: BorderRadius.circular(50.sp),
                        ),
                        child: FloatingActionButton(
                          onPressed: _takePicture,
                          backgroundColor: AppColors.primary_main,
                          elevation: 0,
                          shape: CircleBorder(),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => {
                          //Hiển thị dialog hướng dẫn
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: AppColors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              contentPadding: const EdgeInsets.all(16),
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.8,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Mẹo quét chẩn đoán",
                                            style: TextStyle(
                                              color: AppColors.primary_600,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          icon: Icon(
                                            Icons.close,
                                            color: AppColors.primary_700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Text(
                                      "• Đảm bảo ánh sáng đủ để camera có thể chụp rõ ràng.\n"
                                      "• Giữ điện thoại ổn định khi chụp ảnh để tránh mờ.\n"
                                      "• Chụp ảnh từ khoảng cách vừa phải, không quá gần hoặc quá xa.\n"
                                      "• Tập trung vào vùng bị bệnh trên lá cây để có kết quả chính xác hơn.",
                                      style: TextStyle(
                                        color: AppColors.text_color_main,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8.sp),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary_main,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "Đã hiểu",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        },
                        child: SvgPicture.asset(
                          AppVectors.info,
                          height: 36.sp,
                          width: 36.sp,
                          color: AppColors.primary_600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_image != null)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.7),
                  padding: EdgeInsets.symmetric(vertical: 20.sp),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 64.sp,
                    children: [
                      if (_image != null)
                        GestureDetector(
                          onTap: () async {
                            await _cameraController?.resumePreview();
                            setState(() {
                              _image = null;
                              _predictionResult = null;
                              _cameraError = null;
                            });
                          },
                          child: SvgPicture.asset(
                            AppVectors.reload,
                            color: AppColors.primary_700,
                            width: 30.sp,
                            height: 30.sp,
                          ),
                        ),
                      Container(
                        height: 64.sp,
                        width: 64.sp,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary_300,
                            width: 6,
                          ),
                          borderRadius: BorderRadius.circular(50.sp),
                        ),
                        child: FloatingActionButton(
                          onPressed: !_loading ? _analyzeImage : null,
                          backgroundColor: AppColors.primary_main,
                          elevation: 0,
                          shape: CircleBorder(),
                          child: _loading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: LoadingIndicator(),
                                )
                              : Icon(
                                  Icons.check_rounded,
                                  size: 32.sp,
                                  color: AppColors.white,
                                ),
                        ),
                      ),
                      SizedBox(width: 34.sp),
                    ],
                  ),
                ),
              ),
            if (_image == null)
              Positioned.fill(
                bottom: 30.sp,
                child: Align(
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    AppVectors.qr,
                    color: AppColors.primary_600,
                    height: 450.sp,
                    width: 450.sp,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
