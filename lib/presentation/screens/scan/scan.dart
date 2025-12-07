import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:se501_plantheon/common/widgets/loading_indicator.dart';
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
                color: Colors.black.withOpacity(0.5),
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
                  color: Colors.black.withOpacity(0.5),
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
                  color: Colors.black.withOpacity(0.5),
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
