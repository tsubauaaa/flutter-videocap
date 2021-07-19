import 'dart:io';

import 'package:app/components/blinking_text_animation.dart';
import 'package:app/controllers//camera_provider.dart';
import 'package:camera/camera.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_beep/flutter_beep.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:path/path.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final indexProvider = StateNotifierProvider((ref) => IndexController());

class IndexController extends StateNotifier<int> {
  IndexController() : super(0);

  void change() => state == 0 ? state++ : state--;
}

class CameraPreviewTopPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isRecording = useState(false);
    final videoCapCmera = useProvider(cameraProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture a video'),
      ),
      body: videoCapCmera.when(
        data: (camera) => Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(camera.cameraController),
            if (isRecording.value)
              Align(
                alignment: Alignment.topCenter,
                child: BlinkingTextAnimation(),
              ),
            Positioned(
              top: 20,
              right: 20,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    shape: CircleBorder(),
                    padding: EdgeInsets.all(16),
                    primary: Colors.tealAccent),
                child: const Icon(
                  CupertinoIcons.camera_rotate_fill,
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
                  CupertinoIcons.videocam_circle_fill,
                ),
              ),
            )
          ],
        ),
        loading: () => Center(
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
