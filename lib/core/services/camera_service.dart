import 'package:camera/camera.dart';

/// Simple cache to avoid calling [availableCameras] multiple times.
class CameraService {
  static Future<List<CameraDescription>>? _availableCameras;

  /// Prefetch camera descriptions as early as possible (e.g. at app start).
  static Future<List<CameraDescription>> prefetch() {
    _availableCameras ??= availableCameras();
    return _availableCameras!;
  }

  /// Get cached cameras; will prefetch if not done yet.
  static Future<List<CameraDescription>> getCameras() async {
    return _availableCameras ?? await prefetch();
  }
}
