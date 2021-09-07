import 'dart:io';

import 'package:app/models/reognition_model.dart';
import 'package:app/providers/index_provider.dart';
import 'package:app/providers/recognitions_provider.dart';
import 'package:app/services/classifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:image/image.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

final cameraProvider = FutureProvider.autoDispose<VideoCapCameraController>(
  (ref) async {
    final index = ref.watch(indexProvider);
    final cameras = await availableCameras();
    final cameraController = CameraController(
        cameras[index], ResolutionPreset.medium,
        enableAudio: false);
    await cameraController.initialize();
    return VideoCapCameraController(cameraController, ref.read);
  },
);

class VideoCapCameraController {
  VideoCapCameraController(
    this.cameraController,
    this.read,
  ) {
    Future(
      () async {
        classifier = Classifier();
        // 動画ストリーミング開始
        await cameraController.startImageStream(onLatestImageAvailable);
      },
    );
  }
  final CameraController cameraController;
  final Reader read;
  Classifier? classifier;

  // 動画ストリーミングに対する処理
  Future<void> onLatestImageAvailable(CameraImage cameraImage) async {
    // 未作成のisFaceDetectProviderを更新してやる処理
    if (classifier == null) {
      return;
    }
    final isolateCamImgData =
        IsolateData(cameraImage, classifier!.interpreter!.address);
    read(recognitionsProvider.notifier)
        .update(await compute(inference, isolateCamImgData));
  }

  static Future<RecognitionModel> inference(
      IsolateData isolateCamImgData) async {
    var image = ImageUtils.convertYUV420ToImage(isolateCamImgData.cameraImage);
    if (Platform.isAndroid) {
      image = copyRotate(image, 90);
    }

    final classifier = Classifier(
        Interpreter.fromAddress(isolateCamImgData.interpreterAddress));

    return classifier.predict(image);
  }
}

class IsolateData {
  IsolateData(this.cameraImage, this.interpreterAddress);

  final CameraImage cameraImage;
  final int interpreterAddress;
}

class ImageUtils {
  static Image convertYUV420ToImage(CameraImage cameraImage) {
    final width = cameraImage.width;
    final height = cameraImage.height;

    final uvRowStride = cameraImage.planes[1].bytesPerRow;
    final uvPixelStride = cameraImage.planes[1].bytesPerPixel;

    final image = Image(width, height);

    for (var w = 0; w < width; w++) {
      for (var h = 0; h < height; h++) {
        final uvIndex =
            uvPixelStride! * (w / 2).floor() + uvRowStride * (h / 2).floor();
        final index = h * width + w;

        final y = cameraImage.planes[0].bytes[index];
        final u = cameraImage.planes[1].bytes[index];
        final v = cameraImage.planes[2].bytes[index];

        image.data[index] = yuv2rgb(y, u, v);
      }
    }
    return image;
  }

  static int yuv2rgb(int y, int u, int v) {
    var r = (y + v * 1436 / 1024 - 179).round();
    var g = (y - u * 46549 / 131072 + 44 - v * 93604 / 131072 + 91).round();
    var b = (y + u * 1814 / 1024 - 227).round();

    r = r.clamp(0, 255).toInt();
    g = g.clamp(0, 255).toInt();
    b = b.clamp(0, 255).toInt();

    return 0xff000000 |
        ((b << 16) & 0xff0000) |
        ((g << 8) & 0xff00) |
        (r & 0xff);
  }
}
