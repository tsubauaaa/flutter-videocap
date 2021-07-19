import 'package:camera/camera.dart';
import 'package:riverpod/riverpod.dart';

final cameraProvider = FutureProvider.autoDispose.family<CameraController, int>(
  (ref, index) async {
    final cameras = await availableCameras();
    final cameraController = CameraController(
        cameras[index], ResolutionPreset.medium,
        enableAudio: false);
    await cameraController.initialize();
    return cameraController;
  },
);
