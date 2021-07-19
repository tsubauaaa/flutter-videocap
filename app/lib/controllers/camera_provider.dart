import 'package:app/pages/camera_preview_top_page.dart';
import 'package:camera/camera.dart';
import 'package:riverpod/riverpod.dart';

final cameraProvider = FutureProvider.autoDispose<VideoCapCameraController>(
  (ref) async {
    final index = ref.watch(indexProvider);
    final cameras = await availableCameras();
    final cameraController = CameraController(
        cameras[index], ResolutionPreset.medium,
        enableAudio: false);
    await cameraController.initialize();
    return VideoCapCameraController(cameraController);
  },
);

class VideoCapCameraController {
  VideoCapCameraController(this.cameraController);
  final CameraController cameraController;
}
