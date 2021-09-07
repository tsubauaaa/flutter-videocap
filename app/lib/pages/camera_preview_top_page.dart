import 'dart:io';

import 'package:app/components/blinking_text_animation.dart';
import 'package:app/models/reognition_model.dart';
import 'package:app/providers//camera_provider.dart';
import 'package:app/providers/index_provider.dart';
import 'package:app/providers/recognitions_provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path/path.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CameraPreviewTopPage extends HookWidget {
  const CameraPreviewTopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isRecording = useState(false);
    final videoCapCamera = useProvider(cameraProvider);
    final recognition = useProvider(recognitionsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture a video'),
      ),
      body: videoCapCamera.when(
        data: (camera) => Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(camera.cameraController),
            if (isRecording.value)
              const Align(
                alignment: Alignment.topCenter,
                child: BlinkingTextAnimation(),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(16),
                    primary: Colors.tealAccent),
                child: const Icon(
                  Icons.wifi_protected_setup_sharp,
                  size: 20,
                  color: Colors.black,
                ),
                onPressed: () => context.read(indexProvider.notifier).change(),
              ),
            ),
            Positioned(
              bottom: 40,
              right: 40,
              child: FloatingActionButton(
                onPressed: () => startAndStopVideoRecording(
                    camera.cameraController, isRecording),
                child: const Icon(
                  Icons.video_call_sharp,
                ),
              ),
            )
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (err, stack) => Center(
          child: Text(
            err.toString(),
          ),
        ),
      ),
    );
  }

  Future<void> startAndStopVideoRecording(CameraController cameraController,
      ValueNotifier<bool> isRecording) async {
    try {
      if (cameraController.value.isRecordingVideo) {
        FlutterBeep.playSysSound(iOSSoundIDs.EndVideoRecording);
        XFile video = await cameraController.stopVideoRecording();
        isRecording.value = cameraController.value.isRecordingVideo;

        File videoFile = File(video.path);
        final String videoPath = "/videos/" + basename(video.path);
        Reference ref = FirebaseStorage.instance.ref().child(videoPath);
        TaskSnapshot storageTaskSnapshot = await ref.putFile(videoFile);
        if (storageTaskSnapshot.ref != null) {
          final downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
          print('Stop video recording and save video.');
          print(downloadUrl.toString());
        }
        return;
      }
      try {
        FlutterBeep.playSysSound(
          iOSSoundIDs.BeginVideoRecording,
        );
        await cameraController.startVideoRecording();
        print('Start video recording.');
        isRecording.value = cameraController.value.isRecordingVideo;
      } on CameraException catch (e) {
        print(e);
      }
    } catch (e) {
      print(e);
    }
  }

// Future<void> _toggleCameraDirection() async {
  //   if (_direction == CameraLensDirection.back) {
  //     _direction = CameraLensDirection.front;
  //   } else {
  //     _direction = CameraLensDirection.back;
  //   }
  //   await _cameraController.dispose();
  //   await _initializeCamera();
  // }
}
