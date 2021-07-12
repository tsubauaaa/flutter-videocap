import 'package:camera/camera.dart';

class ScannerUtils {
  static Future<CameraDescription> getCamera(CameraLensDirection dir) async {
    return availableCameras().then(
      (List<CameraDescription> cameras) => cameras.firstWhere(
        (CameraDescription camera) => camera.lensDirection == dir,
      ),
    );
  }
}
